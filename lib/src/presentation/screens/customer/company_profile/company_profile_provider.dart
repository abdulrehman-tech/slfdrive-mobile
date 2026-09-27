import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/company_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/company/company_profile.dart';
import '../../../../core/services/review_aggregates.dart';

enum CompanyTab { vehicles, drivers, reviews }

/// Loads one rental company's profile and holds the selected content tab.
class CompanyProfileProvider extends ChangeNotifier {
  CompanyProfileProvider({required this.companyId, CompanyRepository? repository})
      : _repository = repository ?? getIt<CompanyRepository>() {
    load();
  }

  final int companyId;
  final CompanyRepository _repository;
  final ReviewAggregates ratings = getIt<ReviewAggregates>();

  CompanyProfile? _profile;
  bool _loading = true;
  String? _error;
  CompanyTab _tab = CompanyTab.vehicles;

  CompanyProfile? get profile => _profile;
  bool get isLoading => _loading;
  String? get error => _error;
  CompanyTab get tab => _tab;

  Future<void> load() async {
    _loading = _profile == null;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.profile(companyId);
      // Per-card vehicle/driver ratings come from the shared review cache.
      await ratings.ensureLoaded();
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'company_load_failed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setTab(CompanyTab t) {
    if (_tab == t) return;
    _tab = t;
    notifyListeners();
  }
}
