import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/injection_container.dart';
import '../../core/services/place_namer.dart';

/// A single point rendered on a [LocationMapPreview].
class MapPoint {
  final double lat;
  final double lon;

  /// Optional leading label for the point's row (already localized), e.g.
  /// "Pickup at". Null → just the resolved place name is shown.
  final String? label;

  /// Marker + row accent colour.
  final Color color;

  /// Google marker hue matching [color] (use `BitmapDescriptor.hue*`).
  final double markerHue;

  const MapPoint({
    required this.lat,
    required this.lon,
    this.label,
    this.color = const Color(0xFFE91E63),
    this.markerHue = BitmapDescriptor.hueRose,
  });

  LatLng get latLng => LatLng(lat, lon);
}

/// Reusable location card body: a non-interactive Google map with a marker per
/// point, tappable to open the spot in the device's maps app, plus a
/// reverse-geocoded place-name row per point (never raw coordinates).
///
/// Used by the booking-detail and vehicle-detail location cards so both look
/// and behave identically.
class LocationMapPreview extends StatefulWidget {
  final List<MapPoint> points;
  final bool isDark;
  final ColorScheme cs;
  final double height;

  const LocationMapPreview({
    super.key,
    required this.points,
    required this.isDark,
    required this.cs,
    this.height = 160,
  });

  @override
  State<LocationMapPreview> createState() => _LocationMapPreviewState();
}

class _LocationMapPreviewState extends State<LocationMapPreview> {
  late List<String> _names;

  @override
  void initState() {
    super.initState();
    _names = List<String>.filled(widget.points.length, '');
    _resolveNames();
  }

  @override
  void didUpdateWidget(LocationMapPreview old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) {
      _names = List<String>.filled(widget.points.length, '');
      _resolveNames();
    }
  }

  Future<void> _resolveNames() async {
    final namer = getIt<PlaceNamer>();
    for (var i = 0; i < widget.points.length; i++) {
      final p = widget.points[i];
      final name = await namer.describe(p.lat, p.lon);
      if (!mounted) return;
      setState(() => _names[i] = name);
    }
  }

  /// Opens the point in the platform maps app (falls back to a web maps URL).
  Future<void> _openInMaps(MapPoint p) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lon}',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('LocationMapPreview: failed to open $uri: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final points = widget.points;
    final markers = <Marker>{
      for (var i = 0; i < points.length; i++)
        Marker(
          markerId: MarkerId('p$i'),
          position: points[i].latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(points[i].markerHue),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: SizedBox(
            height: widget.height.r,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: points.first.latLng, zoom: 14),
                  markers: markers,
                  liteModeEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
                // Lite-mode maps swallow taps, so overlay a transparent button
                // that opens the primary point in the maps app.
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: () => _openInMaps(points.first)),
                  ),
                ),
                Positioned(
                  right: 10.r,
                  top: 10.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 5.r),
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.export_3_copy, size: 12.r, color: cs.primary),
                        SizedBox(width: 4.r),
                        Text(
                          'location_open_maps'.tr(),
                          style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < points.length; i++) ...[
          SizedBox(height: 10.r),
          _pointRow(cs, points[i], _names[i]),
        ],
      ],
    );
  }

  Widget _pointRow(ColorScheme cs, MapPoint p, String name) {
    // While the name resolves, show a subtle placeholder rather than coords.
    final resolved = name.isNotEmpty ? name : 'location_resolving'.tr();
    return InkWell(
      onTap: () => _openInMaps(p),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Iconsax.location_copy, size: 15.r, color: p.color),
            SizedBox(width: 8.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.label != null && p.label!.isNotEmpty)
                    Text(
                      p.label!,
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  Text(
                    resolved,
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
