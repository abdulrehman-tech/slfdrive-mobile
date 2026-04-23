import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/fav_driver.dart';

class FavDriverCard extends StatelessWidget {
  final FavDriver driver;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavDriverCard({
    super.key,
    required this.driver,
    required this.isDark,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(cs),
                SizedBox(width: 12.r),
                Expanded(child: _buildInfo(cs)),
                _buildRemoveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CachedNetworkImage(
          imageUrl: driver.avatarUrl,
          imageBuilder: (_, img) => CircleAvatar(radius: 24.r, backgroundImage: img),
          placeholder: (_, _) => _buildAvatarPlaceholder(cs),
          errorWidget: (_, _, _) => _buildAvatarPlaceholder(cs),
        ),
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF1A1A2A) : Colors.white,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(ColorScheme cs) {
    return CircleAvatar(
      radius: 24.r,
      backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
      child: Icon(
        Iconsax.user_copy,
        size: 20.r,
        color: cs.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfo(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          driver.name,
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.r),
        Row(
          children: [
            Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
            SizedBox(width: 3.r),
            Text(
              '${driver.rating}  ·  ${driver.trips} trips',
              style: TextStyle(
                fontSize: 11.r,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(width: 8.r),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                driver.speciality,
                style: TextStyle(
                  fontSize: 9.r,
                  color: const Color(0xFF00BCD4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Iconsax.heart_copy, color: const Color(0xFFE91E63), size: 15.r),
      ),
    );
  }
}
