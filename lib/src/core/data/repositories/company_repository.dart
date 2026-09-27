import '../../models/company/company_profile.dart';
import '../datasources/company_remote_data_source.dart';

abstract class CompanyRepository {
  Future<CompanyProfile> profile(int companyId);
  Future<List<CompanyInfo>> active();
}

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remote;

  CompanyRepositoryImpl(this.remote);

  @override
  Future<CompanyProfile> profile(int companyId) => remote.profile(companyId);

  @override
  Future<List<CompanyInfo>> active() => remote.active();
}
