import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<WishlistItem>> getWishlistItems() async {
    final response = await _client
        .from('wishlist_items')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishlistItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToWishlist(String productId) async {
    // Check if already in wishlist
    final existing = await _client
        .from('wishlist_items')
        .select()
        .eq('user_id', _userId)
        .eq('product_id', productId);

    if ((existing as List).isEmpty) {
      await _client.from('wishlist_items').insert({
        'user_id': _userId,
        'product_id': productId,
      });
    }
  }

  Future<void> removeFromWishlist(String wishlistItemId) async {
    await _client.from('wishlist_items').delete().eq('id', wishlistItemId);
  }

  Future<void> removeByProductId(String productId) async {
    await _client
        .from('wishlist_items')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', productId);
  }

  Future<bool> isInWishlist(String productId) async {
    final response = await _client
        .from('wishlist_items')
        .select('id')
        .eq('user_id', _userId)
        .eq('product_id', productId);
    return (response as List).isNotEmpty;
  }

  Future<int> getWishlistCount() async {
    final response = await _client
        .from('wishlist_items')
        .select('id')
        .eq('user_id', _userId);
    return (response as List).length;
  }
}
