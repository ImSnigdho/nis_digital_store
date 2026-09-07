import 'product.dart';

class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final DateTime? createdAt;
  Product? product; // Joined from products table

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
    this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
    };
  }
}

