import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Order>> getOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Order>> getAllOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', orderId);
  }

  Future<Order> getOrderById(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return Order.fromJson(response);
  }

  Future<Order> placeOrder({
    required List<CartItem> cartItems,
    required String currency,
    required String paymentMethodId,
    required String paymentRef,
    required Map<String, dynamic> shippingAddress,
    String? promoCodeId,
    double discountAmount = 0,
    String? paymentMethodName,
    String? reference,
  }) async {
    double totalBdt = 0;
    double totalUsd = 0;

    for (final item in cartItems) {
      if (item.product != null) {
        final unitBdt = item.product!.salePriceBdt ?? item.product!.priceBdt;
        final unitUsd = item.product!.salePriceUsd ?? item.product!.priceUsd;
        totalBdt += unitBdt * item.quantity;
        totalUsd += unitUsd * item.quantity;
      }
    }

    // Apply discount
    totalBdt = (totalBdt - discountAmount).clamp(0, double.infinity);

    // Create the order with all customer fields denormalized for admin visibility
    // Fetch the customer's discord_username from their profile
    String? discordUsername;
    try {
      final profileRes = await _client
          .from('profiles')
          .select('discord_username')
          .eq('id', _userId)
          .maybeSingle();
      discordUsername = profileRes?['discord_username'] as String?;
    } catch (_) {
      // Ignore – discord is optional
    }

    final orderResponse = await _client
        .from('orders')
        .insert({
          'user_id': _userId,
          'status': 'pending',
          'total_bdt': totalBdt,
          'total_usd': totalUsd,
          'currency': currency,
          'payment_method_id': paymentMethodId,
          'payment_method': paymentMethodName, // human-readable for admin
          'payment_ref': paymentRef,
          'shipping_address': shippingAddress,
          // Denormalized for easy admin querying
          'customer_name': shippingAddress['name'],
          'delivery_email': shippingAddress['email'],
          'phone': shippingAddress['phone'],
          'reference': (reference != null && reference.trim().isNotEmpty)
              ? reference.trim()
              : null,
          'discord_username': discordUsername,
          'promo_code_id': promoCodeId,
          'discount_amount': discountAmount,
        })
        .select()
        .single();

    final orderId = orderResponse['id'] as String;

    // Create order items
    final orderItems = cartItems
        .where((item) => item.product != null)
        .map((item) => {
              'order_id': orderId,
              'product_id': item.productId,
              'product_name': item.product!.name,
              'quantity': item.quantity,
              'price_bdt': item.product!.salePriceBdt ?? item.product!.priceBdt,
              'price_usd': item.product!.salePriceUsd ?? item.product!.priceUsd,
            })
        .toList();

    await _client.from('order_items').insert(orderItems);

    // Clear the cart
    await _client.from('cart_items').delete().eq('user_id', _userId);

    return getOrderById(orderId);
  }
}
