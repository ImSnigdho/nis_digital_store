import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  // ──── PRODUCTS ────

  Future<List<Product>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String currency = 'BDT',
    bool? featuredOnly,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    var query = _client.from('products').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%,brand.ilike.%$searchQuery%');
    }
    if (brand != null) {
      query = query.eq('brand', brand);
    }
    if (featuredOnly == true) {
      query = query.eq('is_featured', true);
    }
    if (minPrice != null) {
      final priceCol = currency == 'BDT' ? 'price_bdt' : 'price_usd';
      query = query.gte(priceCol, minPrice);
    }
    if (maxPrice != null) {
      final priceCol = currency == 'BDT' ? 'price_bdt' : 'price_usd';
      query = query.lte(priceCol, maxPrice);
    }

    final response = await query.order(orderBy, ascending: ascending);

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(String id) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', id)
        .single();

    return Product.fromJson(response);
  }

  Future<List<Product>> getFeaturedProducts() async {
    return getProducts(featuredOnly: true);
  }

  Future<Product> createProduct({
    required String name,
    String? shortDescription,
    String? description,
    required double priceBdt,
    required double priceUsd,
    double? salePriceBdt,
    double? salePriceUsd,
    String? categoryId,
    String status = 'active',
    bool isFeatured = false,
    String? thumbnailUrl,
    String? fileUrl,
    String? brand,
    int stock = 0,
  }) async {
    final data = {
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'price_bdt': priceBdt,
      'price_usd': priceUsd,
      'sale_price_bdt': salePriceBdt,
      'sale_price_usd': salePriceUsd,
      'category_id': categoryId,
      'status': status,
      'is_featured': isFeatured,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'brand': brand,
      'stock': stock,
      'images': thumbnailUrl != null ? [thumbnailUrl] : [],
      'downloads_count': 0,
    };

    final response = await _client
        .from('products')
        .insert(data)
        .select()
        .single();

    return Product.fromJson(response);
  }

  Future<void> updateProductFull({
    required String id,
    required String name,
    String? shortDescription,
    String? description,
    required double priceBdt,
    required double priceUsd,
    double? salePriceBdt,
    double? salePriceUsd,
    String? categoryId,
    String status = 'active',
    bool isFeatured = false,
    String? thumbnailUrl,
    String? fileUrl,
    String? brand,
    required int stock,
  }) async {
    final data = {
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'price_bdt': priceBdt,
      'price_usd': priceUsd,
      'sale_price_bdt': salePriceBdt,
      'sale_price_usd': salePriceUsd,
      'category_id': categoryId,
      'status': status,
      'is_featured': isFeatured,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'brand': brand,
      'stock': stock,
      'images': thumbnailUrl != null ? [thumbnailUrl] : [],
    };

    await _client.from('products').update(data).eq('id', id);
  }

  Future<void> updateProduct(String id, String name, double price) async {
    await _client.from('products').update({
      'name': name,
      'price_bdt': price,
    }).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // ──── FILE UPLOADS ────

  Future<String> uploadThumbnail(String fileName, Uint8List bytes) async {
    final path = 'thumbnails/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('product-thumbnails').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return _client.storage.from('product-thumbnails').getPublicUrl(path);
  }

  Future<String> uploadProductFile(String fileName, Uint8List bytes) async {
    final path = 'files/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('product-files').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    // Return the path, not public URL (private bucket)
    return path;
  }

  // ──── CATEGORIES ────

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name');

    // Compute product counts
    final products = await _client.from('products').select('category_id');
    final countMap = <String, int>{};
    for (final p in products as List) {
      final catId = p['category_id'] as String?;
      if (catId != null) {
        countMap[catId] = (countMap[catId] ?? 0) + 1;
      }
    }

    return (response as List).map((json) {
      final map = Map<String, dynamic>.from(json as Map<String, dynamic>);
      map['product_count'] = countMap[map['id']] ?? 0;
      return Category.fromJson(map);
    }).toList();
  }

  Future<Category> createCategory({
    required String name,
    required String slug,
    String? description,
    String status = 'active',
  }) async {
    final response = await _client.from('categories').insert({
      'name': name,
      'slug': slug,
      'description': description,
      'status': status,
    }).select().single();

    return Category.fromJson(response);
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String slug,
    String? description,
    String status = 'active',
  }) async {
    await _client.from('categories').update({
      'name': name,
      'slug': slug,
      'description': description,
      'status': status,
    }).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  Future<List<String>> getBrands() async {
    final response = await _client
        .from('products')
        .select('brand')
        .not('brand', 'is', null);

    final brands = (response as List)
        .map((json) => json['brand'] as String)
        .toSet()
        .toList();
    brands.sort();
    return brands;
  }
  Future<int> getTotalSold(String productId) async {
    try {
      final response = await _client.rpc('get_total_sold', params: {'p_id': productId});
      return (response as num).toInt();
    } catch (e) {
      return 0;
    }
  }
}
