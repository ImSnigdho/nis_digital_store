import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promo_code.dart';

class PromoValidationResult {
  final bool valid;
  final String? reason;
  final double discountAmount;
  final String? promoId;

  PromoValidationResult({
    required this.valid,
    this.reason,
    this.discountAmount = 0,
    this.promoId,
  });

  factory PromoValidationResult.fromJson(Map<String, dynamic> json) {
    return PromoValidationResult(
      valid: json['valid'] ?? false,
      reason: json['reason'],
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      promoId: json['promo_id'],
    );
  }
}

class PromoCodeService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PromoValidationResult> validatePromoCode(String code, String currency, double subtotal) async {
    try {
      final response = await _client.rpc('validate_promo_code', params: {
        'p_code': code,
        'p_order_currency': currency,
        'p_subtotal': subtotal,
      });

      return PromoValidationResult.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return PromoValidationResult(
        valid: false,
        reason: 'Error validating promo code: $e',
      );
    }
  }

  Future<List<PromoCode>> getAllPromoCodes() async {
    final response = await _client
        .from('promo_codes')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => PromoCode.fromJson(json)).toList();
  }

  Future<PromoCode> createPromoCode({
    required String code,
    required String discountType,
    double? percentageValue,
    double? fixedAmount,
    String? fixedCurrency,
    double minOrderAmount = 0,
    int? usageLimit,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    final response = await _client.from('promo_codes').insert({
      'code': code.toUpperCase().trim(),
      'discount_type': discountType,
      'percentage_value': percentageValue,
      'fixed_amount': fixedAmount,
      'fixed_currency': fixedCurrency,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'times_used': 0,
    }).select().single();

    return PromoCode.fromJson(response);
  }

  Future<void> updatePromoCode({
    required String id,
    required String code,
    required String discountType,
    double? percentageValue,
    double? fixedAmount,
    String? fixedCurrency,
    double minOrderAmount = 0,
    int? usageLimit,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    await _client.from('promo_codes').update({
      'code': code.toUpperCase().trim(),
      'discount_type': discountType,
      'percentage_value': percentageValue,
      'fixed_amount': fixedAmount,
      'fixed_currency': fixedCurrency,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
    }).eq('id', id);
  }

  Future<void> deletePromoCode(String id) async {
    await _client.from('promo_codes').delete().eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client.from('promo_codes').update({'is_active': isActive}).eq('id', id);
  }
}
