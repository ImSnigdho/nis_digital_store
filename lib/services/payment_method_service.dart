import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_method.dart';

class PaymentMethodService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PaymentMethod>> getActivePaymentMethods() async {
    final response = await _client
        .from('payment_methods')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<List<PaymentMethod>> getAllPaymentMethods() async {
    final response = await _client
        .from('payment_methods')
        .select()
        .order('sort_order', ascending: true);

    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<PaymentMethod> createPaymentMethod({
    required String name,
    required String accountNumber,
    String? iconUrl,
    String? instructions,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    final response = await _client.from('payment_methods').insert({
      'name': name,
      'account_number': accountNumber,
      'icon_url': iconUrl,
      'instructions': instructions,
      'is_active': isActive,
      'sort_order': sortOrder,
    }).select().single();

    return PaymentMethod.fromJson(response);
  }

  Future<void> updatePaymentMethod({
    required String id,
    required String name,
    required String accountNumber,
    String? iconUrl,
    String? instructions,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    await _client.from('payment_methods').update({
      'name': name,
      'account_number': accountNumber,
      'icon_url': iconUrl,
      'instructions': instructions,
      'is_active': isActive,
      'sort_order': sortOrder,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deletePaymentMethod(String id) async {
    await _client.from('payment_methods').delete().eq('id', id);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client.from('payment_methods').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<String> uploadIcon(String fileName, Uint8List bytes) async {
    final path = 'icons/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('payment-icons').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
    );
    return _client.storage.from('payment-icons').getPublicUrl(path);
  }
}
