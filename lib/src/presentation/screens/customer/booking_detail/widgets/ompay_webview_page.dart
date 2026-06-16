import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Outcome of the OmPay checkout WebView, decided by which `slfdrive://payment/*`
/// return URL the gateway redirected to.
enum OmPayWebOutcome { success, cancelled, failed }

class OmPayWebResult {
  final OmPayWebOutcome outcome;
  final String? orderId;
  final String? status;
  const OmPayWebResult(this.outcome, {this.orderId, this.status});
}

/// Secure in-app WebView that hosts the OmPay checkout page and intercepts the
/// `slfdrive://payment/{success,cancel,failure}` return redirect.
///
/// TLS is fully verified except for the app's self-signed API host
/// (`161.97.144.112`) — mirrors the allowlist in `core/network/api_client.dart`.
class OmPayWebViewPage extends StatefulWidget {
  final String checkoutUrl;

  /// URL substrings that mark the gateway's terminal "return" page (the backend
  /// `.../Payment/ompay/result` endpoint). Reaching one means the payment flow
  /// finished — the page is allowed to load (so the backend can capture), then
  /// the WebView closes and the caller confirms the order via verify.
  final List<String> returnUrlContains;

  const OmPayWebViewPage({
    super.key,
    required this.checkoutUrl,
    this.returnUrlContains = const ['/ompay/result'],
  });

  /// The self-signed host whose certificate is trusted (the SLF API). Every
  /// other host keeps full TLS verification.
  static const _trustedSelfSignedHost = '161.97.144.112';

  /// Custom return scheme + host configured on the gateway.
  static const _returnScheme = 'slfdrive';
  static const _returnHost = 'payment';

  @override
  State<OmPayWebViewPage> createState() => _OmPayWebViewPageState();
}

class _OmPayWebViewPageState extends State<OmPayWebViewPage> {
  double _progress = 0;
  bool _error = false;
  bool _done = false; // guards against double-pop from overlapping callbacks
  InAppWebViewController? _controller;

  void _finish(OmPayWebResult result) {
    if (!mounted || _done) return;
    _done = true;
    Navigator.of(context).pop(result);
  }

  bool _isReturnUrl(String url) =>
      widget.returnUrlContains.any((m) => m.isNotEmpty && url.contains(m));

  /// Maps a `slfdrive://payment/<path>` URL to a result, or null if it isn't a
  /// return URL.
  OmPayWebResult? _resultFor(WebUri? uri) {
    if (uri == null) return null;
    if (uri.scheme != OmPayWebViewPage._returnScheme || uri.host != OmPayWebViewPage._returnHost) {
      return null;
    }
    final path = (uri.path.isEmpty ? '' : uri.path).replaceAll('/', '').toLowerCase();
    final orderId = uri.queryParameters['orderId'];
    final status = uri.queryParameters['status'];
    final outcome = switch (path) {
      'success' => OmPayWebOutcome.success,
      'failure' || 'failed' || 'fail' => OmPayWebOutcome.failed,
      _ => OmPayWebOutcome.cancelled, // cancel + anything unexpected
    };
    return OmPayWebResult(outcome, orderId: orderId, status: status);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(const OmPayWebResult(OmPayWebOutcome.cancelled));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('pay_checkout_title'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _finish(const OmPayWebResult(OmPayWebOutcome.cancelled)),
          ),
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
                )
              : null,
        ),
        body: _error ? _errorView(cs) : _webView(),
      ),
    );
  }

  Widget _webView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        javaScriptEnabled: true,
        transparentBackground: false,
        // Payment pages must not be cached/restored across sessions.
        cacheEnabled: false,
        clearCache: true,
      ),
      onWebViewCreated: (c) => _controller = c,
      shouldOverrideUrlLoading: (controller, action) async {
        final result = _resultFor(action.request.url);
        if (result != null) {
          _finish(result);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        final host = challenge.protectionSpace.host;
        return ServerTrustAuthResponse(
          action: host == OmPayWebViewPage._trustedSelfSignedHost
              ? ServerTrustAuthResponseAction.PROCEED
              : ServerTrustAuthResponseAction.CANCEL,
        );
      },
      onLoadStop: (controller, uri) async {
        // The gateway redirects to the backend result page when the flow ends.
        // We let it load (so the backend captures the payment), then close and
        // let the caller verify the order. Outcome=success here only means
        // "returned" — verify decides paid vs pending.
        if (uri != null && _isReturnUrl(uri.toString())) {
          _finish(const OmPayWebResult(OmPayWebOutcome.success));
        }
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) return;
        setState(() => _progress = progress / 100.0);
      },
      onReceivedError: (controller, request, error) {
        // Only surface main-frame failures, not sub-resource hiccups.
        if (!mounted || !request.isForMainFrame!) return;
        setState(() => _error = true);
      },
    );
  }

  Widget _errorView(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 44, color: cs.error),
            const SizedBox(height: 12),
            Text(
              'pay_webview_error'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => _finish(const OmPayWebResult(OmPayWebOutcome.cancelled)),
                  child: Text('cancel'.tr()),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _error = false;
                      _progress = 0;
                    });
                    _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(widget.checkoutUrl)));
                  },
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
