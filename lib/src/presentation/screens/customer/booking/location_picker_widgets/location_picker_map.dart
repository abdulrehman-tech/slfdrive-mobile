import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';

/// Google Map with centered pin semantics.
///
/// The map renders even without an API key — tiles may be blank but gestures
/// still work and camera-move events still fire.
class LocationPickerMap extends StatelessWidget {
  const LocationPickerMap({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LocationPickerProvider>();
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: provider.center, zoom: 14),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (c) {
        if (!provider.mapController.isCompleted) provider.mapController.complete(c);
      },
      onCameraMove: provider.onCameraMove,
      onCameraIdle: provider.resolveAddressFromCenter,
    );
  }
}
