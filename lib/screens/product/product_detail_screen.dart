import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../widgets/app_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/currency_formatter.dart';


class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().selectProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final product = productProvider.selectedProduct;

          if (productProvider.isLoading || product == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.of(context).primary),
            );
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Hero Image
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // Main image
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: double.infinity,
                          child: AppNetworkImage(
                            imageUrl: product.images.isNotEmpty
                                ? product.images[_selectedImageIndex]
                                : product.primaryImage,
                            fit: BoxFit.cover,
                            memCacheWidth: 900,
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.of(context).background,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          child: _buildGlassButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // Wishlist button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: Consumer<WishlistProvider>(
                            builder: (context, wishlist, _) {
                              final isFav = wishlist.isWishlisted(product.id);
                              return _buildGlassButton(
                                icon: isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : null,
                                onTap: () =>
                                    wishlist.toggleWishlist(product.id),
                              );
                            },
                          ),
                        ),
                        // Image indicators
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) => GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedImageIndex = index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: _selectedImageIndex == index
                                        ? 24
                                        : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _selectedImageIndex == index
                                          ? AppColors.of(context).primary
                                          : AppColors.of(context).textSecondary
                                              .withValues(alpha: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand
                          if (product.brand != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.of(context).accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.brand!,
                                style: TextStyle(
                                  color: AppColors.of(context).accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Name
                          Text(
                            product.name,
                            style: TextStyle(
                              color: AppColors.of(context).textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stock badge (sales counter removed)
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.stock > 0 ? AppColors.of(context).success.withValues(alpha: 0.1) : AppColors.of(context).error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                                  style: TextStyle(
                                    color: product.stock > 0 ? AppColors.of(context).success : AppColors.of(context).error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.hasSalePrice)
                                    Row(
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(
                                              product.getPrice(auth.currency),
                                              auth.currency),
                                          style: TextStyle(
                                            color: AppColors.of(context).textSecondary,
                                            fontSize: 16,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${product.getDiscountPercent(auth.currency)}% OFF',
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    CurrencyFormatter.format(
                                        product.getActivePrice(auth.currency),
                                        auth.currency),
                                    style: TextStyle(
                                      color: AppColors.of(context).primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // Delivery time frame (replaces the old stock line)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: (product.inStock
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).error)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  product.inStock
                                      ? Icons.schedule
                                      : Icons.remove_shopping_cart_outlined,
                                  size: 16,
                                  color: product.inStock
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).error,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    product.inStock
                                        ? 'Delivery via email: 1 to 4 hours'
                                        : 'Currently out of stock',
                                    style: TextStyle(
                                      color: product.inStock
                                          ? AppColors.of(context).textColor
                                          : AppColors.of(context).error,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              color: AppColors.of(context).textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description ?? 'No description available.',
                            style: TextStyle(
                              color: AppColors.of(context).textSecondary,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tags
                          if (product.tags.isNotEmpty) ...[
                            Text(
                              'Tags',
                              style: TextStyle(
                                color: AppColors.of(context).textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.tags.map((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.of(context).glassBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.of(context).glassBorder),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(
                                      color: AppColors.of(context).textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom action bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          20,
                          16,
                          20,
                          MediaQuery.of(context).padding.bottom + 16),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surface.withValues(alpha: 0.9),
                        border: Border(
                          top: BorderSide(
                              color: AppColors.of(context).glassBorder, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Quantity selector
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.of(context).glassBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.of(context).glassBorder),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove,
                                      color: AppColors.of(context).textColor, size: 18),
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                Text(
                                  '$_quantity',
                                  style: TextStyle(
                                    color: AppColors.of(context).textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add,
                                      color: AppColors.of(context).textColor, size: 18),
                                  onPressed: () {
                                    if (_quantity < product.stock) {
                                      setState(() => _quantity++);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Add to Cart button
                          Expanded(
                            child: Consumer<CartProvider>(
                              builder: (context, cart, _) {
                                return ElevatedButton.icon(
                                  onPressed: product.inStock
                                      ? () async {
                                          await cart.addToCart(
                                              product.id,
                                              quantity: _quantity);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${product.name} added to cart'),
                                                backgroundColor:
                                                    AppColors.of(context).success,
                                                behavior: SnackBarBehavior
                                                    .floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  icon: const Icon(
                                      Icons.shopping_cart_outlined),
                                  label: Text('Add to Cart'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.of(context).primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return _InteractiveGlassButton(
      icon: icon,
      onTap: onTap,
      color: color,
    );
  }
}

class _InteractiveGlassButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _InteractiveGlassButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<_InteractiveGlassButton> createState() => _InteractiveGlassButtonState();
}

class _InteractiveGlassButtonState extends State<_InteractiveGlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.90 : (_isHovered ? 1.08 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.of(context).primary.withValues(alpha: 0.6)
                        : AppColors.of(context).glassBorder,
                  ),
                ),
                child: Icon(widget.icon, color: widget.color ?? Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

