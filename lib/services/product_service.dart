import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

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

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
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
}
