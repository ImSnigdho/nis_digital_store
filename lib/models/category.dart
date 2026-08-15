class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? imageUrl;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.imageUrl,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image_url': imageUrl,
    };
  }
}
