import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../constants/icon_constants.dart';
import '../../../constants/breakpoints.dart';
import '../../../constants/storage_keys.dart';
import '../../../constants/url_constants.dart';
import '../../../core/data/repositories/app_version_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/models/app/app_version_info.dart';
import '../../../core/utils/app_version_compare.dart';
import '../../utils/platform_utils.dart';
import '../../widgets/force_update_dialog.dart';

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

  /// Runs alongside the intro animation; resolves to the published version only
  /// when the installed build must be updated before continuing.
  late final Future<AppVersionInfo?> _requiredUpdate;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _logoAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _requiredUpdate = _checkRequiredUpdate();
    _startAnimations();
  }

  /// Force-update gate. Only mobile has a store to send the user to; web and
  /// desktop skip. Any failure (offline, timeout, malformed row) resolves to
  /// null — a version check must never lock users out of the app.
  Future<AppVersionInfo?> _checkRequiredUpdate() async {
    if (!PlatformUtils.isMobile) return null;
    try {
      final pkg = await PackageInfo.fromPlatform();
      final info = await getIt<AppVersionRepository>()
          .check(UrlConstants.appVersionName)
          .timeout(const Duration(seconds: 5));
      if (info == null || !info.isActive || !info.forceUpdate) return null;
      final outdated = isAppOutdated(
        currentVersion: pkg.version,
        currentBuild: int.tryParse(pkg.buildNumber) ?? 0,
        latestVersion: info.version,
        latestBuild: info.buildNumber,
      );
      return outdated ? info : null;
    } catch (_) {
      return null;
    }
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
          _navigateNext();
        }
      });
    });
  }

  /// Decide where to go after the splash animation based on persisted state:
  /// returning logged-in user → home (role-aware); already onboarded →
  /// auth; first launch → language selection. A required update blocks here
  /// instead — the dialog has no dismiss path.
  Future<void> _navigateNext() async {
    final update = await _requiredUpdate;
    if (!mounted) return;
    if (update != null) {
      ForceUpdateDialog.show(
        context,
        info: update,
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
      return;
    }

    final storage = getIt<FlutterSecureStorage>();
    final accessToken = await storage.read(key: StorageKeys.accessToken);
    final role = await storage.read(key: StorageKeys.userRole);
    final onboarded = await storage.read(key: StorageKeys.hasCompletedOnboarding);
    if (!mounted) return;

    if (accessToken != null && accessToken.isNotEmpty) {
      context.go(role == 'driver' ? '/driver/home' : '/home');
    } else if (onboarded == 'true') {
      context.go('/auth');
    } else {
      context.go('/language-selection');
    }
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
