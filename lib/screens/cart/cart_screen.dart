import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../widgets/app_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../utils/currency_formatter.dart';
import '../checkout/checkout_screen.dart';
import '../../utils/smooth_page_route.dart';

import '../product/product_catalog_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const CartScreen({super.key, this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(
            color: AppColors.of(context).textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cart, auth, _) {
          if (cart.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.of(context).primary),
            );
          }

          if (cart.items.isEmpty) {
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
                        Icons.shopping_cart_outlined,
                        color: AppColors.of(context).primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Looks like you haven't picked up any keys yet.",
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
                      'Explore top digital games, gift cards, and game items ready for instant delivery.',
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

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 300),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  final product = item.product;

                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: AppColors.of(context).error, size: 28),
                    ),
                    onDismissed: (_) => cart.removeFromCart(item.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).glassBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.of(context).glassBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          // Product image
                          AppNetworkImage(
                            imageUrl: product?.primaryImage ?? '',
                            width: 80,
                            height: 80,
                            memCacheWidth: 160,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 12),
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?.name ?? 'Product',
                                  style: TextStyle(
                                    color: AppColors.of(context).textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (product != null && _isOnSale(product, auth.currency))
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // price stack
                                      Text(
                                        CurrencyFormatter.format(
                                            product.getActivePrice(auth.currency),
                                            auth.currency),
                                        style: TextStyle(
                                          color: AppColors.of(context).primary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        CurrencyFormatter.format(
                                            product.getPrice(auth.currency),
                                            auth.currency),
                                        style: TextStyle(
                                          color: AppColors.of(context)
                                              .textColor
                                              .withValues(alpha: 0.6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.lineThrough,
                                          decorationThickness: 1.3,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    product != null
                                        ? CurrencyFormatter.format(
                                            product.getPrice(auth.currency),
                                            auth.currency)
                                        : '',
                                    style: TextStyle(
                                      color: AppColors.of(context).primary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Quantity controls
                                Row(
                                  children: [
                                    _buildQtyButton(context,
                                      icon: Icons.remove,
                                      onTap: () => cart.updateQuantity(
                                          item.id, item.quantity - 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: TextStyle(
                                          color: AppColors.of(context).textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _buildQtyButton(context,
                                      icon: Icons.add,
                                      onTap: () => cart.updateQuantity(
                                          item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Item total
                          Text(
                            CurrencyFormatter.format(
                                item.totalPrice(auth.currency), auth.currency),
                            style: TextStyle(
                              color: AppColors.of(context).textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Bottom checkout bar
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
                          20,
                          20,
                          MediaQuery.of(context).padding.bottom + 20),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surface.withValues(alpha: 0.9),
                        border: Border(
                          top: BorderSide(
                              color: AppColors.of(context).glassBorder, width: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(builder: (context) {
                            final c = AppColors.of(context);
                            final total = cart.totalPrice(auth.currency);
                            final subtotal = cart.items.fold<double>(
                                0,
                                (s, i) =>
                                    s +
                                    (i.product?.getPrice(auth.currency) ?? 0) *
                                        i.quantity);
                            final savings = subtotal - total;
                            final hasSavings = savings > 0.009;
                            final ctaColor = HSLColor.fromColor(c.primary)
                                .withLightness(
                                    (HSLColor.fromColor(c.primary).lightness -
                                            0.12)
                                        .clamp(0.0, 1.0))
                                .withSaturation(
                                    (HSLColor.fromColor(c.primary).saturation +
                                            0.1)
                                        .clamp(0.0, 1.0))
                                .toColor();

                            Widget line(String label, String value,
                                {Color? color}) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(label,
                                        style: TextStyle(
                                            color: c.textSecondary,
                                            fontSize: 13)),
                                    Text(value,
                                        style: TextStyle(
                                            color: color ?? c.textColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasSavings) ...[
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: c.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_offer,
                                            size: 16, color: c.success),
                                        const SizedBox(width: 8),
                                        Text(
                                          'You save: ${CurrencyFormatter.format(savings, auth.currency)}',
                                          style: TextStyle(
                                            color: c.success,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  line('Subtotal (${cart.itemCount} items)',
                                      CurrencyFormatter.format(
                                          subtotal, auth.currency)),
                                  line('Discount',
                                      '-${CurrencyFormatter.format(savings, auth.currency)}',
                                      color: c.success),
                                ] else
                                  line('Subtotal (${cart.itemCount} items)',
                                      CurrencyFormatter.format(
                                          subtotal, auth.currency)),
                                Divider(
                                    height: 12,
                                    color: c.glassBorder,
                                    thickness: 0.8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: TextStyle(
                                          color: c.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Text(
                                      CurrencyFormatter.format(
                                          total, auth.currency),
                                      style: TextStyle(
                                        color: c.textColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        SmoothPageRoute(
                                          page: const CheckoutScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ctaColor,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor:
                                          ctaColor.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Proceed to Checkout',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
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

  /// True when the product has a valid sale price lower than its base price
  /// for the given currency.
  static bool _isOnSale(Product p, String currency) {
    final sale = p.getSalePrice(currency);
    return sale != null && sale > 0 && sale < p.getPrice(currency);
  }

  Widget _buildQtyButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    return _InteractiveQtyButton(icon: icon, onTap: onTap);
  }
}

class _InteractiveQtyButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _InteractiveQtyButton({required this.icon, required this.onTap});

  @override
  State<_InteractiveQtyButton> createState() => _InteractiveQtyButtonState();
}

class _InteractiveQtyButtonState extends State<_InteractiveQtyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.of(context).glassBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.of(context).glassBorder),
          ),
          child: Icon(widget.icon, color: AppColors.of(context).textColor, size: 14),
        ),
      ),
    );
  }
}

