import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Beautiful skeleton loading widget for the customer home screen.
class HomeSkeleton extends StatelessWidget {
  final bool isDesktop;

  const HomeSkeleton({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE8E8E8);

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0),
        highlightColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: isDesktop ? _buildDesktopSkeleton(baseColor) : _buildMobileSkeleton(baseColor),
    );
  }

  Widget _buildMobileSkeleton(Color baseColor) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 64.r),
          _buildBannerSkeleton(baseColor),
          SizedBox(height: 20.r),
          _buildServiceRowSkeleton(baseColor),
          SizedBox(height: 24.r),
          _buildSectionHeaderSkeleton(baseColor),
          SizedBox(height: 16.r),
          _buildBrandsSkeleton(baseColor),
          SizedBox(height: 24.r),
          _buildSectionHeaderSkeleton(baseColor),
          SizedBox(height: 16.r),
          _buildCarCardsSkeleton(baseColor),
          SizedBox(height: 24.r),
          _buildSectionHeaderSkeleton(baseColor),
          SizedBox(height: 16.r),
          _buildDriverCardsSkeleton(baseColor),
          SizedBox(height: 100.r),
        ],
      ),
    );
  }

  Widget _buildDesktopSkeleton(Color baseColor) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDesktopTopBarSkeleton(baseColor),
          SizedBox(height: 28.r),
          _buildBannerSkeleton(baseColor, isDesktop: true),
          SizedBox(height: 28.r),
          _buildServiceRowSkeleton(baseColor, isDesktop: true),
          SizedBox(height: 24.r),
          _buildSectionHeaderSkeleton(baseColor),
          SizedBox(height: 16.r),
          _buildBrandsSkeleton(baseColor, isDesktop: true),
          SizedBox(height: 24.r),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeaderSkeleton(baseColor),
                    SizedBox(height: 16.r),
                    _buildDesktopCarCardsSkeleton(baseColor),
                  ],
                ),
              ),
              SizedBox(width: 24.r),
              SizedBox(
                width: 280.r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeaderSkeleton(baseColor),
                    SizedBox(height: 16.r),
                    _buildDesktopDriverCardsSkeleton(baseColor),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40.r),
        ],
      ),
    );
  }

  Widget _buildBannerSkeleton(Color baseColor, {bool isDesktop = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.r),
      height: isDesktop ? 200.r : 210.r,
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(24.r)),
    );
  }

  Widget _buildServiceRowSkeleton(Color baseColor, {bool isDesktop = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.r),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 10.r : 0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 10.r),
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(18.r)),
                child: Column(
                  children: [
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    SizedBox(height: 10.r),
                    Container(
                      width: 60.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeaderSkeleton(Color baseColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      child: Row(
        children: [
          Container(
            width: 3.r,
            height: 18.r,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(width: 8.r),
          Container(
            width: 120.r,
            height: 16.r,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4.r)),
          ),
          const Spacer(),
          Container(
            width: 50.r,
            height: 14.r,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4.r)),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSkeleton(Color baseColor, {bool isDesktop = false}) {
    return SizedBox(
      height: 98.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.r),
        itemCount: 8,
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(right: 14.r),
            child: Column(
              children: [
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
                ),
                SizedBox(height: 6.r),
                Container(
                  width: 40.r,
                  height: 10.r,
                  decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4.r)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarCardsSkeleton(Color baseColor) {
    return SizedBox(
      height: 270.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        itemCount: 4,
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(right: 16.r),
            child: SizedBox(
              width: 220.r,
              child: _CarCardSkeleton(baseColor: baseColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopCarCardsSkeleton(Color baseColor) {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.r),
          child: _CarCardSkeleton(baseColor: baseColor, isHorizontal: true),
        );
      }),
    );
  }

  Widget _buildDriverCardsSkeleton(Color baseColor) {
    return SizedBox(
      height: 168.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        itemCount: 4,
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(right: 12.r),
            child: _DriverCardSkeleton(baseColor: baseColor),
          );
        },
      ),
    );
  }

  Widget _buildDesktopDriverCardsSkeleton(Color baseColor) {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.r),
          child: _DriverCardSkeleton(baseColor: baseColor, isHorizontal: true),
        );
      }),
    );
  }

  Widget _buildDesktopTopBarSkeleton(Color baseColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.r,
                height: 12.r,
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4.r)),
              ),
              SizedBox(height: 8.r),
              Container(
                width: 200.r,
                height: 20.r,
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4.r)),
              ),
            ],
          ),
        ),
        Container(
          width: 320.r,
          height: 52.r,
          decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16.r)),
        ),
      ],
    );
  }
}

class _CarCardSkeleton extends StatelessWidget {
  final Color baseColor;
  final bool isHorizontal;

  const _CarCardSkeleton({required this.baseColor, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12.r)),
            ),
            SizedBox(width: 16.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.r,
                    height: 16.r,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Container(
                    width: 80.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Container(
                    width: 60.r,
                    height: 16.r,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
          SizedBox(height: 12.r),
          Container(
            width: 120.r,
            height: 16.r,
            decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4.r)),
          ),
          SizedBox(height: 8.r),
          Container(
            width: 80.r,
            height: 12.r,
            decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4.r)),
          ),
          SizedBox(height: 12.r),
          Row(
            children: [
              Container(
                width: 60.r,
                height: 16.r,
                decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4.r)),
              ),
              const Spacer(),
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverCardSkeleton extends StatelessWidget {
  final Color baseColor;
  final bool isHorizontal;

  const _DriverCardSkeleton({required this.baseColor, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), shape: BoxShape.circle),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Container(
                    width: 60.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 140.r,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), shape: BoxShape.circle),
          ),
          SizedBox(height: 12.r),
          Container(
            width: 80.r,
            height: 14.r,
            decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4.r)),
          ),
          SizedBox(height: 8.r),
          Container(
            width: 50.r,
            height: 10.r,
            decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4.r)),
          ),
        ],
      ),
    );
  }
}
