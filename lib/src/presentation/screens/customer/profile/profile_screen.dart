import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// LANGUAGE DATA
// ============================================================

class _LangOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;
  const _LangOption(this.code, this.name, this.nativeName, this.locale);
}

const _languages = [
  _LangOption('en', 'English', 'English', Locale('en', 'US')),
  _LangOption('ar', 'Arabic', 'العربية', Locale('ar', 'AE')),
  _LangOption('ur', 'Urdu', 'اردو', Locale('ur', 'PK')),
  _LangOption('hi', 'Hindi', 'हिन्दी', Locale('hi', 'IN')),
  _LangOption('es', 'Spanish', 'Español', Locale('es', 'ES')),
  _LangOption('de', 'German', 'Deutsch', Locale('de', 'DE')),
  _LangOption('ru', 'Russian', 'Русский', Locale('ru', 'RU')),
];

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  String get _currentLangName {
    final loc = context.locale;
    final match = _languages.where((l) => l.locale.languageCode == loc.languageCode);
    return match.isNotEmpty ? match.first.name : 'English';
  }

  String get _currentThemeLabel {
    final tp = context.watch<ThemeProvider>();
    if (tp.isDarkMode) return 'Dark';
    if (tp.isLightMode) return 'Light';
    return 'System';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Pinned SliverAppBar with glassmorphism when collapsed
        SliverAppBar(
          pinned: true,
          expandedHeight: 280.r,
          toolbarHeight: 56.r,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final collapsed = constraints.maxHeight <= kToolbarHeight + MediaQuery.of(context).padding.top + 10;
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Expanded: gradient header
                  FlexibleSpaceBar(background: _buildHeaderForSliver(isDark, cs)),
                  // Collapsed: glassmorphism bar
                  if (collapsed)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            color: isDark
                                ? const Color(0xFF0E0E1C).withValues(alpha: 0.82)
                                : Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ),
                  // Toolbar content (always visible)
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    height: 56.r,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: collapsed ? 1.0 : 0.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        child: Row(
                          children: [
                            Text(
                              'profile_screen_title'.tr(),
                              style: TextStyle(
                                fontSize: 18.r,
                                fontWeight: FontWeight.w700,
                                color: collapsed ? cs.onSurface : Colors.white,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: collapsed
                                      ? (isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05))
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Iconsax.setting_2,
                                  size: 17.r,
                                  color: collapsed ? cs.onSurface.withValues(alpha: 0.6) : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: _buildStatsRow(isDark, cs),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 0), child: _buildAccountSection(isDark, cs)),
        ),
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildSettingsSection(isDark, cs)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
            child: _buildNotificationsSection(isDark, cs),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildSupportSection(isDark, cs)),
        ),
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildDangerSection(isDark, cs)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.r),
            child: Center(
              child: Text(
                'profile_version'.tr(),
                style: TextStyle(
                  fontSize: 11.r,
                  color: cs.onSurface.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 80.r)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile_screen_title'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              SizedBox(height: 24.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildHeader(isDark, cs, isDesktop: true),
                        SizedBox(height: 16.r),
                        _buildStatsRow(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildNotificationsSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildDangerSection(isDark, cs),
                        SizedBox(height: 16.r),
                        Text(
                          'profile_version'.tr(),
                          style: TextStyle(
                            fontSize: 11.r,
                            color: cs.onSurface.withValues(alpha: 0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.r),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildAccountSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildSettingsSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildSupportSection(isDark, cs),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER (fixed layout: centered, proper spacing)
  // ==========================================================================

  Widget _buildHeaderForSliver(bool isDark, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -30.r, top: -40.r, child: _circle(160.r, 0.06)),
          Positioned(left: -40.r, bottom: -50.r, child: _circle(120.r, 0.04)),
          Positioned(right: 60.r, bottom: -20.r, child: _circle(80.r, 0.03)),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.r),
                // Avatar
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(fontSize: 28.r, fontWeight: FontWeight.bold, color: const Color(0xFF0C2485)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.r),
                Text(
                  'profile_guest_name'.tr(),
                  style: TextStyle(
                    fontSize: 19.r,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 5.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.medal_star_copy, color: const Color(0xFFFFC107), size: 13.r),
                      SizedBox(width: 6.r),
                      Text(
                        'drawer_guest_badge'.tr(),
                        style: TextStyle(
                          fontSize: 11.r,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'profile_member_since'.tr(),
                  style: TextStyle(
                    fontSize: 11.r,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme cs, {bool isDesktop = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: isDesktop ? BorderRadius.circular(24.r) : null,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.r),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isDesktop ? BorderRadius.circular(24.r) : BorderRadius.zero,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(right: -30.r, top: -40.r, child: _circle(160.r, 0.06)),
            Positioned(left: -40.r, bottom: -50.r, child: _circle(120.r, 0.04)),
            Positioned(right: 60.r, bottom: -20.r, child: _circle(80.r, 0.03)),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(24.r, isDesktop ? 32.r : 60.r, 24.r, 28.r),
              child: Column(
                children: [
                  // Settings gear on top-right
                  if (!isDesktop)
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Icon(Iconsax.setting_2, size: 17.r, color: Colors.white70),
                        ),
                      ),
                    ),
                  SizedBox(height: isDesktop ? 0 : 8.r),
                  // Avatar
                  Container(
                    width: 76.r,
                    height: 76.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(fontSize: 28.r, fontWeight: FontWeight.bold, color: const Color(0xFF0C2485)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.r),
                  // Name
                  Text(
                    'profile_guest_name'.tr(),
                    style: TextStyle(
                      fontSize: 19.r,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  // Member badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 5.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.medal_star_copy, color: const Color(0xFFFFC107), size: 13.r),
                        SizedBox(width: 6.r),
                        Text(
                          'drawer_guest_badge'.tr(),
                          style: TextStyle(
                            fontSize: 11.r,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'profile_member_since'.tr(),
                    style: TextStyle(
                      fontSize: 11.r,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  // ==========================================================================
  // STATS ROW
  // ==========================================================================

  Widget _buildStatsRow(bool isDark, ColorScheme cs) {
    final stats = [
      (Iconsax.car_copy, '0', 'profile_stat_trips'.tr(), const Color(0xFF3D5AFE)),
      (Iconsax.heart_copy, '0', 'profile_stat_saved'.tr(), const Color(0xFFE91E63)),
      (Iconsax.star_1_copy, '—', 'profile_stat_rating'.tr(), const Color(0xFFFFC107)),
      (Iconsax.message_2, '0', 'profile_stat_reviews'.tr(), const Color(0xFF00BCD4)),
    ];

    return Transform.translate(
      offset: Offset(0, -14.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.92),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20.r,
                  offset: Offset(0, 6.r),
                ),
              ],
            ),
            child: Row(
              children: stats.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    decoration: BoxDecoration(
                      border: i < stats.length - 1
                          ? Border(
                              right: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.$2,
                          style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                        ),
                        SizedBox(height: 3.r),
                        Text(
                          s.$3,
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACCOUNT SECTION
  // ==========================================================================

  Widget _buildAccountSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'profile_section_account'.tr(),
      icon: Iconsax.user_octagon,
      iconColor: const Color(0xFF3D5AFE),
      children: [
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.edit_2,
          title: 'profile_edit_profile'.tr(),
          color: const Color(0xFF3D5AFE),
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.call,
          title: 'profile_phone'.tr(),
          color: const Color(0xFF00BCD4),
          subtitle: '+968 •••• ••00',
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'profile_email_address'.tr(),
          color: const Color(0xFF7C4DFF),
          subtitle: 'Not set',
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.shield_tick,
          title: 'profile_verify_identity'.tr(),
          color: const Color(0xFF4CAF50),
          onTap: () {},
        ),
      ],
    );
  }

  // ==========================================================================
  // SETTINGS SECTION (theme + language - functional)
  // ==========================================================================

  Widget _buildSettingsSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'settings_title'.tr(),
      icon: Iconsax.setting_2,
      iconColor: const Color(0xFF7C4DFF),
      children: [
        // Theme
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: isDark ? Iconsax.moon : Iconsax.sun_1,
          title: 'profile_theme'.tr(),
          color: const Color(0xFFFFC107),
          subtitle: _currentThemeLabel,
          onTap: () => _showThemeSheet(isDark, cs),
        ),
        _thinDivider(isDark),
        // Language
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.language_circle,
          title: 'profile_language'.tr(),
          color: const Color(0xFF00BCD4),
          subtitle: _currentLangName,
          onTap: () => _showLanguageSheet(isDark, cs),
        ),
      ],
    );
  }

  // ==========================================================================
  // NOTIFICATIONS SECTION (functional toggles)
  // ==========================================================================

  Widget _buildNotificationsSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'profile_notifications_pref'.tr(),
      icon: Iconsax.notification,
      iconColor: const Color(0xFFE91E63),
      children: [
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.notification_bing,
          title: 'settings_push_notifications'.tr(),
          subtitle: 'settings_push_desc'.tr(),
          color: const Color(0xFF3D5AFE),
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v),
        ),
        _thinDivider(isDark),
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'settings_email_notifications'.tr(),
          subtitle: 'settings_email_desc'.tr(),
          color: const Color(0xFF7C4DFF),
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _thinDivider(isDark),
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.message_text,
          title: 'settings_sms_notifications'.tr(),
          subtitle: 'settings_sms_desc'.tr(),
          color: const Color(0xFF00BCD4),
          value: _smsNotifications,
          onChanged: (v) => setState(() => _smsNotifications = v),
        ),
      ],
    );
  }

  // ==========================================================================
  // SUPPORT SECTION
  // ==========================================================================

  Widget _buildSupportSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'profile_section_support'.tr(),
      icon: Iconsax.message_question,
      iconColor: const Color(0xFF00BCD4),
      children: [
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.message_question,
          title: 'profile_help_center'.tr(),
          color: const Color(0xFF3D5AFE),
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.info_circle,
          title: 'profile_about'.tr(),
          color: const Color(0xFF7C4DFF),
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.document_text,
          title: 'profile_terms'.tr(),
          color: const Color(0xFF616161),
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.lock,
          title: 'profile_privacy_policy'.tr(),
          color: const Color(0xFF4CAF50),
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.star,
          title: 'profile_rate_app'.tr(),
          color: const Color(0xFFFFC107),
          onTap: () {},
        ),
      ],
    );
  }

  // ==========================================================================
  // DANGER SECTION
  // ==========================================================================

  Widget _buildDangerSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'profile_section_danger'.tr(),
      icon: Iconsax.warning_2,
      iconColor: const Color(0xFFE53935),
      children: [
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.logout,
          title: 'profile_sign_out'.tr(),
          color: const Color(0xFFE53935),
          titleColor: const Color(0xFFE53935),
          onTap: () => _showLogoutDialog(context, isDark),
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.trash,
          title: 'profile_delete_account'.tr(),
          color: const Color(0xFFE53935),
          subtitle: 'profile_delete_warning'.tr(),
          titleColor: const Color(0xFFE53935),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _thinDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 62.r,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
    );
  }

  // ==========================================================================
  // THEME BOTTOM SHEET
  // ==========================================================================

  void _showThemeSheet(bool isDark, ColorScheme cs) {
    final tp = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ThemeBottomSheet(isDark: isDark, cs: cs, tp: tp),
    );
  }

  // ==========================================================================
  // LANGUAGE BOTTOM SHEET
  // ==========================================================================

  void _showLanguageSheet(bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LanguageBottomSheet(
        isDark: isDark,
        cs: cs,
        currentLocale: context.locale,
        onSelect: (locale) {
          context.setLocale(locale);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // LOGOUT DIALOG
  // ==========================================================================

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 24.r,
                    offset: Offset(0, 8.r),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 32.r),
                  ),
                  SizedBox(height: 20.r),
                  // Title
                  Text(
                    'profile_logout_title'.tr(),
                    style: TextStyle(
                      fontSize: 20.r,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  // Message
                  Text(
                    'profile_logout_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                  ),
                  SizedBox(height: 24.r),
                  // Buttons
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.r),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'profile_logout_cancel'.tr(),
                            style: TextStyle(
                              fontSize: 15.r,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.r),
                      // Logout
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.r),
                            backgroundColor: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'profile_logout_confirm'.tr(),
                            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
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

// ============================================================
// GLASS SECTION
// ============================================================

class _GlassSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _GlassSection({
    required this.isDark,
    required this.cs,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 10.r),
                child: Row(
                  children: [
                    Container(
                      width: 30.r,
                      height: 30.r,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 15.r),
                    ),
                    SizedBox(width: 10.r),
                    Text(
                      title,
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACTION TILE
// ============================================================

class _ActionTile extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final Color color;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    required this.color,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 16.r),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: titleColor ?? cs.onSurface),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 1.r),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(CupertinoIcons.forward, size: 15.r, color: (titleColor ?? cs.onSurface).withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOGGLE TILE
// ============================================================

class _ToggleTile extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 1.r),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.r,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.r),
          _MiniSwitch(value: value, onChanged: onChanged, isDark: isDark, activeColor: color),
        ],
      ),
    );
  }
}

