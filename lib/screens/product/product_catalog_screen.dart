import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/shimmer_loading.dart';
import '../product/product_detail_screen.dart';
import '../../utils/smooth_page_route.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Browse Products',
                style: TextStyle(
                  color: Theme.of(context).textTheme.headlineLarge?.color ?? AppColors.of(context).textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Search for anything...',
                onSubmitted: (query) {
                  context.read<ProductProvider>().setSearchQuery(query.isEmpty ? null : query);
                },
                onChanged: (query) {
                  if (query.isEmpty) {
                    context.read<ProductProvider>().setSearchQuery(null);
                  }
                },
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      CategoryChip(
                        label: 'All',
                        icon: '🔥',
                        isSelected: productProvider.selectedCategoryId == null,
                        onTap: () => productProvider.setCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...productProvider.categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: cat.name,
                            icon: cat.icon,
                            isSelected: productProvider.selectedCategoryId == cat.id,
                            onTap: () => productProvider.setCategory(cat.id),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Products Grid
          Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              if (productProvider.isLoading) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ShimmerProductGrid(),
                  ),
                );
              }

              if (productProvider.products.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              color: AppColors.of(context).textSecondary, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProvider.products[index];
                      return Consumer2<AuthProvider, WishlistProvider>(
                        builder: (context, auth, wishlist, _) {
                          return ProductCard(
                            product: product,
                            currency: auth.currency,
                            isFavorite: wishlist.isWishlisted(product.id),
                            onFavoriteTap: () => wishlist.toggleWishlist(product.id),
                            onTap: () {
                              Navigator.of(context).push(
                                SmoothPageRoute(
                                  page: ProductDetailScreen(productId: product.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    childCount: productProvider.products.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
