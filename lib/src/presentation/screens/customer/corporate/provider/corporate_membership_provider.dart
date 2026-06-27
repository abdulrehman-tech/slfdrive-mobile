import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/corporate_membership_repository.dart';
import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/company/all_company.dart';
import '../../../../../core/models/corporate/corporate_membership.dart';

/// Loads the signed-in user's corporate memberships and exposes whether they
/// can make a corporate booking (gate) plus which companies are eligible.
class CorporateMembershipProvider extends ChangeNotifier {
  CorporateMembershipProvider({
    CorporateMembershipRepository? repository,
    FlutterSecureStorage? storage,
    LookupRepository? lookup,
  })  : _repository = repository ?? getIt<CorporateMembershipRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>(),
        _lookup = lookup ?? getIt<LookupRepository>() {
    load();
  }

  final CorporateMembershipRepository _repository;
  final FlutterSecureStorage _storage;
  final LookupRepository _lookup;

  /// Active corporate companies keyed by id, used to attach a real logo (and
  /// address) to a membership — the membership DTO carries neither.
  Map<int, AllCompany> _companiesById = const {};

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  List<CorporateMembership> _memberships = const [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  List<CorporateMembership> get memberships => List.unmodifiable(_memberships);

  /// Memberships that can back a corporate booking (approved + active).
  List<CorporateMembership> get approvedMemberships =>
      _memberships.where((m) => m.isApprovedActive).toList();

  /// Gate for the corporate booking toggle.
  bool get hasApprovedMembership => approvedMemberships.isNotEmpty;

  /// The full company (with logo) for a membership's `allCompanyId`, when the
  /// active-companies list resolved; null otherwise.
  AllCompany? companyFor(int allCompanyId) => _companiesById[allCompanyId];

  /// Resolved logo URL for a membership's company, or null when unavailable.
  String? logoUrlFor(int allCompanyId) => _companiesById[allCompanyId]?.resolvedLogoUrl;

  /// Approved companies for the booking picker — the real [AllCompany] (with
  /// logo) when resolvable, else a lightweight one built from the membership.
  List<AllCompany> get approvedCompanies => approvedMemberships
      .map((m) =>
          _companiesById[m.allCompanyId] ??
          AllCompany(
            id: m.allCompanyId,
            name: m.companyName,
            nameAr: m.companyNameAr,
            companyType: 'Corporate',
          ))
      .toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
      if (userId == null) {
        _memberships = const [];
      } else {
        _memberships = await _repository.byUser(userId);
        await _loadCompanies();
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  /// Best-effort fetch of active corporate companies to attach logos. A failure
  /// here is non-fatal — memberships still render, just without a logo.
  Future<void> _loadCompanies() async {
    try {
      final companies = await _lookup.getActiveCompanies();
      _companiesById = {for (final c in companies) c.id: c};
    } catch (_) {
      // keep whatever we had; logos simply won't show
    }
  }

  /// Loads once; subsequent calls are no-ops while already loaded.
  Future<void> ensureLoaded() async {
    if (_hasLoaded || _isLoading) return;
    await load();
  }

  /// Submits a membership application and refreshes the list. Returns true on
  /// success; on failure sets [error] and returns false.
  Future<bool> apply(CorporateMembershipRequest request) async {
    try {
      await _repository.apply(request);
      await load();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
