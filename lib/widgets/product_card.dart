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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isPressed ? 0.92 : 1.0,
          child: GlassmorphicCard(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            borderOpacity: _isHovered ? 0.45 : 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedScale(
                          scale: _isHovered ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          child: AppNetworkImage(
                            imageUrl: widget.product.primaryImage,
                            fit: BoxFit.cover,
                            memCacheWidth: 500,
                          ),
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
                    // Badges: Standalone gold star icon ⭐ & discount tag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.product.isFeatured)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB800),
                                size: 22,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.product.hasSalePrice)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${widget.product.getDiscountPercent(widget.currency)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                        ],
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
                        if (widget.product.brand != null && widget.product.brand!.trim().isNotEmpty)
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
                        const SizedBox(height: 2),
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

