import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  List<Order> _allOrders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Order> get allOrders => _allOrders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allOrders = await _orderService.getAllOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await loadAllOrders();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder({
    required List<CartItem> cartItems,
    required String currency,
    required String paymentMethodId,
    required String paymentRef,
    required Map<String, dynamic> shippingAddress,
    String? promoCodeId,
    double discountAmount = 0,
    String? paymentMethodName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderService.placeOrder(
        cartItems: cartItems,
        currency: currency,
        paymentMethodId: paymentMethodId,
        paymentRef: paymentRef,
        shippingAddress: shippingAddress,
        promoCodeId: promoCodeId,
        discountAmount: discountAmount,
        paymentMethodName: paymentMethodName,
      );
      await loadOrders();
      _isLoading = false;
      notifyListeners();
      return _currentOrder;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

