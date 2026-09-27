import '../../models/promo/promo_code.dart';
import '../datasources/promo_code_remote_data_source.dart';

abstract class PromoCodeRepository {
  Future<PromoValidation> validate({required String code, int? companyId, double? amount});
  Future<List<PromoOffer>> active();
}

class PromoCodeRepositoryImpl implements PromoCodeRepository {
  final PromoCodeRemoteDataSource remote;

  PromoCodeRepositoryImpl(this.remote);

  @override
  Future<PromoValidation> validate({required String code, int? companyId, double? amount}) =>
      remote.validate(code: code.trim().toUpperCase(), companyId: companyId, amount: amount);

  @override
  Future<List<PromoOffer>> active() => remote.active();
}
