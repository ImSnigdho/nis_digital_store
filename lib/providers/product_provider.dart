import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  List<String> _brands = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedCategoryId;
  String? _searchQuery;
  String? _selectedBrand;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  List<String> get brands => _brands;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get searchQuery => _searchQuery;
  String? get selectedBrand => _selectedBrand;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadProducts(),
        loadFeaturedProducts(),
        loadCategories(),
        loadBrands(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    try {
      _products = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
        brand: _selectedBrand,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _productService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadBrands() async {
    try {
      _brands = await _productService.getBrands();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> selectProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(productId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadProducts();
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    loadProducts();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = null;
    _selectedBrand = null;
    loadProducts();
  }

  // ──── PRODUCT CRUD ────

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
  }) async {
    final product = await _productService.createProduct(
      name: name,
      shortDescription: shortDescription,
      description: description,
      priceBdt: priceBdt,
      priceUsd: priceUsd,
      salePriceBdt: salePriceBdt,
      salePriceUsd: salePriceUsd,
      categoryId: categoryId,
      status: status,
      isFeatured: isFeatured,
      thumbnailUrl: thumbnailUrl,
      fileUrl: fileUrl,
      brand: brand,
    );
    await loadProducts();
    return product;
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
  }) async {
    await _productService.updateProductFull(
      id: id,
      name: name,
      shortDescription: shortDescription,
      description: description,
      priceBdt: priceBdt,
      priceUsd: priceUsd,
      salePriceBdt: salePriceBdt,
      salePriceUsd: salePriceUsd,
      categoryId: categoryId,
      status: status,
      isFeatured: isFeatured,
      thumbnailUrl: thumbnailUrl,
      fileUrl: fileUrl,
      brand: brand,
    );
    await loadProducts();
  }

  Future<void> updateProduct(String id, String name, double price) async {
    try {
      await _productService.updateProduct(id, name, price);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ──── FILE UPLOADS ────

  Future<String> uploadThumbnail(String fileName, Uint8List bytes) async {
    return _productService.uploadThumbnail(fileName, bytes);
  }

  Future<String> uploadProductFile(String fileName, Uint8List bytes) async {
    return _productService.uploadProductFile(fileName, bytes);
  }

  // ──── CATEGORY CRUD ────

  Future<void> createCategory({
    required String name,
    required String slug,
    String? description,
    String status = 'active',
  }) async {
    await _productService.createCategory(
      name: name,
      slug: slug,
      description: description,
      status: status,
    );
    await loadCategories();
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String slug,
    String? description,
    String status = 'active',
  }) async {
    await _productService.updateCategory(
      id: id,
      name: name,
      slug: slug,
      description: description,
      status: status,
    );
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _productService.deleteCategory(id);
    await loadCategories();
  }
}
