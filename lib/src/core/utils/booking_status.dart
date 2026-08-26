import '../models/booking/booking.dart';

/// Canonical driver-facing booking buckets.
enum BookingBucket { pending, active, completed, cancelled }

/// Single source of truth for classifying a booking's status on the driver
/// side. Prefers the numeric `statusId` (5=pending, 6=approved,
/// 12=corporate_approved, 7=rejected, 8=completed, 15=cancelled — same mapping
/// the customer side uses in `bookingStatusFromApi`); falls back to string matching only
/// when the id is absent/unknown. Unknown statuses classify as [BookingBucket.active]
/// rather than pending, so they can never surface as accept/decline requests.
BookingBucket classifyBooking(Booking b) {
  switch (b.statusId) {
    case 5:
      return BookingBucket.pending;
    case 6:
    case 12:
      // Defensive: some backends stamp completedAt without moving the status
      // row — a finished trip must never linger in the active tab.
      return b.completedAt != null ? BookingBucket.completed : BookingBucket.active;
    case 7:
    case 15:
      return BookingBucket.cancelled;
    case 8:
      return BookingBucket.completed;
  }
  final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
  if (s.contains('reject') || s.contains('cancel')) return BookingBucket.cancelled;
  if (b.completedAt != null || s.contains('complete')) return BookingBucket.completed;
  if (s.contains('approved')) return BookingBucket.active; // incl. CorporateApproved
  if (s.contains('pending') || s.contains('new')) return BookingBucket.pending;
  // Unknown/blank status: treat as active (visible but not actionable) so a
  // lookup hiccup never re-offers an already-decided booking for approval.
  return BookingBucket.active;
}

bool isPendingBooking(Booking b) => classifyBooking(b) == BookingBucket.pending;
bool isCompletedBooking(Booking b) => classifyBooking(b) == BookingBucket.completed;
bool isCancelledBooking(Booking b) => classifyBooking(b) == BookingBucket.cancelled;
