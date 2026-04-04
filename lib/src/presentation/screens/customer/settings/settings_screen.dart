import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states (mock)
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _promoNotifications = true;
  bool _biometrics = false;
  bool _autoDownload = true;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
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
        // App bar
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 0,
          toolbarHeight: 64.r,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.72),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: Text(
              'settings_title'.tr(),
              style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
          ),
        ),
        // Appearance
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 20.r, 16.r, 0), child: _buildAppearanceSection(isDark, cs)),
        ),
        // Notifications
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
            child: _buildNotificationsSection(isDark, cs),
          ),
        ),
        // Privacy & Security
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0), child: _buildPrivacySection(isDark, cs)),
        ),
        // Data & Storage
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0), child: _buildDataSection(isDark, cs)),
        ),
        // About
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0), child: _buildAboutSection(isDark, cs)),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.r)),
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
                'settings_title'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              SizedBox(height: 24.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildAppearanceSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildNotificationsSection(isDark, cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.r),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPrivacySection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildDataSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildAboutSection(isDark, cs),
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
  // APPEARANCE SECTION
  // ==========================================================================

  Widget _buildAppearanceSection(bool isDark, ColorScheme cs) {
    final tp = context.watch<ThemeProvider>();

    return _SettingsCard(
      isDark: isDark,
      cs: cs,
      title: 'settings_appearance'.tr(),
      icon: Iconsax.brush_1,
      iconColor: const Color(0xFF7C4DFF),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'settings_theme_mode'.tr(),
                style: TextStyle(
                  fontSize: 12.r,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 10.r),
              // Theme toggle pills
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    _ThemeOption(
                      label: 'settings_theme_light'.tr(),
                      icon: Iconsax.sun_1,
                      active: tp.isLightMode,
                      activeColor: const Color(0xFFFFC107),
                      isDark: isDark,
                      cs: cs,
                      onTap: () => tp.setLightMode(),
                    ),
                    _ThemeOption(
                      label: 'settings_theme_dark'.tr(),
                      icon: Iconsax.moon,
                      active: tp.isDarkMode,
                      activeColor: const Color(0xFF7C4DFF),
                      isDark: isDark,
                      cs: cs,
                      onTap: () => tp.setDarkMode(),
                    ),
                    _ThemeOption(
                      label: 'settings_theme_system'.tr(),
                      icon: Iconsax.mobile,
                      active: tp.isSystemMode,
                      activeColor: const Color(0xFF3D5AFE),
                      isDark: isDark,
                      cs: cs,
                      onTap: () => tp.setSystemMode(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Language
        Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.language_circle,
          iconColor: const Color(0xFF00BCD4),
          title: 'settings_language'.tr(),
          subtitle: 'settings_current_language'.tr(),
          onTap: () {},
        ),
      ],
    );
  }

  // ==========================================================================
  // NOTIFICATIONS SECTION
  // ==========================================================================

  Widget _buildNotificationsSection(bool isDark, ColorScheme cs) {
    return _SettingsCard(
      isDark: isDark,
      cs: cs,
      title: 'settings_notifications'.tr(),
      icon: Iconsax.notification,
      iconColor: const Color(0xFFE91E63),
      children: [
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.notification_bing,
          iconColor: const Color(0xFF3D5AFE),
          title: 'settings_push_notifications'.tr(),
          subtitle: 'settings_push_desc'.tr(),
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v),
        ),
        _divider(isDark),
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          iconColor: const Color(0xFF7C4DFF),
          title: 'settings_email_notifications'.tr(),
          subtitle: 'settings_email_desc'.tr(),
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _divider(isDark),
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.message_text,
          iconColor: const Color(0xFF00BCD4),
          title: 'settings_sms_notifications'.tr(),
          subtitle: 'settings_sms_desc'.tr(),
          value: _smsNotifications,
          onChanged: (v) => setState(() => _smsNotifications = v),
        ),
        _divider(isDark),
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.discount_shape,
          iconColor: const Color(0xFFFFA726),
          title: 'settings_promo_notifications'.tr(),
          subtitle: 'settings_promo_desc'.tr(),
          value: _promoNotifications,
          onChanged: (v) => setState(() => _promoNotifications = v),
        ),
      ],
    );
  }

  // ==========================================================================
  // PRIVACY SECTION
  // ==========================================================================

  Widget _buildPrivacySection(bool isDark, ColorScheme cs) {
    return _SettingsCard(
      isDark: isDark,
      cs: cs,
      title: 'settings_privacy'.tr(),
      icon: Iconsax.shield_tick,
      iconColor: const Color(0xFF4CAF50),
      children: [
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.finger_scan,
          iconColor: const Color(0xFF3D5AFE),
          title: 'settings_biometrics'.tr(),
          subtitle: 'settings_biometrics_desc'.tr(),
          value: _biometrics,
          onChanged: (v) => setState(() => _biometrics = v),
        ),
        _divider(isDark),
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.password_check,
          iconColor: const Color(0xFF7C4DFF),
          title: 'settings_change_pin'.tr(),
          onTap: () {},
        ),
        _divider(isDark),
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.security_safe,
          iconColor: const Color(0xFFFFA726),
          title: 'settings_two_factor'.tr(),
          onTap: () {},
        ),
      ],
    );
  }

  // ==========================================================================
  // DATA & STORAGE SECTION
  // ==========================================================================

  Widget _buildDataSection(bool isDark, ColorScheme cs) {
    return _SettingsCard(
      isDark: isDark,
      cs: cs,
      title: 'settings_data'.tr(),
      icon: Iconsax.document_download,
      iconColor: const Color(0xFF00BCD4),
      children: [
        _SettingsToggle(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.image,
          iconColor: const Color(0xFF7C4DFF),
          title: 'settings_auto_download'.tr(),
          subtitle: 'settings_auto_download_desc'.tr(),
          value: _autoDownload,
          onChanged: (v) => setState(() => _autoDownload = v),
        ),
        _divider(isDark),
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.trash,
          iconColor: const Color(0xFFE53935),
          title: 'settings_clear_cache'.tr(),
          subtitle: 'settings_clear_cache_desc'.tr(),
          onTap: () {},
        ),
      ],
    );
  }

  // ==========================================================================
  // ABOUT SECTION
  // ==========================================================================

  Widget _buildAboutSection(bool isDark, ColorScheme cs) {
    return _SettingsCard(
      isDark: isDark,
      cs: cs,
      title: 'settings_about'.tr(),
      icon: Iconsax.info_circle,
      iconColor: const Color(0xFF616161),
      children: [
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.mobile,
          iconColor: const Color(0xFF3D5AFE),
          title: 'settings_version'.tr(),
          subtitle: '1.0.0 (Build 1)',
          onTap: () {},
          showChevron: false,
        ),
        _divider(isDark),
        _SettingsTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.code,
          iconColor: const Color(0xFF7C4DFF),
          title: 'settings_licenses'.tr(),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60.r,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
    );
  }
}

