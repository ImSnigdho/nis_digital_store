import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:badges/badges.dart' as badges;
import '../config/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;
  final int wishlistCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
    this.wishlistCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: AppColors.of(context).glassBorder, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_outlined, 'Home'),
                  _buildNavItem(context, 1, Icons.shopping_bag_outlined, 'Products'),
                  _buildNavItem(context, 2, Icons.favorite_outline, 'Wishlist',
                      badgeCount: wishlistCount),
                  _buildNavItem(context, 3, Icons.shopping_cart_outlined, 'Cart',
                      badgeCount: cartCount),
                  _buildNavItem(context, 4, Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label,
      {int badgeCount = 0}) {
    final isSelected = currentIndex == index;

    Widget iconWidget = Icon(
      icon,
      color: isSelected ? AppColors.of(context).primary : AppColors.of(context).textSecondary,
      size: 24,
    );

    if (badgeCount > 0) {
      iconWidget = badges.Badge(
        badgeContent: Text(
          badgeCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: AppColors.of(context).primary,
          padding: EdgeInsets.all(4),
        ),
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.of(context).primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.of(context).primary : AppColors.of(context).textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

