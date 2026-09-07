class Product {
  final String id;
  final String name;
  final String? shortDescription;
  final String? description;
  final double priceBdt;
  final double priceUsd;
  final double? salePriceBdt;
  final double? salePriceUsd;
  final List<String> images;
  final String? categoryId;
  final String? brand;
  final String status; // 'active', 'draft', 'inactive'
  final bool isFeatured;
  final String? thumbnailUrl;
  final String? fileUrl;
  final int downloadsCount;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.shortDescription,
    this.description,
    required this.priceBdt,
    required this.priceUsd,
    this.salePriceBdt,
    this.salePriceUsd,
    this.images = const [],
    this.categoryId,
    this.brand,
    this.status = 'active',
    this.isFeatured = false,
    this.thumbnailUrl,
    this.fileUrl,
    this.downloadsCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  double getPrice(String currency) {
    return currency == 'BDT' ? priceBdt : priceUsd;
  }

  double? getSalePrice(String currency) {
    return currency == 'BDT' ? salePriceBdt : salePriceUsd;
  }

  bool get hasSalePrice => salePriceBdt != null && salePriceBdt! > 0;

  String get primaryImage {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl!;
    return images.isNotEmpty
        ? images.first
        : 'https://via.placeholder.com/400x400?text=No+Image';
  }

  // Keep backward compat
  int get stock => 0;
  bool get inStock => true; // Digital products always in stock

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      priceBdt: (json['price_bdt'] as num).toDouble(),
      priceUsd: (json['price_usd'] as num).toDouble(),
      salePriceBdt: (json['sale_price_bdt'] as num?)?.toDouble(),
      salePriceUsd: (json['sale_price_usd'] as num?)?.toDouble(),
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      categoryId: json['category_id'] as String?,
      brand: json['brand'] as String?,
      status: json['status'] as String? ?? 'active',
      isFeatured: json['is_featured'] as bool? ?? false,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileUrl: json['file_url'] as String?,
      downloadsCount: (json['downloads_count'] as num?)?.toInt() ?? 0,
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
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'price_bdt': priceBdt,
      'price_usd': priceUsd,
      'sale_price_bdt': salePriceBdt,
      'sale_price_usd': salePriceUsd,
      'images': images,
      'category_id': categoryId,
      'brand': brand,
      'status': status,
      'is_featured': isFeatured,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'downloads_count': downloadsCount,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
    };
  }
}
