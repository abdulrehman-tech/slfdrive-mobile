import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';

/// Renders a hosted legal document (Terms or Privacy Policy) inside an in-app
/// browser. The URL comes from `LegalConstants` and is the same public link
/// entered in the App Store / Play Console listings, so the in-app view and the
/// store link always show identical content.
class LegalDocumentScreen extends StatefulWidget {
  final String titleKey;
  final String url;

  const LegalDocumentScreen({super.key, required this.titleKey, required this.url});

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  double _progress = 0;
  bool _error = false;
  InAppWebViewController? _controller;

  void _reload() {
    setState(() {
      _error = false;
      _progress = 0;
    });
    _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isDark =
        tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.titleKey.tr()),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: _progress < 1.0 && !_error
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
              )
            : null,
      ),
      body: _error ? _buildError(isDark) : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        supportZoom: false,
      ),
      onWebViewCreated: (c) => _controller = c,
      onProgressChanged: (controller, p) => setState(() => _progress = p / 100),
      onReceivedError: (controller, request, error) {
        if (mounted) setState(() => _error = true);
      },
      onReceivedHttpError: (controller, request, response) {
        final code = response.statusCode ?? 0;
        if (mounted && code >= 400) setState(() => _error = true);
      },
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 56.r, color: isDark ? whiteColor : darkGrayColor),
            SizedBox(height: 20.r),
            Text(
              'legal_load_error'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.5,
                color: isDark ? whiteColor.withValues(alpha: 0.8) : darkGrayColor,
              ),
            ),
            SizedBox(height: 24.r),
            OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Iconsax.refresh),
              label: Text('legal_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
