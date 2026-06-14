import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/services/places_service.dart';
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
  final PlacesService _places = PlacesService();

  LatLng _center = muscat;
  String _address = 'Muscat, Oman';
  String _label = '';
  bool _resolving = false;

  // Places autocomplete state.
  List<PlacePrediction> _predictions = const [];
  bool _searching = false;
  Timer? _debounce;

  LatLng get center => _center;
  String get address => _address;
  String get label => _label;
  bool get resolving => _resolving;
  List<PlacePrediction> get predictions => _predictions;
  bool get searching => _searching;

  @override
  void dispose() {
    _debounce?.cancel();
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

  /// Called as the user types in the search bar: keeps the typed text and
  /// debounces a Places autocomplete request (350ms).
  void onSearchChanged(String value) {
    _address = value;
    _debounce?.cancel();
    if (value.trim().length < 2) {
      if (_predictions.isNotEmpty) {
        _predictions = const [];
        notifyListeners();
      }
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _runAutocomplete(value));
  }

  Future<void> _runAutocomplete(String query) async {
    _searching = true;
    notifyListeners();
    final results = await _places.autocomplete(query);
    _predictions = results;
    _searching = false;
    notifyListeners();
  }

  void clearPredictions() {
    if (_predictions.isEmpty) return;
    _predictions = const [];
    notifyListeners();
  }

  /// Resolves a tapped suggestion to coordinates, moves the map there, and sets
  /// the address. Falls back silently if details can't be fetched.
  Future<void> selectPrediction(PlacePrediction prediction) async {
    _predictions = const [];
    _searching = true;
    notifyListeners();
    final details = await _places.details(prediction.placeId);
    _searching = false;
    if (details == null) {
      // Keep the typed label as the address; leave the map where it is.
      _address = prediction.fullText;
      addressController.text = prediction.fullText;
      notifyListeners();
      return;
    }
    _center = LatLng(details.lat, details.lon);
    _address = details.address.isNotEmpty ? details.address : prediction.fullText;
    addressController.text = _address;
    notifyListeners();
    try {
      final controller = await mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(_center, 15));
    } catch (e) {
      if (kDebugMode) debugPrint('Camera move failed: $e');
    }
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
