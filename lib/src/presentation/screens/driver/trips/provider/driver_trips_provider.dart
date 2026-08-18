import 'package:flutter/foundation.dart';

import '../../../../../core/utils/safe_notifier.dart';
import '../../shell/driver_shell_provider.dart';
import '../models/driver_trip.dart';

/// Thin view-model over [DriverShellProvider] for the trips tab. Holds no data
/// of its own — trips, loading/error state and the selected tab all live in
/// the shared shell so they survive navigation and stay in sync with actions
/// taken on any driver screen.
class DriverTripsProvider extends ChangeNotifier with SafeNotifier {
  DriverTripsProvider(this._shell) {
    _shell.addListener(safeNotify);
  }

  final DriverShellProvider _shell;

  static const tabKeys = [
    'trips_active',
    'trips_completed',
    'trips_cancelled',
  ];

  static const statusMap = [
    DriverTripStatus.active,
    DriverTripStatus.completed,
    DriverTripStatus.cancelled,
  ];

  static const emptyTitles = [
    'trips_no_active',
    'trips_no_completed',
    'trips_no_cancelled',
  ];

  static const emptySubs = [
    'trips_no_active_desc',
    'trips_no_completed_desc',
    'trips_no_cancelled_desc',
  ];

  bool get isLoading => _shell.isLoading;
  bool get isInitialLoading => _shell.isInitialLoading;
  String? get error => _shell.error;
  String? get actionError => _shell.actionError;

  int get tabIndex => _shell.tripsTabIndex;
  void setTab(int index) => _shell.setTripsTab(index);

  List<DriverTrip> get trips => _shell.allTrips;

  List<DriverTrip> get filteredTrips =>
      trips.where((t) => t.status == statusMap[tabIndex]).toList();

  int countForTab(int index) =>
      trips.where((t) => t.status == statusMap[index]).length;

  bool isBusy(int bookingId) => _shell.isBusy(bookingId);

  Future<void> load() => _shell.refresh();

  /// Marks an active trip complete; the shell refresh moves it across tabs on
  /// every driver screen at once. On failure [error] holds the message.
  Future<bool> completeTrip(int bookingId) => _shell.complete(bookingId);

  @override
  void dispose() {
    _shell.removeListener(safeNotify);
    super.dispose();
  }
}
