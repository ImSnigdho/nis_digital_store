import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import 'admin_add_product_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Products Management',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADD PRODUCT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product count badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: GlassDecoration(context: context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products List',
                    style: TextStyle(color: AppColors.of(context).primary, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${products.length} TOTAL PRODUCTS',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Product list
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.of(context).textSecondary),
                        const SizedBox(height: 16),
                        Text('No products yet', style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddProductScreen())),
                          child: const Text('Add your first product'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final category = productProvider.categories
                          .where((c) => c.id == product.categoryId)
                          .firstOrNull;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: GlassDecoration(context: context),
                        child: Row(
                          children: [
                            // Index
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13),
                              ),
                            ),
                            // Thumbnail + Title
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.primaryImage,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 44, height: 44,
                                  color: AppColors.of(context).surface,
                                  child: Icon(Icons.image_not_supported, size: 20, color: AppColors.of(context).textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.headlineLarge?.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (category != null)
                                    Text(
                                      category.name,
                                      style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            // Price
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.hasSalePrice) ...[
                                    Text(
                                      '৳${product.priceBdt.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppColors.of(context).textSecondary,
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    Text(
                                      '৳${product.salePriceBdt!.toStringAsFixed(0)}',
                                      style: TextStyle(color: AppColors.of(context).success, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ] else
                                    Text(
                                      '৳${product.priceBdt.toStringAsFixed(0)}',
                                      style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                ],
                              ),
                            ),
                            // Status
                            _buildStatusPill(context, product.status),
                            const SizedBox(width: 8),
                            // Actions
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.of(context).primary, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AdminAddProductScreen(product: product)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete, color: AppColors.of(context).error, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => _confirmDelete(context, productProvider, product.id, product.name),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'active':
        color = AppColors.of(context).success;
        break;
      case 'draft':
        color = AppColors.of(context).warning;
        break;
      default:
        color = AppColors.of(context).textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface,
        title: Text('Delete Product', style: TextStyle(color: AppColors.of(context).textColor)),
        content: Text('Are you sure you want to delete "$name"?', style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.deleteProduct(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
