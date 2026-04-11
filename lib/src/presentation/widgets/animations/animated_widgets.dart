import 'package:flutter/material.dart';

/// A widget that animates its child with a fade and slide effect when it appears.
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation after a delay based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// A list view with staggered animations for each item.
class AnimatedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final Duration animationDuration;
  final Duration staggerDelay;

  const AnimatedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.animationDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      padding: padding,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AnimatedCard(
          index: index,
          duration: animationDuration,
          delay: staggerDelay,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// A grid view with staggered animations for each item.
class AnimatedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final Duration animationDuration;
  final Duration staggerDelay;

  const AnimatedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.animationDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AnimatedCard(
          index: index,
          duration: animationDuration,
          delay: staggerDelay,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// A wrapper that adds a scale animation on tap.
class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressedScale;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.pressedScale = 0.96,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// A shimmer loading effect widget.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({super.key, required this.child, this.isLoading = true});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

    _animation = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey[800]!, Colors.grey[700]!, Colors.grey[800]!]
                  : [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
