import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/skeletons/list_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/models/vehicle/vehicle.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/auth_gate.dart';
import '../booking/models/booking_data.dart';
import 'provider/car_detail_provider.dart';
import 'widgets/booking_bar.dart';
import 'widgets/car_info_header.dart';
import 'widgets/car_sliver_app_bar.dart';
import 'widgets/description_section.dart';
import 'widgets/desktop_book_button.dart';
import 'widgets/features_section.dart';
import 'widgets/image_gallery.dart';
import 'widgets/location_section.dart';
import 'widgets/owner_section.dart';
import 'widgets/plate_section.dart';
import 'widgets/specs_section.dart';

// ============================================================
// CAR DETAIL SCREEN
// ============================================================

class CarDetailScreen extends StatelessWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final vehicleId = int.tryParse(carId) ?? 0;
    final ar = context.locale.languageCode == 'ar';
    return ChangeNotifierProvider(
      create: (_) => CarDetailProvider(
        vehicleRepository: getIt<VehicleRepository>(),
        vehicleId: vehicleId,
        ar: ar,
      ),
      child: const _CarDetailView(),
    );
  }
}

class _CarDetailView extends StatelessWidget {
  const _CarDetailView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> _launchBookingFlow(BuildContext context, Vehicle vehicle) async {
    if (!await requireLogin(context)) return;
    if (!context.mounted) return;
    final car = BookingCar(
      id: vehicle.id.toString(),
      name: vehicle.displayTitle(ar: context.read<CarDetailProvider>().ar),
      brand: (context.read<CarDetailProvider>().ar ? vehicle.brandNameAr : vehicle.brandName) ?? vehicle.brandName ?? '',
      imageUrl: vehicle.primaryPhoto ?? '',
      pricePerDay: vehicle.pricePerDay ?? 0,
      plateNumber: vehicle.plateNumber ?? '',
      plateCode: '',
      lat: vehicle.lat,
      lon: vehicle.lon,
      locationName: context.read<CarDetailProvider>().ar
          ? (vehicle.locationNameAr ?? vehicle.locationName)
          : vehicle.locationName,
      branchId: vehicle.branchId,
    );
    context.pushNamed('booking', extra: {'service': BookingServiceType.rentCar, 'car': car});
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<CarDetailProvider>();

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const ListSkeleton(itemCount: 4, itemHeight: 170),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _ErrorRetry(
          message: provider.error!,
          cs: cs,
          onRetry: provider.load,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop
          ? _buildDesktop(context, isDark, cs, provider.vehicle!)
          : _buildMobile(context, isDark, cs, provider.vehicle!),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs, Vehicle vehicle) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CarSliverAppBar(isDark: isDark, cs: cs),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0), child: CarInfoHeader(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: PlateSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: SpecsSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: FeaturesSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: DescriptionSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: OwnerSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: LocationSection(isDark: isDark, cs: cs)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BookingBar(
            isDark: isDark,
            cs: cs,
            onBook: () => _launchBookingFlow(context, vehicle),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs, Vehicle vehicle) {
    final provider = context.watch<CarDetailProvider>();
    final title = vehicle.displayTitle(ar: provider.ar);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                    SizedBox(width: 10.r),
                    Text(
                      title,
                      style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        ImageGallery(isDark: isDark, cs: cs, isDesktop: true),
                        SizedBox(height: 20.r),
                        DescriptionSection(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        OwnerSection(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        LocationSection(isDark: isDark, cs: cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        CarInfoHeader(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        PlateSection(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        SpecsSection(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        FeaturesSection(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        DesktopBookButton(onTap: () => _launchBookingFlow(context, vehicle)),
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
}

/// Centered error message with a retry button.
class _ErrorRetry extends StatelessWidget {
  final String message;
  final ColorScheme cs;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.cs, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.exclamationmark_circle, size: 40.r, color: cs.primary.withValues(alpha: 0.6)),
            SizedBox(height: 12.r),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            SizedBox(height: 16.r),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: Text('common_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
