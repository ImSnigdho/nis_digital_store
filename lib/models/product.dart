class Product {
  final String id;
  final String name;
  final String? description;
  final double priceBdt;
  final double priceUsd;
  final List<String> images;
  final String? categoryId;
  final String? brand;
  final int stock;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.priceBdt,
    required this.priceUsd,
    this.images = const [],
    this.categoryId,
    this.brand,
    this.stock = 0,
    this.isFeatured = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  double getPrice(String currency) {
    return currency == 'BDT' ? priceBdt : priceUsd;
  }

  String get primaryImage {
    return images.isNotEmpty
        ? images.first
        : 'https://via.placeholder.com/400x400?text=No+Image';
  }

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceBdt: (json['price_bdt'] as num).toDouble(),
      priceUsd: (json['price_usd'] as num).toDouble(),
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      categoryId: json['category_id'] as String?,
      brand: json['brand'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_bdt': priceBdt,
      'price_usd': priceUsd,
      'images': images,
      'category_id': categoryId,
      'brand': brand,
      'stock': stock,
      'is_featured': isFeatured,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
    };
  }
}
