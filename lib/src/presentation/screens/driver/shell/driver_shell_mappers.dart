import '../../../../constants/date_label_keys.dart';
import '../../../../core/models/booking/booking.dart';
import '../../../../core/services/customer_avatars.dart';
import '../../../../core/services/place_namer.dart';
import '../../../../core/utils/booking_status.dart';
import '../home/models/day_earning.dart';
import '../home/models/trip_request.dart';
import '../trips/models/driver_trip.dart';

/// Pure derivation helpers for [DriverShellProvider]. Everything here is
/// side-effect free (except [enrichBookings], which fans out network lookups)
/// so it can be unit-tested without a widget tree.

/// Per-booking display enrichment: resolved place names + customer avatar.
typedef BookingEnrichment = ({String pickup, String dropoff, String? avatar});

/// Resolves place names and avatars for every booking **in parallel** (one
/// `Future.wait` per booking, all bookings concurrently). Returns a map keyed
/// by booking id, shared by the request cards and the trip cards so each
/// booking is geocoded exactly once per load.
Future<Map<int, BookingEnrichment>> enrichBookings(
  List<Booking> bookings,
  PlaceNamer placeNamer,
  CustomerAvatars avatars,
) async {
  final entries = await Future.wait(bookings.map((b) async {
    final results = await Future.wait<String?>([
      placeNamer.describe(b.pickupLat, b.pickupLon),
      placeNamer.describe(b.dropoffLat, b.dropoffLon),
      avatars.photoUrl(b.userId),
    ]);
    return MapEntry(b.id, (
      pickup: results[0] ?? '',
      dropoff: results[1] ?? '',
      avatar: results[2],
    ));
  }));
  return Map.fromEntries(entries);
}

DateTime? completionDay(Booking b) =>
    DateTime.tryParse(b.completedAt ?? b.toDateTime ?? b.fromDateTime ?? '')?.toLocal();

/// Rolling 7-day revenue series (oldest → today) for the home earnings card.
List<DayEarning> buildWeekly(List<Booking> bookings) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final buckets = List<double>.filled(7, 0);
  for (final b in bookings) {
    if (!isCompletedBooking(b)) continue;
    final when = completionDay(b);
    if (when == null) continue;
    final day = DateTime(when.year, when.month, when.day);
    final offset = today.difference(day).inDays; // 0 = today
    if (offset < 0 || offset > 6) continue;
    buckets[6 - offset] += b.totalAmount ?? 0;
  }
  return List.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    return DayEarning(
      labelKey: DateLabelKeys.dow[day.weekday - 1],
      amount: buckets[i],
      isToday: i == 6,
    );
  });
}

/// Booking-derived fallbacks for the home headline stats (used when the
/// server aggregate isn't available).
({double todayEarnings, int completed, int cancelled}) deriveBookingStats(
  List<Booking> bookings,
) {
  final now = DateTime.now();
  var earnings = 0.0;
  var completed = 0;
  var cancelled = 0;
  for (final b in bookings) {
    switch (classifyBooking(b)) {
      case BookingBucket.completed:
        completed++;
        final when = completionDay(b);
        if (when != null &&
            when.year == now.year && when.month == now.month && when.day == now.day) {
          earnings += b.totalAmount ?? 0;
        }
      case BookingBucket.cancelled:
        cancelled++;
      case BookingBucket.pending:
      case BookingBucket.active:
        break;
    }
  }
  return (todayEarnings: earnings, completed: completed, cancelled: cancelled);
}

/// Pending bookings → accept/decline request cards.
List<TripRequest> buildTripRequests(
  List<Booking> bookings,
  Map<int, BookingEnrichment> enrichment,
) {
  return bookings.where(isPendingBooking).map((b) {
    final e = enrichment[b.id];
    return TripRequest.fromBooking(
      b,
      pickup: e?.pickup ?? '',
      dropoff: e?.dropoff ?? '',
      avatarUrl: e?.avatar,
    );
  }).toList();
}

/// All non-pending bookings → trip cards for the trips tab.
List<DriverTrip> buildDriverTrips(
  List<Booking> bookings,
  Map<int, BookingEnrichment> enrichment,
) {
  final built = <DriverTrip>[];
  for (final b in bookings) {
    final e = enrichment[b.id];
    final t = DriverTrip.fromBooking(
      b,
      pickupName: e?.pickup,
      dropoffName: e?.dropoff,
      avatarUrl: e?.avatar,
    );
    if (t != null) built.add(t);
  }
  return built;
}

/// Completed bookings paired with their completion timestamps, newest first —
/// the earnings tab's base dataset. Rows with no resolvable timestamp are
/// dropped so earnings and the home card bucket by the same rule (previously
/// they defaulted to "now", inflating today's earnings tab only).
List<({Booking booking, DateTime when})> buildCompletedRows(List<Booking> bookings) {
  final rows = <({Booking booking, DateTime when})>[];
  for (final b in bookings.where(isCompletedBooking)) {
    final when = completionDay(b);
    if (when != null) rows.add((booking: b, when: when));
  }
  rows.sort((a, b) => b.when.compareTo(a.when));
  return rows;
}
