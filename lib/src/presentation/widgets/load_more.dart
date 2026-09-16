import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Calls [onLoadMore] when the vertical scroll view directly below it gets
/// within [threshold] px of its end — including when its content doesn't fill
/// the viewport at all. A client-side filter can leave a page too short to
/// scroll, so the check re-runs after every rebuild (i.e. after each page
/// lands) instead of relying on scroll events alone.
class LoadMoreListener extends StatefulWidget {
  final bool enabled;
  final VoidCallback onLoadMore;
  final double threshold;
  final Widget child;

  const LoadMoreListener({
    super.key,
    required this.enabled,
    required this.onLoadMore,
    required this.child,
    this.threshold = 600,
  });

  @override
  State<LoadMoreListener> createState() => _LoadMoreListenerState();
}

class _LoadMoreListenerState extends State<LoadMoreListener> {
  BuildContext? _scrollContext;
  bool _checkScheduled = false;

  /// Set after triggering a load, until the next frame has laid out: scroll
  /// events in between still report the old extent and would request the
  /// same "last page" again.
  bool _awaitingLayout = false;

  @override
  void didUpdateWidget(LoadMoreListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) _scheduleCheck();
  }

  bool _onNotification(BuildContext? source, ScrollMetrics metrics, int depth) {
    // depth 0 = our own scroll view, not a nested (e.g. horizontal chip) list.
    if (depth != 0 || metrics.axis != Axis.vertical) return false;
    _scrollContext = source;
    if (widget.enabled) _scheduleCheck();
    return false;
  }

  /// Scroll notifications can arrive mid-layout; loading notifies listeners, so
  /// defer to after the frame in that phase.
  void _scheduleCheck() {
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      _check();
      return;
    }
    if (_checkScheduled) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      _check();
    });
  }

  void _check() {
    final source = _scrollContext;
    if (_awaitingLayout || !mounted || !widget.enabled || source == null || !source.mounted) return;
    final position = source.findAncestorStateOfType<ScrollableState>()?.position;
    if (position == null || !position.hasContentDimensions || !position.hasPixels) return;
    if (position.extentAfter >= widget.threshold) return;
    _awaitingLayout = true;
    SchedulerBinding.instance.addPostFrameCallback((_) => _awaitingLayout = false);
    SchedulerBinding.instance.ensureVisualUpdate();
    widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onNotification(n.context, n.metrics, n.depth),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onNotification(n.context, n.metrics, n.depth),
        child: widget.child,
      ),
    );
  }
}

/// Bottom-of-list paging state: a spinner while the next page loads, a retry
/// button after a failed page, nothing otherwise.
class LoadMoreFooter extends StatelessWidget {
  final bool isLoading;
  final bool failed;
  final VoidCallback onRetry;

  const LoadMoreFooter({super.key, required this.isLoading, required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.r),
        child: Center(
          child: SizedBox(
            width: 22.r,
            height: 22.r,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
          ),
        ),
      );
    }
    if (failed) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.r),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 18.r),
            label: Text('common_retry'.tr(), style: TextStyle(fontSize: 13.r)),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
