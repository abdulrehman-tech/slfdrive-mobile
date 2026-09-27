import 'package:flutter/foundation.dart';

import '../data/repositories/company_repository.dart';
import '../models/company/company_profile.dart';

/// Company names and logos by id, from one `GET /api/AllCompanies/active`.
///
/// Vehicle, driver and booking DTOs carry only the owning company's id and
/// name, so every company avatar outside the profile page looks its logo up
/// here. Loaded once on first use; a failed load retries on the next use.
class CompanyDirectory extends ChangeNotifier {
  CompanyDirectory(this._companies);

  final CompanyRepository _companies;
  final Map<int, CompanyInfo> _byId = {};
  Future<void>? _inFlight;
  bool _loaded = false;

  CompanyInfo? find(int? id) => id == null ? null : _byId[id];

  /// Absolute logo URL for [companyId], or null when unknown / no logo.
  String? logoFor(int? companyId) => find(companyId)?.resolvedLogoUrl;

  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<void> _load() async {
    try {
      final all = await _companies.active();
      for (final c in all) {
        _byId[c.id] = c;
      }
      _loaded = true;
      notifyListeners();
    } catch (_) {
      // Logos are decorative — avatars keep their letter fallback.
    }
  }

  /// Keeps the directory in step with a freshly loaded profile (its logo may
  /// be newer than the cached list).
  void remember(CompanyInfo company) {
    final old = _byId[company.id];
    _byId[company.id] = company;
    if (old?.logoUrl != company.logoUrl) notifyListeners();
  }
}
