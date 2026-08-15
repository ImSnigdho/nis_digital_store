import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';
import '../models/wishlist_item.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _error;
  final Set<String> _wishlistedProductIds = {};

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;

  bool isWishlisted(String productId) {
    return _wishlistedProductIds.contains(productId);
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _wishlistService.getWishlistItems();
      _wishlistedProductIds.clear();
      for (final item in _items) {
        _wishlistedProductIds.add(item.productId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      if (isWishlisted(productId)) {
        await _wishlistService.removeByProductId(productId);
        _wishlistedProductIds.remove(productId);
      } else {
        await _wishlistService.addToWishlist(productId);
        _wishlistedProductIds.add(productId);
      }
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      await _wishlistService.removeFromWishlist(wishlistItemId);
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
