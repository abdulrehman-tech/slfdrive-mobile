import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/models/booking/booking.dart';
import 'package:slfdrive/src/core/utils/booking_status.dart';

Booking b({int? statusId, String? status, String? statusType, String? completedAt}) =>
    Booking(id: 1, statusId: statusId, status: status, statusType: statusType, completedAt: completedAt);

void main() {
  group('classifyBooking — statusId first', () {
    test('5 = pending', () => expect(classifyBooking(b(statusId: 5)), BookingBucket.pending));
    test('6 = active', () => expect(classifyBooking(b(statusId: 6)), BookingBucket.active));
    test('12 (corporate approved) = active',
        () => expect(classifyBooking(b(statusId: 12)), BookingBucket.active));
    test('7 = cancelled', () => expect(classifyBooking(b(statusId: 7)), BookingBucket.cancelled));
    test('15 (customer/admin cancelled) = cancelled',
        () => expect(classifyBooking(b(statusId: 15)), BookingBucket.cancelled));
    test('8 = completed', () => expect(classifyBooking(b(statusId: 8)), BookingBucket.completed));

    test('statusId beats contradictory strings', () {
      expect(classifyBooking(b(statusId: 8, status: 'Pending')), BookingBucket.completed);
      expect(classifyBooking(b(statusId: 5, status: 'Approved')), BookingBucket.pending);
    });
  });

  group('classifyBooking — string fallback (no/unknown statusId)', () {
    test('rejected/cancelled strings', () {
      expect(classifyBooking(b(status: 'Rejected')), BookingBucket.cancelled);
      expect(classifyBooking(b(statusType: 'Cancelled')), BookingBucket.cancelled);
    });
    test('completedAt implies completed',
        () => expect(classifyBooking(b(completedAt: '2026-08-01T10:00:00')), BookingBucket.completed));
    test('approved strings are active', () {
      expect(classifyBooking(b(status: 'Approved')), BookingBucket.active);
      expect(classifyBooking(b(status: 'CorporateApproved')), BookingBucket.active);
    });
    test('pending strings', () {
      expect(classifyBooking(b(status: 'Pending')), BookingBucket.pending);
      expect(classifyBooking(b(status: 'New')), BookingBucket.pending);
    });

    test('blank/unknown status is NOT pending (regression: was offered for approval)', () {
      // The old matcher classified any string without "approved" as pending,
      // re-offering already-decided bookings as accept/decline requests.
      expect(classifyBooking(b()), isNot(BookingBucket.pending));
      expect(classifyBooking(b(status: '  ')), isNot(BookingBucket.pending));
      expect(classifyBooking(b(status: 'OnHold')), isNot(BookingBucket.pending));
    });
  });
}
