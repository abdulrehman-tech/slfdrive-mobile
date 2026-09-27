import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Page background shared by every driver tab (the shell paints the same).
Color driverPageBackground(bool isDark) => isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

/// Bottom padding a driver tab needs so its last item clears the floating nav
/// bar with breathing room. The shell sets `extendBody`, so the nav height
/// arrives as the body's bottom inset — [context] must be below the Scaffold.
double driverBottomClearance(BuildContext context) => MediaQuery.paddingOf(context).bottom + 32.r;

/// Frosted surface the driver headers turn into once content scrolls under
/// them. [glass] 0 = flat page colour (at rest), 1 = blurred and translucent
/// with a hairline, so the resting header is seamless with the page.
class _GlassSurface extends StatelessWidget {
  final double glass;
  final bool isDark;
  final Widget child;

  const _GlassSurface({required this.glass, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = driverPageBackground(isDark);
    final line = isDark ? Colors.white : Colors.black;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20 * glass, sigmaY: 20 * glass),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 1 - 0.22 * glass),
            border: Border(
              bottom: BorderSide(color: line.withValues(alpha: (isDark ? 0.08 : 0.07) * glass), width: 0.8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Collapsing tab header: a large, start-aligned title that shrinks into a
/// centred compact title as the page scrolls, with an optional [bottom] (tab
/// selector) that stays pinned underneath. Includes the status-bar inset, so
/// the tab body must not add its own top SafeArea.
class DriverSliverHeader extends StatelessWidget {
  final String title;
  final Widget? bottom;

  /// Exact height of [bottom]; the selector widgets size themselves to it.
  final double bottomHeight;
  final bool isDark;

  const DriverSliverHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.bottom,
    this.bottomHeight = 0,
  });

  /// Total height while expanded — use as RefreshIndicator.edgeOffset.
  static double expandedExtent(BuildContext context, {double bottomHeight = 0}) =>
      MediaQuery.paddingOf(context).top + 64.r + bottomHeight;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CollapsingTitleDelegate(
        title: title,
        bottom: bottom,
        bottomHeight: bottom == null ? 0 : bottomHeight,
        topInset: MediaQuery.paddingOf(context).top,
        largeHeight: 64.r,
        compactHeight: 48.r,
        isDark: isDark,
        textDirection: Directionality.of(context),
      ),
    );
  }
}

class _CollapsingTitleDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Widget? bottom;
  final double bottomHeight;
  final double topInset;
  final double largeHeight;
  final double compactHeight;
  final bool isDark;
  final TextDirection textDirection;

  _CollapsingTitleDelegate({
    required this.title,
    required this.bottom,
    required this.bottomHeight,
    required this.topInset,
    required this.largeHeight,
    required this.compactHeight,
    required this.isDark,
    required this.textDirection,
  });

  @override
  double get maxExtent => topInset + largeHeight + bottomHeight;

  @override
  double get minExtent => topInset + compactHeight + bottomHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    // Glass fades in over the first part of the collapse and stays on while
    // content is underneath (t stays 1 once fully collapsed). Note:
    // overlapsContent is NOT "content is under me" — it only reports another
    // sliver overlapping this one — so drive everything from shrinkOffset.
    final glass = math.min(1.0, t * 1.6);
    final titleHeight = lerpDouble(largeHeight, compactHeight, t)!;
    final start = textDirection == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft;

    return _GlassSurface(
      glass: glass,
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: Column(
          children: [
            SizedBox(
              height: titleHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.r),
                child: Align(
                  alignment: Alignment.lerp(start, Alignment.center, t)!,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: lerpDouble(28.r, 17.r, t),
                      fontWeight: FontWeight.w800,
                      letterSpacing: lerpDouble(-0.4, 0, t),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            if (bottom != null) SizedBox(height: bottomHeight, child: bottom),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CollapsingTitleDelegate old) =>
      old.title != title ||
      old.bottom != bottom ||
      old.bottomHeight != bottomHeight ||
      old.topInset != topInset ||
      old.largeHeight != largeHeight ||
      old.compactHeight != compactHeight ||
      old.isDark != isDark ||
      old.textDirection != textDirection;
}

/// Pins [child] (a fixed-height bar) under the status bar and turns it into
/// frosted glass once content scrolls beneath it.
class DriverPinnedGlassHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final bool isDark;

  const DriverPinnedGlassHeader({super.key, required this.child, required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedGlassDelegate(
        child: child,
        height: height,
        topInset: MediaQuery.paddingOf(context).top,
        isDark: isDark,
      ),
    );
  }
}

class _PinnedGlassDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final double topInset;
  final bool isDark;

  _PinnedGlassDelegate({required this.child, required this.height, required this.topInset, required this.isDark});

  @override
  double get maxExtent => topInset + height;

  @override
  double get minExtent => topInset + height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // A fixed-height header never "collapses"; shrinkOffset still grows with
    // the scroll, so > 0 means content is passing beneath. Fade the glass in/
    // out over a short tween at that moment.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: shrinkOffset > 0 ? 1 : 0),
      duration: const Duration(milliseconds: 180),
      builder: (context, glass, child) => _GlassSurface(glass: glass, isDark: isDark, child: child!),
      child: Padding(padding: EdgeInsets.only(top: topInset), child: child),
    );
  }

  @override
  bool shouldRebuild(_PinnedGlassDelegate old) =>
      old.child != child || old.height != height || old.topInset != topInset || old.isDark != isDark;
}
