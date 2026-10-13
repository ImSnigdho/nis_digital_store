class Order {
  final String id;
  final String userId;
  final String status;
  final double totalBdt;
  final double totalUsd;
  final String currency;
  final String? paymentMethod;
  final String? paymentRef;
  final Map<String, dynamic>? shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<OrderItem> items;

  // Top-level denormalized fields (stored as separate columns in DB)
  final String? _rawCustomerName;
  final String? _rawDeliveryEmail;
  final String? _rawPhone;
  final String? _rawDiscordUsername;

  Order({
    required this.id,
    required this.userId,
    this.status = 'pending',
    this.totalBdt = 0,
    this.totalUsd = 0,
    this.currency = 'BDT',
    this.paymentMethod,
    this.paymentRef,
    this.shippingAddress,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    String? customerName,
    String? deliveryEmail,
    String? phone,
    String? discordUsername,
  })  : _rawCustomerName = customerName,
        _rawDeliveryEmail = deliveryEmail,
        _rawPhone = phone,
        _rawDiscordUsername = discordUsername;

  double getTotal(String currency) {
    return currency == 'BDT' ? totalBdt : totalUsd;
  }

  /// Falls back to shipping_address fields if top-level columns are null
  String? get deliveryEmail =>
      _rawDeliveryEmail ?? shippingAddress?['email'] as String?;

  String? get customerName =>
      _rawCustomerName ?? shippingAddress?['name'] as String?;

  String? get customerPhone =>
      _rawPhone ?? shippingAddress?['phone'] as String?;

  String? get discordUsername =>
      _rawDiscordUsername ??
      shippingAddress?['discord'] as String? ??
      shippingAddress?['discord_username'] as String?;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'pending',
      totalBdt: (json['total_bdt'] as num?)?.toDouble() ?? 0,
      totalUsd: (json['total_usd'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'BDT',
      paymentMethod: json['payment_method'] as String?,
      paymentRef: json['payment_ref'] as String?,
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      customerName: json['customer_name'] as String?,
      deliveryEmail: json['delivery_email'] as String?,
      phone: json['phone'] as String?,
      discordUsername: json['discord_username'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((item) =>
                  OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status,
      'total_bdt': totalBdt,
      'total_usd': totalUsd,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_ref': paymentRef,
      'shipping_address': shippingAddress,
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final int quantity;
  final double priceBdt;
  final double priceUsd;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.quantity = 1,
    this.priceBdt = 0,
    this.priceUsd = 0,
  });

  double getPrice(String currency) {
    return currency == 'BDT' ? priceBdt : priceUsd;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceBdt: (json['price_bdt'] as num?)?.toDouble() ?? 0,
      priceUsd: (json['price_usd'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price_bdt': priceBdt,
      'price_usd': priceUsd,
    };
  }
}
