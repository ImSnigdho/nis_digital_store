import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.02 : 1.0,
          _isHovered ? 1.02 : 1.0,
          1.0,
        ),
        alignment: FractionalOffset.center,
        child: GlassmorphicCard(
          onTap: widget.onTap,
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
                      child: CachedNetworkImage(
                        imageUrl: widget.product.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.of(context).surface,
                          highlightColor: AppColors.of(context).glassBorder,
                          child: Container(color: AppColors.of(context).surface),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.of(context).surface,
                          child: Icon(Icons.image_not_supported,
                              color: AppColors.of(context).textSecondary, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
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
                        children: [
                          Text(
                            CurrencyFormatter.format(
                                widget.product.getPrice(widget.currency), widget.currency),
                            style: TextStyle(
                              color: AppColors.of(context).primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.product.rating > 0)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  widget.product.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.of(context).textSecondary,
                                    fontSize: 12,
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
    );
  }
}

