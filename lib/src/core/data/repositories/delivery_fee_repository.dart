import '../../models/delivery/delivery_fee.dart';
import '../datasources/delivery_fee_remote_data_source.dart';

/// Delivery-fee reads, plus a helper to resolve the fee for a (company, area).
abstract class DeliveryFeeRepository {
  Future<List<DeliveryFee>> byCompany(int companyId);
  Future<List<DeliveryFee>> byArea(int locationId);

  /// Resolves the active delivery fee for [companyId] delivering to
  /// [locationId], or null when the company has no fee configured for that area.
  Future<double?> resolveFee({required int companyId, required int locationId});
}

class DeliveryFeeRepositoryImpl implements DeliveryFeeRepository {
  final DeliveryFeeRemoteDataSource remote;

  DeliveryFeeRepositoryImpl(this.remote);

  @override
  Future<List<DeliveryFee>> byCompany(int companyId) => remote.byCompany(companyId);

  @override
  Future<List<DeliveryFee>> byArea(int locationId) => remote.byArea(locationId);

  @override
  Future<double?> resolveFee({required int companyId, required int locationId}) async {
    final fees = await remote.byCompany(companyId);
    for (final f in fees) {
      if (f.locationId == locationId && f.isActive) return f.fee;
    }
    return null;
  }
}
