import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../widgets/app_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/currency_formatter.dart';
import '../checkout/checkout_screen.dart';
import '../../utils/smooth_page_route.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      color: AppColors.of(context).textSecondary.withValues(alpha: 0.5), size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: AppColors.of(context).textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 200),
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
                                Text(
                                  product != null
                                      ? CurrencyFormatter.format(
                                          product.getPrice(auth.currency),
                                          auth.currency)
                                      : '',
                                  style: TextStyle(
                                    color: AppColors.of(context).primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      color: AppColors.of(context).textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(
                                        cart.totalPrice(auth.currency),
                                        auth.currency),
                                    style: TextStyle(
                                      color: AppColors.of(context).textColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${cart.itemCount} items',
                                style: TextStyle(
                                  color: AppColors.of(context).textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  SmoothPageRoute(
                                    page: const CheckoutScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.of(context).primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

