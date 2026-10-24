import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../../utils/smooth_page_route.dart';

import '../product/product_catalog_screen.dart';

class WishlistScreen extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const WishlistScreen({super.key, this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: TextStyle(
            color: AppColors.of(context).textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.of(context).primary),
            );
          }

          if (wishlist.items.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.of(context).primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your wishlist is empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.of(context).textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Save digital keys and game items you love for easy access anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (onBrowseProducts != null) {
                          onBrowseProducts!();
                        } else {
                          Navigator.of(context).push(
                            SmoothPageRoute(
                              page: const ProductCatalogScreen(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.explore_outlined, size: 20),
                      label: const Text(
                        'Browse Products',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor:
                            AppColors.of(context).primary.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final item = wishlist.items[index];
              final product = item.product;

              if (product == null) return const SizedBox.shrink();

              return Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Stack(
                    children: [
                      ProductCard(
                        product: product,
                        currency: auth.currency,
                        isFavorite: true,
                        onFavoriteTap: () =>
                            wishlist.toggleWishlist(product.id),
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(
                              page: ProductDetailScreen(
                                  productId: product.id),
                            ),
                          );
                        },
                      ),
                      // Move to cart button
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            await context
                                .read<CartProvider>()
                                .addToCart(product.id);
                            await wishlist.toggleWishlist(product.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} moved to cart'),
                                  backgroundColor: AppColors.of(context).success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).primary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.of(context).primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

