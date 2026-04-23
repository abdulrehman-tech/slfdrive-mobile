import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/booking_data.dart';

/// State for the full-screen location picker.
///
/// Owns map camera position, selected address/label, and the loading flag used
/// while reverse-geocoding. Widgets consume this via `context.watch` / `select`.
class LocationPickerProvider extends ChangeNotifier {
  static const LatLng muscat = LatLng(23.5880, 58.3829);

  LocationPickerProvider({BookingLocation? initial, bool forDelivery = false}) {
    if (initial != null) {
      _center = LatLng(initial.latitude, initial.longitude);
      _address = initial.address;
      _label = initial.label ?? '';
    } else if (forDelivery) {
      _label = 'Delivery address';
    }
    addressController.text = _address;
    labelController.text = _label;
  }

  final Completer<GoogleMapController> mapController = Completer();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  LatLng _center = muscat;
  String _address = 'Muscat, Oman';
  String _label = '';
  bool _resolving = false;

  LatLng get center => _center;
  String get address => _address;
  String get label => _label;
  bool get resolving => _resolving;

  @override
  void dispose() {
    addressController.dispose();
    labelController.dispose();
    super.dispose();
  }

  void onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void onAddressChanged(String value) {
    _address = value;
  }

  Future<void> resolveAddressFromCenter() async {
    _resolving = true;
    notifyListeners();
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
          _address = resolved;
          addressController.text = resolved;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Reverse-geocoding failed: $e');
    } finally {
      _resolving = false;
      notifyListeners();
    }
  }

  Future<void> goToMyLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      _center = latLng;
      notifyListeners();
      final controller = await mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLng(latLng));
      await resolveAddressFromCenter();
    } catch (e) {
      if (kDebugMode) debugPrint('Geolocator failed: $e');
    }
  }

  BookingLocation buildResult() {
    final typedAddress = addressController.text.trim();
    final resolvedAddress = typedAddress.isNotEmpty ? typedAddress : _address;
    final typedLabel = labelController.text.trim();
    return BookingLocation(
      latitude: _center.latitude,
      longitude: _center.longitude,
      address: resolvedAddress,
      label: typedLabel.isEmpty ? null : typedLabel,
    );
  }
}
