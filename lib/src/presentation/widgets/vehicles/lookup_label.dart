import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/common/general_lookup.dart';

/// Display name for a vehicle lookup value (car type, transmission, fuel).
/// The backend's `nameAr` is English for these rows, so known values come
/// from `lookup_<name>` translation keys; anything else shows the raw name.
String lookupLabel(String? name, {String? nameAr, bool ar = false}) {
  final raw = (name ?? '').trim();
  final key = 'lookup_${raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  if (raw.isNotEmpty && key.trExists()) return key.tr();
  final shown = ((ar ? nameAr : null) ?? raw).trim();
  if (shown.isEmpty) return '';
  return shown[0].toUpperCase() + shown.substring(1);
}

String generalLookupLabel(GeneralLookup t, {bool ar = false}) => lookupLabel(t.name, nameAr: t.nameAr, ar: ar);
