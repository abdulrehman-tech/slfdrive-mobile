import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/auth_gate.dart';
import '../../favorites/provider/favorites_provider.dart';
import '../provider/driver_detail_provider.dart';
import 'glass_button.dart';
import 'identity_card.dart';

class CoverHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool isDesktop;

  const CoverHeader({super.key, required this.isDark, required this.cs, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverDetailProvider>();
    final profile = provider.profile!;
    // Backend has no per-driver cover yet → fall back to a bundled asset.
    final ImageProvider coverImage = profile.coverUrl.isEmpty
        ? const AssetImage('assets/images/pre-login.webp')
        : CachedNetworkImageProvider(profile.coverUrl);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: isDesktop ? 200.r : 230.r,
          decoration: BoxDecoration(
            borderRadius: isDesktop ? BorderRadius.circular(20.r) : null,
            image: DecorationImage(
              image: coverImage,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: isDesktop ? BorderRadius.circular(20.r) : null,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
              ),
            ),
          ),
        ),
        if (!isDesktop)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.r,
            left: 16.r,
            right: 16.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassButton(icon: CupertinoIcons.back, onTap: () => Navigator.of(context).pop()),
                Row(
                  children: [
                    GlassButton(icon: Iconsax.share_copy, onTap: () {}),
                    SizedBox(width: 8.r),
                    Builder(
                      builder: (context) {
                        final fav = context.watch<FavoritesProvider>();
                        final isFav = fav.isDriverFav(profile.id);
                        return GlassButton(
                          icon: isFav ? Iconsax.heart : Iconsax.heart_copy,
                          onTap: () async {
                            final snap = provider.favSnapshot();
                            if (snap == null) return;
                            if (!await requireLogin(context)) return;
                            fav.toggleDriver(snap);
                          },
                          iconColor: isFav ? const Color(0xFFE91E63) : null,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        Positioned(
          left: 16.r,
          right: 16.r,
          bottom: -48.r,
          child: IdentityCard(profile: profile, isDark: isDark, cs: cs),
        ),
      ],
    );
  }
}
