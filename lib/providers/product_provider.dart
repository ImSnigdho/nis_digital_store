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
}
