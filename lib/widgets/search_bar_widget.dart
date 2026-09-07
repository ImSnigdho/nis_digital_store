import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String hintText;
  final VoidCallback? onFilterTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search products...',
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.of(context).glassBorder, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: TextStyle(color: AppColors.of(context).textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.of(context).textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.of(context).textSecondary),
              suffixIcon: onFilterTap != null
                  ? GestureDetector(
                      onTap: onFilterTap,
                      child: Container(
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.tune,
                            color: AppColors.of(context).primary, size: 20),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

