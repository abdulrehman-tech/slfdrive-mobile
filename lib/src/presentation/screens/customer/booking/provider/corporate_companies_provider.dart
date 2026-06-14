import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/company/all_company.dart';

/// Loads the active corporate companies (`GET /api/AllCompanies/active`) for the
/// booking flow's corporate company picker.
class CorporateCompaniesProvider extends ChangeNotifier {
  CorporateCompaniesProvider({LookupRepository? repository})
      : _repository = repository ?? getIt<LookupRepository>();

  final LookupRepository _repository;

  List<AllCompany> _companies = const [];
  List<AllCompany> get companies => _companies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _loaded = false;

  /// Loads companies once (cached). Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (_loaded || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _companies = await _repository.getActiveCompanies();
      _loaded = true;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
