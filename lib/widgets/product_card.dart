import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'app_network_image.dart';
import '../models/product.dart';
import '../utils/currency_formatter.dart';
import 'glassmorphic_card.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.025 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          alignment: FractionalOffset.center,
          child: GlassmorphicCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AppNetworkImage(
                          imageUrl: widget.product.primaryImage,
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                        ),
                      ),
                    ),
                    // Favorite button with bouncy spring pop
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onFavoriteTap,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(widget.isFavorite),
                          tween: Tween<double>(begin: 0.75, end: 1.0),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.elasticOut,
                          builder: (context, animScale, child) {
                            return Transform.scale(
                              scale: animScale,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: widget.isFavorite ? Colors.redAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Featured badge
                  if (widget.product.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.of(context).primary, AppColors.of(context).accent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.of(context).primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Text(
                          '★ Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Discount badge
                  if (widget.product.hasSalePrice)
                    Positioned(
                      top: widget.product.isFeatured ? 36 : 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.product.getDiscountPercent(widget.currency)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.brand != null)
                        Text(
                          widget.product.brand!,
                          style: TextStyle(
                            color: AppColors.of(context).accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 2),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headlineLarge?.color ?? AppColors.of(context).textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.product.hasSalePrice)
                                Text(
                                  CurrencyFormatter.format(
                                      widget.product.getPrice(widget.currency), widget.currency),
                                  style: TextStyle(
                                    color: AppColors.of(context).textSecondary,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                CurrencyFormatter.format(
                                    widget.product.getActivePrice(widget.currency), widget.currency),
                                style: TextStyle(
                                  color: AppColors.of(context).primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

