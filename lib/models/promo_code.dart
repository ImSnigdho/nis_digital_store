class PromoCode {
  final String id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double? percentageValue;
  final double? fixedAmount;
  final String? fixedCurrency; // 'BDT' or 'USD'
  final double minOrderAmount;
  final int? usageLimit;
  final int timesUsed;
  final DateTime? expiresAt;
  final bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    this.percentageValue,
    this.fixedAmount,
    this.fixedCurrency,
    this.minOrderAmount = 0,
    this.usageLimit,
    this.timesUsed = 0,
    this.expiresAt,
    this.isActive = true,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'],
      code: json['code'],
      discountType: json['discount_type'],
      percentageValue: (json['percentage_value'] as num?)?.toDouble(),
      fixedAmount: (json['fixed_amount'] as num?)?.toDouble(),
      fixedCurrency: json['fixed_currency'],
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount_type': discountType,
      'percentage_value': percentageValue,
      'fixed_amount': fixedAmount,
      'fixed_currency': fixedCurrency,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
