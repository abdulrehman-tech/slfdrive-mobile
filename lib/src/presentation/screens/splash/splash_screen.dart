import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../constants/icon_constants.dart';
import '../../../constants/breakpoints.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  String _displayedText = '';
  String get _fullText => 'splash_tagline'.tr();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _logoAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _startTypewriterEffect();
  }

  void _startTypewriterEffect() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 80));
      if (_currentIndex < _fullText.length) {
        setState(() {
          _currentIndex++;
          _displayedText = _fullText.substring(0, _currentIndex);
        });
        return true;
      }
      return false;
    }).then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.go('/language-selection');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
            final isTablet = Breakpoints.isTablet(constraints.maxWidth);

            final logoSize = isDesktop ? 300.0 : (isTablet ? 250.0 : 200.r);
            final fontSize = isDesktop ? 28.0 : (isTablet ? 22.0 : 18.r);
            final textHeight = isDesktop ? 50.0 : (isTablet ? 40.0 : 30.r);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(_logoAnimation),
                      child: SvgPicture.asset(
                        isDark ? IconConstants.logoWhite : IconConstants.logo,
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: textHeight,
                    child: Text(
                      _displayedText,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: isDark ? Colors.white : const Color(0xFF0C2485),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
