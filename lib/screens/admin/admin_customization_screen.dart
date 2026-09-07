import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import '../../providers/store_provider.dart';
import 'admin_payment_methods_screen.dart';

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
          _buildSettingsCard(
            context,
            'Payment Methods',
            'Add/edit bKash, Nagad and other payment options',
            Icons.payments,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminPaymentMethodsScreen()),
              );
            },
          ),
          _buildSettingsCard(
            context,
            'Store Banner',
            'Upload a homepage banner image',
            Icons.image,
            isDark,
            onTap: () => _showBannerUploadDialog(context),
          ),
          _buildSettingsCard(
            context,
            'Featured Categories',
            'Select which categories appear on home',
            Icons.category,
            isDark,
          ),
        ],
      ),
    );
  }

  // ──── Store Name ────

  void _showEditStoreNameDialog(BuildContext context) {
    final storeProvider = context.read<StoreProvider>();
    final controller = TextEditingController(text: storeProvider.storeName);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Edit Store Name',
            style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge?.color),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge?.color),
            decoration: InputDecoration(
              labelText: 'Store Name',
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.of(context).glassBorder),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style:
                      TextStyle(color: AppColors.of(context).textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setState(() => isSaving = true);
                      try {
                        await storeProvider
                            .updateStoreName(controller.text.trim());
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Store name updated!'),
                              backgroundColor:
                                  AppColors.of(context).success,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSaving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor:
                                  AppColors.of(context).error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).primary),
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ──── Banner Upload ────

  void _showBannerUploadDialog(BuildContext context) {
    final storeProvider = context.read<StoreProvider>();
    final client = Supabase.instance.client;
    Uint8List? bytes;
    String? fileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Upload Store Banner',
              style: TextStyle(
                  color: Theme.of(context).textTheme.headlineLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (storeProvider.bannerUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(storeProvider.bannerUrl,
                      height: 120, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => const SizedBox()),
                ),
              if (bytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(bytes!, height: 120,
                      width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isUploading
                    ? null
                    : () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null &&
                            result.files.single.bytes != null) {
                          setState(() {
                            bytes = result.files.single.bytes;
                            fileName = result.files.single.name;
                          });
                        }
                      },
                icon: const Icon(Icons.upload),
                label: const Text('Choose Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(
                      color: AppColors.of(context).textSecondary)),
            ),
            ElevatedButton(
              onPressed: (bytes == null || isUploading)
                  ? null
                  : () async {
                      setState(() => isUploading = true);
                      try {
                        final path =
                            'banner/${DateTime.now().millisecondsSinceEpoch}_$fileName';
                        await client.storage
                            .from('store-banner')
                            .uploadBinary(path, bytes!,
                                fileOptions: const FileOptions(upsert: true));
                        final url = client.storage
                            .from('store-banner')
                            .getPublicUrl(path);
                        await storeProvider.updateBannerUrl(url);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Banner updated!'),
                              backgroundColor: AppColors.of(context).success,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isUploading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.of(context).error,
                          ));
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).primary),
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  // ──── Card ────

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: GlassDecoration(context: context),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.of(context).primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.of(context).primary),
        ),
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge?.color,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color)),
        trailing:
            Icon(Icons.chevron_right, color: AppColors.of(context).textSecondary),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title coming soon!')),
              );
            },
      ),
    );
  }
}
