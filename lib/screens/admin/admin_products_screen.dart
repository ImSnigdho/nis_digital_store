import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_network_image.dart';
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
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                    MaterialPageRoute(
                        builder: (_) => const AdminAddProductScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADD PRODUCT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Products List',
                    style: TextStyle(
                        color: AppColors.of(context).primary,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${products.length} TOTAL PRODUCTS',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
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
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: AppColors.of(context).textSecondary),
                        const SizedBox(height: 16),
                        Text('No products yet',
                            style: TextStyle(
                                color: AppColors.of(context).textSecondary,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminAddProductScreen())),
                          child: const Text('Add your first product'),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 620;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final category = productProvider.categories
                              .where((c) => c.id == product.categoryId)
                              .firstOrNull;

                          if (isMobile) {
                            return _buildMobileProductCard(context,
                                productProvider, product, category, index);
                          }
                          return _buildDesktopProductRow(context,
                               productProvider, product, category, index);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductCard(
    BuildContext context,
    ProductProvider productProvider,
    Product product,
    dynamic category,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: GlassDecoration(context: context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          AppNetworkImage(
            imageUrl: product.primaryImage,
            width: 50,
            height: 50,
            memCacheWidth: 120,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          // Middle: Name, Category, Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                if (category != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    category.name,
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                if (product.hasSalePrice)
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '৳${product.salePriceBdt!.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: AppColors.of(context).success,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '৳${product.priceBdt.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.of(context).textSecondary,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '৳${product.priceBdt.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: Status pill + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusPill(context, product.status),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: AppColors.of(context).primary, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdminAddProductScreen(product: product)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: AppColors.of(context).error, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => _confirmDelete(
                        context, productProvider, product.id, product.name),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProductRow(
    BuildContext context,
    ProductProvider productProvider,
    Product product,
    dynamic category,
    int index,
  ) {
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
              style: TextStyle(
                  color: AppColors.of(context).textSecondary, fontSize: 13),
            ),
          ),
          // Thumbnail
          AppNetworkImage(
            imageUrl: product.primaryImage,
            width: 44,
            height: 44,
            memCacheWidth: 120,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          // Title + Category
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
                    style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12),
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
                    style: TextStyle(
                        color: AppColors.of(context).success,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ] else
                  Text(
                    '৳${product.priceBdt.toStringAsFixed(0)}',
                    style: TextStyle(
                        color:
                            Theme.of(context).textTheme.headlineLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          // Status + Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusPill(context, product.status),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit,
                    color: AppColors.of(context).primary, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AdminAddProductScreen(product: product)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete,
                    color: AppColors.of(context).error, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => _confirmDelete(
                    context, productProvider, product.id, product.name),
              ),
            ],
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider,
      String productId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface,
        title: Text('Delete Product',
            style: TextStyle(color: AppColors.of(context).textColor)),
        content: Text(
          'Are you sure you want to delete "$productName"? This action cannot be undone.',
          style: TextStyle(color: AppColors.of(context).textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.of(context).textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final successColor = AppColors.of(context).success;
              final errorColor = AppColors.of(context).error;
              try {
                await provider.deleteProduct(productId);
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Product deleted'),
                    backgroundColor: successColor,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed: $e'),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
