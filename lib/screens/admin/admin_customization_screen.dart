import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/store_provider.dart';

class AdminCustomizationScreen extends StatelessWidget {
  const AdminCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context,
            'Store Name',
            'Edit the main title of your store',
            Icons.edit_document,
            isDark,
            onTap: () => _showEditStoreNameDialog(context),
          ),
          _buildSettingsCard(context, 'Store Banner', 'Manage homepage banner image', Icons.image, isDark),
          _buildSettingsCard(context, 'Promo Codes', 'Create and manage discount codes', Icons.local_offer, isDark),
          _buildSettingsCard(context, 'Featured Categories', 'Select which categories appear on home', Icons.category, isDark),
          _buildSettingsCard(context, 'Store Theme Colors', 'Adjust primary and accent colors', Icons.color_lens, isDark),
        ],
      ),
    );
  }

  void _showEditStoreNameDialog(BuildContext context) {
    final storeProvider = context.read<StoreProvider>();
    final controller = TextEditingController(text: storeProvider.storeName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Edit Store Name',
            style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color),
            decoration: InputDecoration(
              labelText: 'Store Name',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                storeProvider.updateStoreName(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Store Name updated successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context, String title, String subtitle, IconData icon, bool isDark, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: GlassDecoration(isLight: !isDark),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.headlineLarge?.color, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title management coming soon!')));
        },
      ),
    );
  }
}
