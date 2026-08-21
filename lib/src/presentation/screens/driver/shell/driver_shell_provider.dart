import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../constants/storage_keys.dart';
import '../../../../core/data/repositories/booking_repository.dart';
import '../../../../core/data/repositories/driver_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/booking/booking.dart';
import '../../../../core/models/common/pagination_params.dart';
import '../../../../core/models/driver/driver_stats.dart';
import '../../../../core/services/customer_avatars.dart';
import '../../../../core/services/driver_session.dart';
import '../../../../core/services/place_namer.dart';
import '../earnings/models/earnings_period.dart';
import '../home/models/day_earning.dart';
import '../home/models/trip_request.dart';
import '../trips/models/driver_trip.dart';
import 'driver_shell_mappers.dart';

/// Single source of truth for the whole driver role — one load feeds home,
/// trips and earnings, and every action (accept / decline / complete / toggle
/// online) mutates this shared state so all tabs update together.
///
/// Registered as a get_it lazy singleton (a provider created inside a route
/// dies on every `context.go` tab switch); [reset] is called on logout /
/// account switch alongside `DriverSession.clear()`.
class DriverShellProvider extends ChangeNotifier {
  DriverShellProvider({
    BookingRepository? repository,
    DriverRepository? drivers,
    FlutterSecureStorage? storage,
    DriverSession? session,
    PlaceNamer? placeNamer,
    CustomerAvatars? avatars,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _drivers = drivers ?? getIt<DriverRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>(),
        _session = session ?? getIt<DriverSession>(),
        _placeNamer = placeNamer ?? getIt<PlaceNamer>(),
        _avatars = avatars ?? getIt<CustomerAvatars>();

  final BookingRepository _repository;
  final DriverRepository _drivers;
  final FlutterSecureStorage _storage;
  final DriverSession _session;
  final PlaceNamer _placeNamer;
  final CustomerAvatars _avatars;

  /// Data older than this triggers a silent background refresh when a driver
  /// screen comes (back) into view.
  static const staleAfter = Duration(seconds: 60);

  /// Bookings-per-page and the page-count safety cap for the paged fetch.
  static const _pageSize = 100;
  static const _maxPages = 10;

  // ---- load lifecycle -------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  /// True only during the very first load (before any data has arrived) —
  /// drives the full-screen shimmers. Refreshes never re-trigger it, so
  /// rendered data stays on screen while new data arrives.
  bool get isInitialLoading => _isLoading && !_hasLoaded;

  /// Load-path failure (drives full-screen error states, banners, and
  /// refresh-failure snackbars). May be a translation key or a server message —
  /// render through `.tr()`.
  String? _error;
  String? get error => _error;

  /// Last accept/decline/complete/toggle failure — transient, for snackbars
  /// only. Kept separate from [error] so a failed action can never blank a
  /// healthy screen into a full error state.
  String? _actionError;
  String? get actionError => _actionError;

  /// Whether any real data has arrived — used to decide between a full-screen
  /// error state (nothing to show) and a non-blocking snackbar/banner.
  bool get hasData => _stats != null || _allTrips.isNotEmpty || _requests.isNotEmpty;

  /// Invalidates slower in-flight loads: only the newest load may apply its
  /// results or flip loading flags.
  int _loadSeq = 0;
  Future<void>? _inFlight;

  /// Time of the last *attempt* (success or failure) — set in the load's
  /// finally so a failing backend can't turn every rebuild into a refetch.
  DateTime? _loadedAt;

  /// Bumped by [reset] so actions in flight across a logout can never mutate
  /// the fresh state afterwards.
  int _resetGen = 0;

  /// Bumped whenever the toggle adopts a server-confirmed online state, so a
  /// slower concurrent load can't stomp it with a pre-toggle snapshot.
  int _toggleGen = 0;

  // ---- identity -------------------------------------------------------------

  int? _userId;
  int? _driverId;

  // ---- data -----------------------------------------------------------------

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isTogglingOnline = false;
  bool get isTogglingOnline => _isTogglingOnline;

  DriverStats? _stats;

  double _todayEarnings = 0;
  int _totalTrips = 0;
  int _cancelledTrips = 0;

  double get todayEarnings => _todayEarnings;

  /// Completed trips — prefers the server aggregate, falls back to the count
  /// derived from the fetched bookings.
  int get totalTrips => _stats?.completedBookings ?? _totalTrips;

  /// Completion rate = completed / (completed + rejected), as a whole
  /// percentage. '—' until there's any finished trip to measure.
  String get completionLabel {
    final completed = _stats?.completedBookings ?? _totalTrips;
    final rejected = _stats?.rejectedBookings ?? _cancelledTrips;
    final finished = completed + rejected;
    if (finished == 0) return '—';
    return '${((completed / finished) * 100).round()}%';
  }

  /// Average driver rating from the server, e.g. `4.8`. '—' when unavailable.
  String get ratingLabel {
    final r = _stats?.averageRating;
    if (r == null) return '—';
    return r.toStringAsFixed(1);
  }

  List<DayEarning> _weekly = const [];
  List<DayEarning> get weekly => _weekly;

  List<TripRequest> _requests = const [];
  List<TripRequest> get requests => _requests;

  List<DriverTrip> _allTrips = const [];
  List<DriverTrip> get allTrips => _allTrips;

  List<({Booking booking, DateTime when})> _completedRows = const [];
  List<({Booking booking, DateTime when})> get completedRows => _completedRows;

  // ---- cross-navigation view state ------------------------------------------

  int _tripsTabIndex = 0; // 0=active, 1=completed, 2=cancelled
  int get tripsTabIndex => _tripsTabIndex;
  void setTripsTab(int index) {
    if (_tripsTabIndex == index) return;
    _tripsTabIndex = index;
    notifyListeners();
  }

  EarningsPeriod _earningsPeriod = EarningsPeriod.today;
  EarningsPeriod get earningsPeriod => _earningsPeriod;
  void setEarningsPeriod(EarningsPeriod period) {
    if (_earningsPeriod == period) return;
    _earningsPeriod = period;
    notifyListeners();
  }

  // ---- per-booking action state ---------------------------------------------

  final Set<int> _busyBookings = {};

  /// True while an accept/decline/complete call for this booking is in flight —
  /// drives the in-card spinners and blocks double taps.
  bool isBusy(int bookingId) => _busyBookings.contains(bookingId);

  // ---- loading --------------------------------------------------------------

  /// Idempotent entry point for the shell: kicks off the first load, dedupes
  /// concurrent callers onto the in-flight future, and silently refreshes when
  /// the last attempt is older than [staleAfter]. Rendered data is never
  /// blanked; a failed load is not retried until the cooldown passes (retry
  /// stays available via the error state's button and pull-to-refresh).
  Future<void> ensureLoaded() {
    final pending = _inFlight;
    if (pending != null) return pending;
    if (_hasLoaded) {
      final age = _loadedAt == null ? null : DateTime.now().difference(_loadedAt!);
      if (age != null && age < staleAfter) return Future.value();
    }
    return refresh();
  }

  /// Reloads the shared dataset. Plain calls (pull-to-refresh, retry) join an
  /// already-running load; [force] (used after mutations) instead chains a
  /// fresh load behind it, guaranteeing the result reflects the mutation even
  /// when a pre-action load was still in flight.
  Future<void> refresh({bool force = false}) {
    final pending = _inFlight;
    if (pending != null && !force) return pending;
    final gen = _resetGen;
    final next = pending == null
        ? _load()
        // Chained load must not run if the account was reset while waiting.
        : pending.then((_) => gen == _resetGen ? _load() : Future<void>.value());
    late final Future<void> tracked;
    tracked = next.whenComplete(() {
      // Only the owner may clear the slot — an orphaned load finishing late
      // must not free it while a newer load is running.
      if (identical(_inFlight, tracked)) _inFlight = null;
    });
    return _inFlight = tracked;
  }

  Future<void> _load() async {
    final seq = ++_loadSeq;
    // Captured at load start: any toggle committed after this point makes the
    // load's online snapshot stale, so it must not be applied.
    final toggleGen = _toggleGen;
    _isLoading = true;
    _error = null;
    // Yield before notifying: ensureLoaded() is invoked from build methods,
    // and notifying mid-build throws markNeedsBuild errors.
    await null;
    if (seq != _loadSeq) return;
    notifyListeners();
    try {
      _userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
      // One driver read gives both the driver-entity id (for bookings) and the
      // persisted online state; fall back to the session cache for the id.
      final details = _userId == null ? null : await _drivers.getById(_userId!);
      if (seq != _loadSeq) return;
      // Don't stomp an online state the driver just toggled (or is toggling)
      // with this load's pre-toggle server snapshot.
      if (details?.isOnline != null && toggleGen == _toggleGen && !_isTogglingOnline) {
        _isOnline = details!.isOnline!;
      }
      _driverId = details?.driverId ?? await _session.driverId();
      if (seq != _loadSeq) return;

      // Stats are best-effort — a failed aggregate must not wipe the rest.
      if (_userId != null) {
        try {
          _stats = await _drivers.getStats(_userId!);
        } catch (_) {}
        if (seq != _loadSeq) return;
      }

      if (_driverId == null) {
        // Surfaced as a real error instead of a silently empty dashboard.
        // Previously-rendered data (if any) is deliberately kept on screen.
        _error = 'driver_error_account';
        return;
      }

      // Page through the driver's bookings so stats/earnings aren't silently
      // truncated for busy drivers; _maxPages caps the worst case.
      final mine = <Booking>[];
      var page = 1;
      while (true) {
        final res = await _repository.driverPaginated(
          _driverId!,
          PaginationParams(pageNumber: page, pageSize: _pageSize),
        );
        if (seq != _loadSeq) return;
        mine.addAll(res.items);
        if (!res.hasMore || res.items.isEmpty || page >= _maxPages) break;
        page++;
      }

      // Render immediately with unenriched cards — the screen must go live
      // the moment the bookings API answers. Place names / avatars are filled
      // in afterwards; a slow or stalled platform geocoder can never hold the
      // skeleton (this exact hang was observed in the field).
      _applyBookings(seq, mine);
      unawaited(_enrich(seq, mine));
    } on AppException catch (e) {
      if (seq != _loadSeq) return;
      _error = e.message;
    } catch (e) {
      if (seq != _loadSeq) return;
      // Never surface raw exception dumps to the user.
      debugPrint('DriverShellProvider load failed: $e');
      _error = 'error_occurred';
    } finally {
      if (seq == _loadSeq) {
        _isLoading = false;
        _hasLoaded = true;
        _loadedAt = DateTime.now();
        notifyListeners();
      }
    }
  }

  /// Background enrichment pass: geocodes + avatars, then re-applies the same
  /// booking list with names filled in. Discarded if a newer load started.
  Future<void> _enrich(int seq, List<Booking> bookings) async {
    if (bookings.isEmpty) return;
    try {
      final enrichment = await enrichBookings(bookings, _placeNamer, _avatars);
      if (seq != _loadSeq) return;
      _applyBookings(seq, bookings, enrichment: enrichment);
      notifyListeners();
    } catch (e) {
      debugPrint('DriverShellProvider enrichment failed: $e');
    }
  }

  void _applyBookings(
    int seq,
    List<Booking> bookings, {
    Map<int, BookingEnrichment> enrichment = const {},
  }) {
    if (seq != _loadSeq) return;
    final derived = deriveBookingStats(bookings);
    _todayEarnings = derived.todayEarnings;
    _totalTrips = derived.completed;
    _cancelledTrips = derived.cancelled;
    _weekly = List.unmodifiable(buildWeekly(bookings));
    _requests = List.unmodifiable(buildTripRequests(bookings, enrichment));
    _allTrips = List.unmodifiable(buildDriverTrips(bookings, enrichment));
    _completedRows = List.unmodifiable(buildCompletedRows(bookings));
  }

  // ---- actions --------------------------------------------------------------

  /// Flips availability via `POST /api/Driver/toggle-online/{userId}` and
  /// adopts the server's returned state. On failure the toggle is left
  /// unchanged and [actionError] carries the message.
  Future<void> toggleOnline() async {
    if (_isTogglingOnline) return;
    if (_userId == null) {
      _actionError = 'driver_error_account';
      notifyListeners();
      return;
    }
    final gen = _resetGen;
    _isTogglingOnline = true;
    _actionError = null;
    notifyListeners();
    try {
      final online = await _drivers.toggleOnline(_userId!);
      if (gen != _resetGen) return; // logged out mid-toggle — discard
      _isOnline = online;
      _toggleGen++;
    } on AppException catch (e) {
      if (gen != _resetGen) return;
      _actionError = e.message;
    } catch (e) {
      if (gen != _resetGen) return;
      debugPrint('DriverShellProvider toggleOnline failed: $e');
      _actionError = 'driver_toggle_failed';
    } finally {
      if (gen == _resetGen) {
        _isTogglingOnline = false;
        notifyListeners();
      }
    }
  }

  /// Driver accepts a request (`POST /api/Booking/approve`).
  Future<bool> accept(int bookingId) =>
      _act(bookingId, (uid) => _repository.approve(id: bookingId, confirmedBy: uid));

  /// Driver declines a request (`POST /api/Booking/reject`).
  Future<bool> decline(int bookingId) =>
      _act(bookingId, (uid) => _repository.reject(id: bookingId, confirmedBy: uid));

  /// Marks an active trip complete (`POST /api/Booking/{id}/complete`).
  Future<bool> complete(int bookingId) =>
      _act(bookingId, (_) => _repository.complete(bookingId));

  /// Runs a booking action with per-booking busy state (blocks double taps),
  /// then force-refreshes the shared dataset so every tab reflects the change
  /// even if an older load was already in flight. Returns true on success; on
  /// failure [actionError] holds the server message.
  Future<bool> _act(int bookingId, Future<bool> Function(int userId) action) async {
    if (_busyBookings.contains(bookingId)) return false;
    final uid = _userId;
    if (uid == null) {
      _actionError = 'driver_error_account';
      notifyListeners();
      return false;
    }
    final gen = _resetGen;
    _busyBookings.add(bookingId);
    _actionError = null;
    notifyListeners();
    try {
      await action(uid);
      if (gen != _resetGen) return false; // logged out mid-action
      await refresh(force: true);
      return true;
    } on AppException catch (e) {
      if (gen != _resetGen) return false;
      _actionError = e.message;
      return false;
    } catch (e) {
      if (gen != _resetGen) return false;
      debugPrint('DriverShellProvider action failed: $e');
      _actionError = 'error_occurred';
      return false;
    } finally {
      if (gen == _resetGen) {
        _busyBookings.remove(bookingId);
        notifyListeners();
      }
    }
  }

  // ---- lifecycle ------------------------------------------------------------

  /// Clears all state back to construction defaults. Called on logout /
  /// account switch; also orphans any in-flight load or action.
  void reset() {
    _loadSeq++; // orphan any in-flight load
    _resetGen++; // orphan any in-flight action/toggle
    _inFlight = null;
    _isLoading = false;
    _hasLoaded = false;
    _error = null;
    _actionError = null;
    _loadedAt = null;
    _userId = null;
    _driverId = null;
    _isOnline = false;
    _isTogglingOnline = false;
    _stats = null;
    _todayEarnings = 0;
    _totalTrips = 0;
    _cancelledTrips = 0;
    _weekly = const [];
    _requests = const [];
    _allTrips = const [];
    _completedRows = const [];
    _busyBookings.clear();
    _tripsTabIndex = 0;
    _earningsPeriod = EarningsPeriod.today;
    notifyListeners();
  }
}
