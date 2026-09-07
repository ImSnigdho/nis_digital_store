class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? imageUrl;
  final String? description;
  final String status; // 'active', 'inactive'
  final int productCount;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.imageUrl,
    this.description,
    this.status = 'active',
    this.productCount = 0,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'icon': icon,
      'image_url': imageUrl,
      'description': description,
      'status': status,
    };
  }
}