// ============================================================
// MINI SWITCH
// ============================================================

class _MiniSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final Color activeColor;

  const _MiniSwitch({required this.value, required this.onChanged, required this.isDark, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 44.r,
        height: 24.r,
        padding: EdgeInsets.all(2.5.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: value
              ? activeColor.withValues(alpha: isDark ? 0.35 : 0.25)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 19.r,
            height: 19.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? activeColor
                  : (isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: (value ? activeColor : Colors.black).withValues(alpha: 0.15),
                  blurRadius: 4.r,
                  offset: Offset(0, 1.r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// THEME BOTTOM SHEET
// ============================================================

class _ThemeBottomSheet extends StatefulWidget {
  final bool isDark;
  final ColorScheme cs;
  final ThemeProvider tp;

  const _ThemeBottomSheet({required this.isDark, required this.cs, required this.tp});

  @override
  State<_ThemeBottomSheet> createState() => _ThemeBottomSheetState();
}

class _ThemeBottomSheetState extends State<_ThemeBottomSheet> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.tp.isLightMode
        ? 0
        : widget.tp.isDarkMode
        ? 1
        : 2;
  }

  static const _options = [
    (Iconsax.sun_1, 'settings_theme_light', Color(0xFFFFC107)),
    (Iconsax.moon, 'settings_theme_dark', Color(0xFF7C4DFF)),
    (Iconsax.mobile, 'settings_theme_system', Color(0xFF3D5AFE)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cs = widget.cs;

    return Container(
      margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.r),
                Text(
                  'profile_theme'.tr(),
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                SizedBox(height: 16.r),
                ...List.generate(_options.length, (i) {
                  final o = _options[i];
                  final active = _selected == i;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.r),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selected = i);
                        switch (i) {
                          case 0:
                            widget.tp.setLightMode();
                            break;
                          case 1:
                            widget.tp.setDarkMode();
                            break;
                          case 2:
                            widget.tp.setSystemMode();
                            break;
                        }
                        Navigator.of(context).pop();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                        decoration: BoxDecoration(
                          color: active ? o.$3.withValues(alpha: isDark ? 0.15 : 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                          border: active
                              ? Border.all(color: o.$3.withValues(alpha: 0.3))
                              : Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                color: o.$3.withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(o.$1, color: o.$3, size: 17.r),
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Text(
                                o.$2.tr(),
                                style: TextStyle(
                                  fontSize: 14.r,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  color: active ? o.$3 : cs.onSurface,
                                ),
                              ),
                            ),
                            if (active)
                              Container(
                                width: 22.r,
                                height: 22.r,
                                decoration: BoxDecoration(color: o.$3, shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, size: 14.r, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LANGUAGE BOTTOM SHEET
// ============================================================

class _LanguageBottomSheet extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Locale currentLocale;
  final ValueChanged<Locale> onSelect;

  const _LanguageBottomSheet({
    required this.isDark,
    required this.cs,
    required this.currentLocale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.r),
                Text(
                  'profile_language'.tr(),
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                SizedBox(height: 16.r),
                ...List.generate(_languages.length, (i) {
                  final lang = _languages[i];
                  final active = currentLocale.languageCode == lang.locale.languageCode;
                  const col = Color(0xFF00BCD4);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.r),
                    child: GestureDetector(
                      onTap: () => onSelect(lang.locale),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                        decoration: BoxDecoration(
                          color: active ? col.withValues(alpha: isDark ? 0.15 : 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                          border: active
                              ? Border.all(color: col.withValues(alpha: 0.3))
                              : Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36.r,
                              child: Text(
                                lang.code.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.r,
                                  fontWeight: FontWeight.w700,
                                  color: active ? col : cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.name,
                                    style: TextStyle(
                                      fontSize: 13.r,
                                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                      color: active ? col : cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.45)),
                                  ),
                                ],
                              ),
                            ),
                            if (active)
                              Container(
                                width: 22.r,
                                height: 22.r,
                                decoration: const BoxDecoration(color: col, shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, size: 14.r, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
