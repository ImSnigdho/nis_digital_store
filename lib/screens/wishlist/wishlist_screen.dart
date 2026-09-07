import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      color: AppColors.of(context).textSecondary.withValues(alpha: 0.5), size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      color: AppColors.of(context).textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save items you love for later',
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
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
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
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

