import 'package:intl/intl.dart';

import '../../../constants/endpoints.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_handler.dart';
import '../../models/promo/promo_code.dart';
import '../../network/api_client.dart';

/// Customer-facing promo code calls (`/api/PromoCode/*`).
abstract class PromoCodeRemoteDataSource {
  /// Validates [code] for a booking with [companyId] (the rental company).
  /// Throws [AppException] with the server's (localised) reason when invalid.
  Future<PromoValidation> validate({required String code, int? companyId, double? amount});

  /// Active promo codes (`GET /api/PromoCode/active`); empty when the caller
  /// may not list them.
  Future<List<PromoOffer>> active();
}

class PromoCodeRemoteDataSourceImpl implements PromoCodeRemoteDataSource {
  final ApiClient apiClient;

  PromoCodeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PromoValidation> validate({required String code, int? companyId, double? amount}) async {
    try {
      final res = await apiClient.post(ApiEndpoints.promoCodeValidate, data: {
        'code': code,
        'companyId': ?companyId,
        'amount': ?amount,
      });
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (body['isSuccess'] == true && data is Map<String, dynamic>) {
        final v = PromoValidation.fromJson(data);
        if (v.isValid) return v;
      }
      throw AppException(message: localizedMessage(body) ?? 'promo_invalid');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<PromoOffer>> active() async {
    try {
      final res = await apiClient.get(ApiEndpoints.promoCodeActive);
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is List) {
        return (body['data'] as List).whereType<Map<String, dynamic>>().map(PromoOffer.fromJson).toList();
      }
      return const [];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

/// The server's `messageAr` when the app runs in Arabic, else `message`, else
/// the first validation error.
String? localizedMessage(Map<String, dynamic> body) {
  final ar = Intl.getCurrentLocale().startsWith('ar');
  for (final key in [if (ar) 'messageAr', 'message']) {
    final m = body[key];
    if (m is String && m.trim().isNotEmpty) return m;
  }
  final errors = body['errors'];
  if (errors is List && errors.isNotEmpty) return errors.first.toString();
  return null;
}
