import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark, cs)),
            SliverToBoxAdapter(child: _buildStatsRow(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 0.r)),
            SliverToBoxAdapter(child: _buildAccountSection(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: _buildSettingsSection(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: _buildNotificationsSection(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: _buildSupportSection(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: _buildDangerZone(isDark, cs)),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.r, 40.r, 20.r, 50.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12.r, offset: Offset(0, 4.r)),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Icon(Icons.person, size: 50.r, color: const Color(0xFF4D63DD)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8.r)],
                    ),
                    child: Icon(Iconsax.camera, size: 16.r, color: const Color(0xFF4D63DD)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Text(
            'driver_name'.tr(),
            style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 6.r),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'driver_badge'.tr(),
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Transform.translate(
        offset: Offset(0, -40.r),
        child: Row(
          children: [
            _buildStatCard('245', 'driver_stat_trips'.tr(), Iconsax.car, isDark),
            SizedBox(width: 12.r),
            _buildStatCard('4.8', 'driver_stat_rating'.tr(), Iconsax.star_1, isDark),
            SizedBox(width: 12.r),
            _buildStatCard('3.2k', 'driver_stat_earnings'.tr(), Iconsax.wallet_3, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.r, color: const Color(0xFF4D63DD)),
            SizedBox(height: 8.r),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_account'.tr(),
      icon: Iconsax.user,
      iconColor: const Color(0xFF4D63DD),
      children: [
        _ActionTile(isDark: isDark, cs: cs, icon: Iconsax.edit, title: 'driver_edit_profile'.tr(), onTap: () {}),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.call,
          title: 'driver_phone'.tr(),
          subtitle: '+968 9123 4567',
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'driver_email'.tr(),
          subtitle: 'driver@example.com',
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(isDark: isDark, cs: cs, icon: Iconsax.car, title: 'driver_vehicle_info'.tr(), onTap: () {}),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_settings'.tr(),
      icon: Iconsax.setting_2,
      iconColor: const Color(0xFF7C4DFF),
      children: [
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.language_square,
          title: 'driver_language'.tr(),
          subtitle: 'English',
          onTap: () {},
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.brush_2,
          title: 'driver_theme'.tr(),
          subtitle: isDark ? 'Dark' : 'Light',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_notifications'.tr(),
      icon: Iconsax.notification,
      iconColor: const Color(0xFFFFA000),
      children: [
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.notification_bing,
          title: 'driver_push_notifications'.tr(),
          subtitle: 'driver_push_desc'.tr(),
          value: _pushNotifications,
          onChanged: (val) => setState(() => _pushNotifications = val),
        ),
        _thinDivider(isDark),
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'driver_email_notifications'.tr(),
          subtitle: 'driver_email_desc'.tr(),
          value: _emailNotifications,
          onChanged: (val) => setState(() => _emailNotifications = val),
        ),
        _thinDivider(isDark),
        _ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.message,
          title: 'driver_sms_notifications'.tr(),
          subtitle: 'driver_sms_desc'.tr(),
          value: _smsNotifications,
          onChanged: (val) => setState(() => _smsNotifications = val),
        ),
      ],
    );
  }

  Widget _buildSupportSection(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_support'.tr(),
      icon: Iconsax.message_question,
      iconColor: const Color(0xFF4CAF50),
      children: [
        _ActionTile(isDark: isDark, cs: cs, icon: Iconsax.info_circle, title: 'driver_help_center'.tr(), onTap: () {}),
        _thinDivider(isDark),
        _ActionTile(isDark: isDark, cs: cs, icon: Iconsax.document_text, title: 'driver_terms'.tr(), onTap: () {}),
        _thinDivider(isDark),
        _ActionTile(isDark: isDark, cs: cs, icon: Iconsax.shield_tick, title: 'driver_privacy'.tr(), onTap: () {}),
      ],
    );
  }

  Widget _buildDangerZone(bool isDark, ColorScheme cs) {
    return _GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_danger'.tr(),
      icon: Iconsax.warning_2,
      iconColor: const Color(0xFFE53935),
      children: [
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.logout,
          title: 'driver_sign_out'.tr(),
          color: const Color(0xFFE53935),
          titleColor: const Color(0xFFE53935),
          onTap: () => _showLogoutDialog(context, isDark),
        ),
        _thinDivider(isDark),
        _ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.trash,
          title: 'driver_delete_account'.tr(),
          subtitle: 'driver_delete_warning'.tr(),
          color: const Color(0xFFE53935),
          titleColor: const Color(0xFFE53935),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _thinDivider(bool isDark) {
    return Divider(
      height: 1.r,
      thickness: 1.r,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
    );
  }

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
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 32.r),
                  ),
                  SizedBox(height: 20.r),
                  Text(
                    'driver_logout_title'.tr(),
                    style: TextStyle(
                      fontSize: 20.r,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    'driver_logout_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                  ),
                  SizedBox(height: 24.r),
                  Row(
                    children: [
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
                            'driver_logout_cancel'.tr(),
                            style: TextStyle(
                              fontSize: 15.r,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.r),
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
                            'driver_logout_confirm'.tr(),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: ClipRRect(
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
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, size: 20.r, color: iconColor),
                      ),
                      SizedBox(width: 12.r),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.r,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                ...children,
              ],
            ),
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
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Color? titleColor;

  const _ActionTile({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
        child: Row(
          children: [
            Icon(icon, size: 20.r, color: color ?? (isDark ? Colors.white70 : Colors.black54)),
            SizedBox(width: 16.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.r),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
            Icon(CupertinoIcons.forward, size: 16.r, color: isDark ? Colors.white38 : Colors.black26),
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
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: isDark ? Colors.white70 : Colors.black54),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.r),
          _MiniSwitch(value: value, onChanged: onChanged, isDark: isDark),
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

  const _MiniSwitch({required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4D63DD) : (isDark ? Colors.white24 : Colors.black12),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.all(3.r),
            width: 22.r,
            height: 22.r,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
