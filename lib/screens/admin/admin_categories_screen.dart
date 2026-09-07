import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/product_provider.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

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
                  'Categories Management',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, productProvider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADD CATEGORY'),
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

          // Count badge
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
                    'Categories List',
                    style: TextStyle(color: AppColors.of(context).primary, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${categories.length} CATEGORIES',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 64, color: AppColors.of(context).textSecondary),
                        const SizedBox(height: 16),
                        Text('No categories yet', style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showAddEditDialog(context, productProvider),
                          child: const Text('Add Category'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: GlassDecoration(context: context),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text('${index + 1}', style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 13)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  if (category.description != null && category.description!.isNotEmpty)
                                    Text(category.description!, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category.slug,
                                  style: TextStyle(color: AppColors.of(context).accent, fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.inventory_2, size: 14, color: AppColors.of(context).textSecondary),
                                  const SizedBox(width: 4),
                                  Text('${category.productCount}', style: TextStyle(color: AppColors.of(context).textColor, fontSize: 13)),
                                ],
                              ),
                            ),
                            _buildStatusPill(context, category.status),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.of(context).primary, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => _showAddEditDialog(context, productProvider, category: category),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete, color: AppColors.of(context).error, size: 20),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () => _confirmDelete(context, productProvider, category.id, category.name, category.productCount),
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
    Color color = status == 'active' ? AppColors.of(context).success : AppColors.of(context).textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showAddEditDialog(BuildContext context, ProductProvider provider, {dynamic category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: isEdit ? category.name : '');
    final descCtrl = TextEditingController(text: isEdit ? category.description : '');
    String status = isEdit ? category.status : 'active';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.of(context).surface,
          title: Text(isEdit ? 'Edit Category' : 'Add Category', style: TextStyle(color: AppColors.of(context).textColor)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  style: TextStyle(color: AppColors.of(context).textColor),
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    labelStyle: TextStyle(color: AppColors.of(context).textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).primary)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  style: TextStyle(color: AppColors.of(context).textColor),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.of(context).textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).primary)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  onChanged: (val) => setState(() => status = val!),
                  items: ['active', 'inactive']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                      .toList(),
                  style: TextStyle(color: AppColors.of(context).textColor),
                  dropdownColor: AppColors.of(context).surface,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: AppColors.of(context).textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).glassBorder)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).primary)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setState(() => isSaving = true);
                
                final name = nameCtrl.text.trim();
                final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

                try {
                  if (isEdit) {
                    await provider.updateCategory(
                      id: category.id,
                      name: name,
                      slug: slug,
                      description: descCtrl.text.trim(),
                      status: status,
                    );
                  } else {
                    await provider.createCategory(
                      name: name,
                      slug: slug,
                      description: descCtrl.text.trim(),
                      status: status,
                    );
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isEdit ? 'Category updated' : 'Category added'),
                      backgroundColor: AppColors.of(context).success,
                    ));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    setState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.of(context).error,
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).primary),
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider, String id, String name, int productCount) {
    if (productCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.of(context).surface,
          title: Text('Cannot Delete', style: TextStyle(color: AppColors.of(context).textColor)),
          content: Text('Category "$name" contains $productCount products. Please reassign or delete them first.', style: TextStyle(color: AppColors.of(context).textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).surface,
        title: Text('Delete Category', style: TextStyle(color: AppColors.of(context).textColor)),
        content: Text('Are you sure you want to delete "$name"?', style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              provider.deleteCategory(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
