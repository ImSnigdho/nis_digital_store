import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';

class CartService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<CartItem>> getCartItems() async {
    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at');

    return (response as List)
        .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    // Check if item already in cart
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', _userId)
        .eq('product_id', productId);

    if ((existing as List).isNotEmpty) {
      // Update quantity
      final currentQty = existing.first['quantity'] as int;
      await _client
          .from('cart_items')
          .update({'quantity': currentQty + quantity})
          .eq('id', existing.first['id']);
    } else {
      // Insert new
      await _client.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart() async {
    await _client.from('cart_items').delete().eq('user_id', _userId);
  }

  Future<int> getCartCount() async {
    final response = await _client
        .from('cart_items')
        .select('id')
        .eq('user_id', _userId);
    return (response as List).length;
  }
}
