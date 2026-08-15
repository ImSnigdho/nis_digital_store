import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/shimmer_loading.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/store_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    await Future.wait([
      productProvider.loadInitialData(),
      cartProvider.loadCart(),
      wishlistProvider.loadWishlist(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Consumer2<CartProvider, WishlistProvider>(
        builder: (context, cart, wishlist, _) {
          return CustomBottomNavBar(
            currentIndex: _currentIndex,
            cartCount: cart.itemCount,
            wishlistCount: wishlist.itemCount,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return Text(
                              'Hello, ${auth.profile?.fullName ?? 'there'} 👋',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Consumer<StoreProvider>(
                          builder: (context, store, _) {
                            return Text(
                              store.storeName,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.headlineLarge?.color ?? AppColors.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: CustomSearchBar(
                  controller: _searchController,
                  onSubmitted: (query) {
                    context.read<ProductProvider>().setSearchQuery(
                        query.isEmpty ? null : query);
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      children: [
                        CategoryChip(
                          label: 'All',
                          icon: '🔥',
                          isSelected:
                              productProvider.selectedCategoryId == null,
                          onTap: () => productProvider.setCategory(null),
                        ),
                        const SizedBox(width: 8),
                        ...productProvider.categories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: cat.name,
                              icon: cat.icon,
                              isSelected: productProvider.selectedCategoryId ==
                                  cat.id,
                              onTap: () =>
                                  productProvider.setCategory(cat.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Featured Section
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.featuredProducts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          '⭐ Featured Products',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headlineLarge?.color ?? AppColors.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              productProvider.featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                productProvider.featuredProducts[index];
                            return Consumer2<AuthProvider, WishlistProvider>(
                              builder: (context, auth, wishlist, _) {
                                return Container(
                                  width: 170,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: ProductCard(
                                    product: product,
                                    currency: auth.currency,
                                    isFavorite:
                                        wishlist.isWishlisted(product.id),
                                    onFavoriteTap: () => wishlist
                                        .toggleWishlist(product.id),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailScreen(
                                                  productId: product.id),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // All Products Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  '🛍️ All Products',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color ?? AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                                color: AppColors.textSecondary, size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              onFavoriteTap: () =>
                                  wishlist.toggleWishlist(product.id),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                        productId: product.id),
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
      ),
    );
  }
}
