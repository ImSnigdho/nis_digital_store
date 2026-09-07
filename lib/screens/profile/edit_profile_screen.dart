import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _discordController;
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _discordController = TextEditingController(text: profile?.discordUsername ?? '');
    _avatarUrl = profile?.avatarUrl ?? context.read<AuthProvider>().user?.userMetadata?['picture'] ?? context.read<AuthProvider>().user?.userMetadata?['avatar_url'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _discordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    if (auth.profile != null) {
      try {
        await auth.updateProfile(
          auth.profile!.copyWith(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            discordUsername: _discordController.text.trim(),
            avatarUrl: _avatarUrl,
          ),
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e'), backgroundColor: AppColors.of(context).error),
          );
        }
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Placeholder for editing
                GestureDetector(
                  onTap: () {
                    final urlCtrl = TextEditingController(text: _avatarUrl ?? '');
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.of(context).surface,
                        title: Text('Profile Image URL', style: TextStyle(color: AppColors.of(context).textColor)),
                        content: TextField(
                          controller: urlCtrl,
                          style: TextStyle(color: AppColors.of(context).textColor),
                          decoration: InputDecoration(hintText: 'Enter image URL (https://...)'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _avatarUrl = urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim());
                              Navigator.pop(ctx);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.of(context).primary.withValues(alpha: 0.2),
                        backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                        child: _avatarUrl == null 
                          ? Icon(Icons.person, size: 60, color: AppColors.of(context).primary)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.of(context).surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 16),

                // Discord
                TextFormField(
                  controller: _discordController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    labelText: 'Discord Username',
                    prefixIcon: Icon(Icons.discord),
                  ),
                ),
                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Changes'),
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

