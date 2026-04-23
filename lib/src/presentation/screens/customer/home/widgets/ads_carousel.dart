import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';

class AdsCarousel extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const AdsCarousel({super.key, this.isDesktop = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final ads = home.ads;
    final height = isDesktop ? 180.r : 140.r;
    final hPad = isDesktop ? 0.0 : 16.r;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, isDesktop ? 4.r : 12.r, 0, 4.r),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: home.adsController,
              physics: const BouncingScrollPhysics(),
              itemCount: ads.length,
              onPageChanged: home.onAdsPageChanged,
              itemBuilder: (_, i) {
                final ad = ads[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.r).copyWith(
                    left: i == 0 ? hPad : 6.r,
                    right: i == ads.length - 1 ? hPad : 6.r,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: ad.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: ad.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: ad.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          Container(color: Colors.black.withValues(alpha: 0.35)),
                          Positioned(
                            left: 20.r,
                            right: 20.r,
                            bottom: 18.r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ad.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isDesktop ? 22.r : 18.r,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                                SizedBox(height: 4.r),
                                Text(
                                  ad.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: isDesktop ? 14.r : 12.r,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.r),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(ads.length, (i) {
              final active = i == home.adsPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                margin: EdgeInsets.symmetric(horizontal: 3.r),
                width: active ? 20.r : 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: active
                      ? (isDark ? Colors.white : const Color(0xFF0C2485))
                      : (isDark ? Colors.white24 : Colors.black26),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