// ============================================================
// SETTINGS CARD (Glass container)
// ============================================================

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SettingsCard({
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
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 16.r),
                    ),
                    SizedBox(width: 10.r),
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
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
// SETTINGS TILE (Tap)
// ============================================================

class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 13.r),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: iconColor, size: 17.r),
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
                    SizedBox(height: 2.r),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron) Icon(Iconsax.arrow_right_3, size: 16.r, color: cs.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS TOGGLE
// ============================================================

class _SettingsToggle extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
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
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, color: iconColor, size: 17.r),
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
                  SizedBox(height: 2.r),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.r,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.r),
          _GlassSwitch(value: value, onChanged: onChanged, isDark: isDark, activeColor: iconColor),
        ],
      ),
    );
  }
}

// ============================================================
// THEME OPTION (pill in theme selector)
// ============================================================

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: active ? Border.all(color: activeColor.withValues(alpha: 0.25)) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.r, color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4)),
              SizedBox(height: 4.r),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.r,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLASS SWITCH (custom toggle)
// ============================================================

class _GlassSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final Color activeColor;

  const _GlassSwitch({required this.value, required this.onChanged, required this.isDark, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 46.r,
        height: 26.r,
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          color: value
              ? activeColor.withValues(alpha: isDark ? 0.35 : 0.25)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1)),
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.r,
            height: 20.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? activeColor
                  : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: (value ? activeColor : Colors.black).withValues(alpha: 0.2),
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
