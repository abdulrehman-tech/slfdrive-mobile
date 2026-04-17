import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';
import 'models/booking_data.dart';

/// Full-screen Google Maps picker.
///
/// Set a Google Maps API key in the Android manifest / iOS AppDelegate for the
/// map tiles to render. If no key is set, the UI still works — a search/manual
/// address field lets the user type the location and the selected coordinate
/// is the map center (default Muscat).
class LocationPickerScreen extends StatefulWidget {
  final BookingLocation? initial;
  final bool forDelivery;

  const LocationPickerScreen({super.key, this.initial, this.forDelivery = false});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _muscat = LatLng(23.5880, 58.3829);

  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _center = _muscat;
  String _address = 'Muscat, Oman';
  String _label = '';
  bool _resolving = false;
  final _addressController = TextEditingController();
  final _labelController = TextEditingController();

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _center = LatLng(widget.initial!.latitude, widget.initial!.longitude);
      _address = widget.initial!.address;
      _label = widget.initial!.label ?? '';
    } else if (widget.forDelivery) {
      _label = 'Delivery address';
    }
    _addressController.text = _address;
    _labelController.text = _label;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddressFromCenter() async {
    setState(() => _resolving = true);
    try {
      final placemarks = await placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if ((p.street ?? '').isNotEmpty) p.street,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
          if ((p.locality ?? '').isNotEmpty) p.locality,
          if ((p.country ?? '').isNotEmpty) p.country,
        ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();
        final resolved = parts.join(', ');
        if (resolved.isNotEmpty) {
          setState(() {
            _address = resolved;
            _addressController.text = resolved;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Reverse-geocoding failed: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = latLng);
      final controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLng(latLng));
      await _resolveAddressFromCenter();
    } catch (e) {
      if (kDebugMode) debugPrint('Geolocator failed: $e');
    }
  }

  void _confirm() {
    final address = _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : _address;
    final label = _labelController.text.trim();
    Navigator.of(context).pop(
      BookingLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: address,
        label: label.isEmpty ? null : label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _buildMap(),
        // Center pin
        IgnorePointer(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.r),
              child: Icon(Iconsax.location_copy, size: 38.r, color: cs.primary),
            ),
          ),
        ),
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  _glassCircle(icon: CupertinoIcons.back, isDark: isDark, onTap: () => Navigator.of(context).pop()),
                  SizedBox(width: 10.r),
                  Expanded(child: _buildAddressSearch(cs, isDark)),
                ],
              ),
            ),
          ),
        ),
        // FAB: my location
        Positioned(
          bottom: 200.r,
          right: 16.r,
          child: _glassCircle(icon: Iconsax.gps_copy, isDark: isDark, color: cs.primary, onTap: _goToMyLocation),
        ),
        // Bottom sheet
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomSheet(cs, isDark)),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Side panel
        Container(
          width: 360.r,
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111118) : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Text(
                    widget.forDelivery ? 'booking_delivery_where'.tr() : 'booking_pickup_point'.tr(),
                    style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 18.r),
              _buildAddressSearch(cs, isDark),
              SizedBox(height: 12.r),
              _buildLabelField(cs, isDark),
              SizedBox(height: 18.r),
              _buildSelectedAddressBlock(cs, isDark),
              const Spacer(),
              _buildConfirmButton(),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildMap(),
              IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.r),
                    child: Icon(Iconsax.location_copy, size: 44.r, color: cs.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 24.r,
                right: 24.r,
                child: _glassCircle(icon: Iconsax.gps_copy, isDark: isDark, color: cs.primary, onTap: _goToMyLocation),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================

  Widget _buildMap() {
    // GoogleMap widget renders even without API key — tiles will be blank but
    // gestures still work and we still get LatLng updates from camera moves.
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _center, zoom: 14),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (c) {
        if (!_mapController.isCompleted) _mapController.complete(c);
      },
      onCameraMove: (pos) {
        _center = pos.target;
      },
      onCameraIdle: () {
        _resolveAddressFromCenter();
      },
    );
  }

  Widget _buildAddressSearch(ColorScheme cs, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 14.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.primary),
              SizedBox(width: 10.r),
              Expanded(
                child: TextField(
                  controller: _addressController,
                  onChanged: (v) => _address = v,
                  style: TextStyle(fontSize: 13.r, color: cs.onSurface),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'booking_location_search_hint'.tr(),
                    hintStyle: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.4)),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.r),
                  ),
                ),
              ),
              if (_resolving)
                SizedBox(width: 14.r, height: 14.r, child: const CircularProgressIndicator(strokeWidth: 1.8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelField(ColorScheme cs, bool isDark) {
    return TextField(
      controller: _labelController,
      style: TextStyle(fontSize: 13.r, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: 'booking_location_label'.tr(),
        labelStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.55)),
        hintText: 'booking_location_label_hint'.tr(),
        hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.35)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
      ),
    );
  }

  Widget _buildSelectedAddressBlock(ColorScheme cs, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.location_copy, color: cs.primary, size: 16.r),
              SizedBox(width: 6.r),
              Text(
                'booking_location_selected'.tr(),
                style: TextStyle(fontSize: 11.r, color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Text(
            _address,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface, fontWeight: FontWeight.w600, height: 1.4),
          ),
          SizedBox(height: 6.r),
          Text(
            '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45), fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(ColorScheme cs, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(28.r), topRight: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 16.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F18).withValues(alpha: 0.96) : Colors.white.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.r),
              _buildSelectedAddressBlock(cs, isDark),
              SizedBox(height: 12.r),
              _buildLabelField(cs, isDark),
              SizedBox(height: 14.r),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _confirm,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.r),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0C2485).withValues(alpha: 0.3), blurRadius: 16.r, offset: Offset(0, 6.r)),
          ],
        ),
        child: Center(
          child: Text(
            'booking_location_confirm'.tr(),
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _glassCircle({required IconData icon, required bool isDark, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                  blurRadius: 10.r,
                  offset: Offset(0, 3.r),
                ),
              ],
            ),
            child: Icon(icon, size: 19.r, color: color ?? (isDark ? Colors.white : Colors.black87)),
          ),
        ),
      ),
    );
  }
}
