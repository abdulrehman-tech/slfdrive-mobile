import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/bottom_sheets/app_bottom_sheet.dart';

// ============================================================
// PROFILE — simplified
//
// Pragmatic sections only:
//   Sliver glass header (name + tier)
//   Account
//   Preferences
//   My data  (addresses / cards / docs as navigation tiles)
//   Support
//   Sign out
// ============================================================

class _LangOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;
  const _LangOption(this.code, this.name, this.nativeName, this.locale);
}

const _languages = <_LangOption>[
  _LangOption('en', 'English', 'English', Locale('en', 'US')),
  _LangOption('ar', 'Arabic', 'العربية', Locale('ar', 'AE')),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final next = _scroll.offset.clamp(0, 200).toDouble();
    if ((next - _scrollOffset).abs() > 0.5) {
      setState(() => _scrollOffset = next);
    }
  }

  // ---- THEME / LOCALE helpers (NEVER call context.watch from here) -----------
  bool _computeIsDark(BuildContext ctx) {
    final tp = Provider.of<ThemeProvider>(ctx, listen: false);
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(ctx).platformBrightness == Brightness.dark);
  }

  String _currentLangName(BuildContext ctx) {
    final loc = ctx.locale;
    final match = _languages.where((l) => l.locale.languageCode == loc.languageCode);
    return match.isNotEmpty ? match.first.name : 'English';
  }

  String _currentThemeLabel(BuildContext ctx) {
    final tp = Provider.of<ThemeProvider>(ctx, listen: false);
    if (tp.isDarkMode) return 'theme_dark'.tr();
    if (tp.isLightMode) return 'theme_light'.tr();
    return 'profile_theme_system'.tr();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ThemeProvider here (in build is valid) so that toggling from the
    // sheet triggers this screen to rebuild and pick up new values.
    context.watch<ThemeProvider>();
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _computeIsDark(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop(isDark) : _buildMobile(isDark),
    );
  }

  // ==========================================================================
  // MOBILE
  // ==========================================================================

  Widget _buildMobile(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Gradient header scrolls naturally with the content.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, topPad + 12.r, 16.r, 0),
                child: _buildHeaderCard(isDark, rounded: true),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 100.r),
              sliver: SliverList.list(
                children: [
                  _buildAccountSection(cs, isDark),
                  SizedBox(height: 16.r),
                  _buildPreferencesSection(cs, isDark),
                  SizedBox(height: 16.r),
                  _buildMyDataSection(cs, isDark),
                  SizedBox(height: 16.r),
                  _buildSupportSection(cs, isDark),
                  SizedBox(height: 16.r),
                  _buildSignOutButton(isDark),
                  SizedBox(height: 20.r),
                  Center(
                    child: Text(
                      'profile_version'.tr(),
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Glass bar overlay — fades in only after the gradient header scrolls past.
        Positioned(left: 0, right: 0, top: 0, child: _buildGlassOverlay(isDark)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktop(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 960.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile_screen_title'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              SizedBox(height: 20.r),
              _buildHeaderCard(isDark, rounded: true),
              SizedBox(height: 20.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildAccountSection(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildMyDataSection(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildSupportSection(cs, isDark),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildPreferencesSection(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildSignOutButton(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // GLASS OVERLAY — fades in only AFTER the gradient card scrolls past.
  // This avoids any translucent "banner" artifact below a pinned app bar.
  // ==========================================================================

  Widget _buildGlassOverlay(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    // Don't start fading in until most of the gradient card has scrolled away.
    const triggerStart = 120.0;
    const triggerEnd = 170.0;
    final t = ((_scrollOffset - triggerStart) / (triggerEnd - triggerStart)).clamp(0.0, 1.0);

    return IgnorePointer(
      ignoring: t < 0.6,
      child: Opacity(
        opacity: t,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.r, topPad + 6.r, 12.r, 10.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.74) : Colors.white.withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildSmallAvatar(),
                  SizedBox(width: 10.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'profile_guest_name'.tr(),
                          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                        Text(
                          'profile_tier_gold'.tr(),
                          style: TextStyle(fontSize: 10.r, color: const Color(0xFFFFC107), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Iconsax.setting_2_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.7)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w900, color: const Color(0xFF0C2485)),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER CARD (used both in expanded sliver and on desktop)
  // ==========================================================================

  Widget _buildHeaderCard(bool isDark, {required bool rounded}) {
    final cs = Theme.of(context).colorScheme;
    final topPad = rounded ? 0.0 : MediaQuery.of(context).padding.top;

    return Container(
      margin: rounded ? EdgeInsets.zero : EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(20.r, topPad + 16.r, 20.r, 20.r),
      decoration: BoxDecoration(
        borderRadius: rounded ? BorderRadius.circular(22.r) : null,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: rounded
            ? [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 18.r, offset: Offset(0, 8.r))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2.5),
            ),
            child: Center(
              child: Text(
                'G',
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.w900, color: const Color(0xFF0C2485)),
              ),
            ),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'profile_guest_name'.tr(),
                  style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFD54F)]),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.medal_star_copy, size: 11.r, color: const Color(0xFF8B5A00)),
                      SizedBox(width: 4.r),
                      Text(
                        'profile_tier_gold'.tr(),
                        style: TextStyle(fontSize: 10.r, color: const Color(0xFF5D3A00), fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'guest@slfdrive.com',
                  style: TextStyle(fontSize: 11.r, color: Colors.white.withValues(alpha: 0.75)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Icon(Iconsax.edit_copy, size: 16.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTIONS
  // ==========================================================================

  Widget _buildAccountSection(ColorScheme cs, bool isDark) {
    return _Section(
      title: 'profile_section_account'.tr(),
      isDark: isDark,
      children: [
        _Tile(
          icon: Iconsax.call_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_phone'.tr(),
          value: '+968 9000 0000',
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.sms_copy,
          iconColor: const Color(0xFF00BCD4),
          title: 'profile_email_address'.tr(),
          value: 'guest@slfdrive.com',
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.shield_tick_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_verify_identity'.tr(),
          value: 'profile_verified'.tr(),
          valueColor: const Color(0xFF4CAF50),
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ColorScheme cs, bool isDark) {
    return _Section(
      title: 'profile_section_preferences'.tr(),
      isDark: isDark,
      children: [
        _Tile(
          icon: Iconsax.global_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_language'.tr(),
          value: _currentLangName(context),
          isDark: isDark,
          onTap: _showLanguageSheet,
        ),
        _Tile(
          icon: Iconsax.brush_2_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_theme'.tr(),
          value: _currentThemeLabel(context),
          isDark: isDark,
          onTap: _showThemeSheet,
        ),
        _Tile(
          icon: Iconsax.money_recive_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_currency'.tr(),
          value: 'OMR',
          isDark: isDark,
          onTap: () {},
        ),
        _ToggleTile(
          icon: Iconsax.notification_copy,
          iconColor: const Color(0xFFFF6D00),
          title: 'settings_push_notifications'.tr(),
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMyDataSection(ColorScheme cs, bool isDark) {
    return _Section(
      title: 'profile_section_my_data'.tr(),
      isDark: isDark,
      children: [
        _Tile(
          icon: Iconsax.location_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_section_addresses'.tr(),
          value: '2',
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.card_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_section_payments'.tr(),
          value: '2',
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.personalcard_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_section_documents'.tr(),
          value: 'profile_pending'.tr(),
          valueColor: const Color(0xFFFF6D00),
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSection(ColorScheme cs, bool isDark) {
    return _Section(
      title: 'profile_section_support'.tr(),
      isDark: isDark,
      children: [
        _Tile(
          icon: Iconsax.message_question_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_help_center'.tr(),
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.star_1_copy,
          iconColor: const Color(0xFFFFC107),
          title: 'profile_rate_app'.tr(),
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.document_text_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_terms'.tr(),
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.security_safe_copy,
          iconColor: const Color(0xFF00BCD4),
          title: 'profile_privacy_policy'.tr(),
          isDark: isDark,
          onTap: () {},
        ),
        _Tile(
          icon: Iconsax.info_circle_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_about'.tr(),
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.logout_copy, size: 17.r, color: const Color(0xFFE53935)),
            SizedBox(width: 8.r),
            Text(
              'profile_sign_out'.tr(),
              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: const Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SHEETS
  // ==========================================================================

  void _showThemeSheet() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _computeIsDark(context);
    final tp = context.read<ThemeProvider>();
    AppBottomSheet.show(
      context: context,
      title: 'profile_theme'.tr(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOption(
              icon: Iconsax.sun_1_copy,
              label: 'theme_light'.tr(),
              color: const Color(0xFFFFC107),
              active: tp.isLightMode,
              onTap: () {
                tp.setLightMode();
                Navigator.pop(context);
              },
              isDark: isDark,
              cs: cs,
            ),
            _SheetOption(
              icon: Iconsax.moon_copy,
              label: 'theme_dark'.tr(),
              color: const Color(0xFF7C4DFF),
              active: tp.isDarkMode,
              onTap: () {
                tp.setDarkMode();
                Navigator.pop(context);
              },
              isDark: isDark,
              cs: cs,
            ),
            _SheetOption(
              icon: Iconsax.mobile_copy,
              label: 'profile_theme_system'.tr(),
              color: const Color(0xFF00BCD4),
              active: tp.isSystemMode,
              onTap: () {
                tp.setSystemMode();
                Navigator.pop(context);
              },
              isDark: isDark,
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _computeIsDark(context);
    AppBottomSheet.show(
      context: context,
      title: 'profile_language'.tr(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((l) {
            final active = context.locale.languageCode == l.locale.languageCode;
            return GestureDetector(
              onTap: () {
                context.setLocale(l.locale);
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.r),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: active
                      ? cs.primary.withValues(alpha: isDark ? 0.18 : 0.1)
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: active
                        ? cs.primary.withValues(alpha: 0.3)
                        : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: active ? cs.primary : cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Center(
                        child: Text(
                          l.code.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.r,
                            fontWeight: FontWeight.w800,
                            color: active ? Colors.white : cs.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.r),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.name,
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                          ),
                          SizedBox(height: 2.r),
                          Text(
                            l.nativeName,
                            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    if (active) Icon(Iconsax.tick_circle_copy, color: cs.primary, size: 19.r),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final isDark = _computeIsDark(context);
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.logout_copy, color: const Color(0xFFE53935), size: 28.r),
                  ),
                  SizedBox(height: 18.r),
                  Text(
                    'profile_logout_title'.tr(),
                    style: TextStyle(
                      fontSize: 18.r,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    'profile_logout_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                  ),
                  SizedBox(height: 20.r),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 13.r),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'profile_logout_cancel'.tr(),
                            style: TextStyle(
                              fontSize: 13.r,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.r),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (context.mounted) context.go('/auth');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 13.r),
                            backgroundColor: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'profile_logout_confirm'.tr(),
                            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;
  const _Section({required this.title, required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.r, 0, 4.r, 10.r),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.4,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.055) : Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Color? valueColor;
  final bool isDark;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.onTap,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 16.r, color: iconColor),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
              ),
              if (value != null)
                Padding(
                  padding: EdgeInsets.only(right: 6.r),
                  child: Text(
                    value!,
                    style: TextStyle(
                      fontSize: 12.r,
                      color: valueColor ?? cs.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right, size: 18.r, color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.r, color: iconColor),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 38.r,
              height: 22.r,
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                color: value ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18.r,
                  height: 18.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3.r, offset: Offset(0, 1.r)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme cs;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.r),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.35)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: color, size: 18.r),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            if (active) Icon(Iconsax.tick_circle_copy, color: color, size: 19.r),
          ],
        ),
      ),
    );
  }
}
