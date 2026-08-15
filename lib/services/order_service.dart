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
    required String paymentMethod,
    required String paymentRef,
    required Map<String, dynamic> shippingAddress,
  }) async {
    double totalBdt = 0;
    double totalUsd = 0;

    for (final item in cartItems) {
      if (item.product != null) {
        totalBdt += item.product!.priceBdt * item.quantity;
        totalUsd += item.product!.priceUsd * item.quantity;
      }
    }

    // Create the order
    final orderResponse = await _client
        .from('orders')
        .insert({
          'user_id': _userId,
          'status': 'pending',
          'total_bdt': totalBdt,
          'total_usd': totalUsd,
          'currency': currency,
          'payment_method': paymentMethod,
          'payment_ref': paymentRef,
          'shipping_address': shippingAddress,
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
              'price_bdt': item.product!.priceBdt,
              'price_usd': item.product!.priceUsd,
            })
        .toList();

    await _client.from('order_items').insert(orderItems);

    // Clear the cart
    await _client.from('cart_items').delete().eq('user_id', _userId);

    return getOrderById(orderId);
  }
}
