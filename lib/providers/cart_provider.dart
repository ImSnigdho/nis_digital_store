import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;

  double totalPrice(String currency) {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice(currency));
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _cartService.getCartItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      await _cartService.addToCart(productId, quantity: quantity);
      await loadCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _cartService.updateQuantity(cartItemId, quantity);
      await loadCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      await loadCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

