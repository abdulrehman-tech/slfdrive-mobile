import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/models/booking/booking.dart';
import 'package:slfdrive/src/core/models/booking/booking_creation_request.dart';
import 'package:slfdrive/src/core/models/booking/booking_quote.dart';
import 'package:slfdrive/src/core/models/company/company_profile.dart';
import 'package:slfdrive/src/core/models/promo/promo_code.dart';
import 'package:slfdrive/src/core/models/vehicle/vehicle_brand.dart';
import 'package:slfdrive/src/presentation/screens/customer/booking_detail/models/booking_detail.dart';

void main() {
  group('promo', () {
    final now = DateTime(2026, 9, 27);
    PromoOffer offer({int? companyId, bool active = true, DateTime? to}) => PromoOffer(
          id: 1,
          code: 'SAVE10',
          name: 'Save',
          companyId: companyId,
          discountType: 'Percentage',
          discountValue: 10,
          effectiveTo: to,
          isActive: active,
        );

    test('all-company codes apply everywhere; company codes only to that company', () {
      expect(offer().appliesTo(7, now), isTrue);
      expect(offer(companyId: 7).appliesTo(7, now), isTrue);
      expect(offer(companyId: 7).appliesTo(8, now), isFalse);
      expect(offer(active: false).appliesTo(7, now), isFalse);
      expect(offer(to: DateTime(2026, 9, 1)).appliesTo(7, now), isFalse);
    });

    test('request sends the typed code; quote exposes the server discount', () {
      const r = BookingCreationRequest(userId: 1, bookingTypeId: 14, serviceTypeId: 10, promoCode: 'SAVE10');
      expect(r.toJson()['promoCode'], 'SAVE10');
      expect(const BookingCreationRequest(userId: 1, bookingTypeId: 14, serviceTypeId: 10).toJson().containsKey('promoCode'), isFalse);

      final q = BookingQuote.fromJson({
        'days': 2, 'rentalAmount': 30, 'grossAmount': 30, 'rentalCompanyId': 11,
        'promoCode': 'SAVE10', 'promoCodeId': 3, 'discountType': 'Percentage', 'discountValue': 10,
        'discountAmount': 3, 'totalAmount': 27,
      });
      expect(q.hasPromo, isTrue);
      expect(q.rentalCompanyId, 11);
      expect(q.totalAmount, 27);
    });

    test('booking detail keeps the delivery residual right when discounted', () {
      // gross 30 vehicle + 5 delivery, 3 off → total 32 (net).
      final b = Booking.fromJson({
        'id': 1, 'vehicleAmount': 30, 'totalAmount': 32, 'discountAmount': 3, 'promoCode': 'SAVE10',
        'fromDateTime': '2026-09-29T10:00:00Z', 'toDateTime': '2026-10-01T10:00:00Z',
      });
      final d = BookingDetail.fromBooking(b);
      expect(d.deliveryFee, 5);
      expect(d.discountAmount, 3);
      expect(d.promoCode, 'SAVE10');
    });
  });

  test('company profile parses and hides inactive vehicles / reviews', () {
    final p = CompanyProfile.fromJson({
      'company': {'id': 11, 'name': 'Speed car ', 'nameAr': 'السيارة السريعة', 'logoUrl': 'logos/speed.png', 'website': ''},
      'stats': {'averageRating': 4.5, 'totalReviews': 2, 'completedBookings': 9, 'totalEarnings': 999},
      'vehicles': [
        {'id': 1, 'isActive': true},
        {'id': 2, 'isActive': false},
      ],
      'drivers': [{'id': 5}],
      'recentReviews': [
        {'id': 1, 'rating': 5, 'isActive': true},
        {'id': 2, 'rating': 1, 'isActive': false},
      ],
    });
    expect(p.company.displayName(), 'Speed car');
    expect(p.company.displayName(ar: true), 'السيارة السريعة');
    expect(p.company.website, isNull);
    expect(p.company.resolvedLogoUrl, endsWith('/api/logos/speed.png'));
    expect(p.vehicles.map((v) => v.id), [1]);
    expect(p.recentReviews.length, 1);
    expect(p.stats.completedBookings, 9);
  });

  test('brand logo resolves against the media host; missing logo stays null', () {
    expect(VehicleBrand.fromJson({'id': 1, 'name': 'Toyota', 'logoUrl': 'brands/t.png'}).resolvedLogoUrl, endsWith('/api/brands/t.png'));
    expect(VehicleBrand.fromJson({'id': 1, 'name': 'Toyota', 'logoUrl': null}).resolvedLogoUrl, isNull);
  });
}
