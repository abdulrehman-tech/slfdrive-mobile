/// Result of `POST /api/PromoCode/validate` (`PromoCodeValidateResponseDto`).
class PromoValidation {
  final bool isValid;
  final int? promoCodeId;
  final String? code;
  final String? name;

  /// `Percentage` or `Fixed`.
  final String? discountType;
  final double discountValue;

  /// Discount computed against the amount sent (0 when no amount was sent).
  final double discountAmount;
  final double netAmount;

  const PromoValidation({
    required this.isValid,
    this.promoCodeId,
    this.code,
    this.name,
    this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.netAmount,
  });

  bool get isPercentage => (discountType ?? '').toLowerCase().startsWith('percent');

  factory PromoValidation.fromJson(Map<String, dynamic> json) => PromoValidation(
        isValid: json['isValid'] == true,
        promoCodeId: (json['promoCodeId'] as num?)?.toInt(),
        code: json['code'] as String?,
        name: json['name'] as String?,
        discountType: json['discountType'] as String?,
        discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
        netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
      );
}

/// An active promo code (`PromoCodeResponseDto`), shown as an offer chip.
class PromoOffer {
  final int id;
  final String code;
  final String name;
  final String? description;

  /// Null when the code applies to every company.
  final int? companyId;
  final String discountType;
  final double discountValue;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;

  const PromoOffer({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.companyId,
    required this.discountType,
    required this.discountValue,
    this.effectiveFrom,
    this.effectiveTo,
    this.isActive = true,
  });

  bool get isPercentage => discountType.toLowerCase().startsWith('percent');

  /// Usable now for a booking with [companyId]: active, inside its window, and
  /// either all-company or owned by that company.
  bool appliesTo(int? companyId, DateTime now) {
    if (!isActive) return false;
    if (effectiveFrom != null && now.isBefore(effectiveFrom!)) return false;
    if (effectiveTo != null && now.isAfter(effectiveTo!)) return false;
    return this.companyId == null || this.companyId == companyId;
  }

  factory PromoOffer.fromJson(Map<String, dynamic> json) => PromoOffer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: (json['code'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        description: json['description'] as String?,
        companyId: (json['companyId'] as num?)?.toInt(),
        discountType: (json['discountType'] as String?) ?? '',
        discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
        effectiveFrom: DateTime.tryParse('${json['effectiveFrom']}')?.toLocal(),
        effectiveTo: DateTime.tryParse('${json['effectiveTo']}')?.toLocal(),
        isActive: json['isActive'] != false,
      );
}
