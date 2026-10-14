import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_network_image.dart';

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
  bool _isUploadingAvatar = false;

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

  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty && result.files.single.bytes != null) {
        setState(() => _isUploadingAvatar = true);
        final file = result.files.single;
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        final newUrl = await auth.uploadAndSetAvatar(file.bytes!, file.name);
        if (mounted) {
          setState(() {
            _avatarUrl = newUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload picture: $e'),
            backgroundColor: AppColors.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
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
                // Avatar editing via device picker
                GestureDetector(
                  onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.of(context).primary.withValues(alpha: 0.15),
                        ),
                        child: ClipOval(
                          child: _isUploadingAvatar
                              ? Container(
                                  color: Colors.black45,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty)
                                  ? AppNetworkImage(
                                      imageUrl: _avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      memCacheWidth: 240,
                                      memCacheHeight: 240,
                                      errorWidget: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.of(context).primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.of(context).primary,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.of(context).surface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (11 digits)',
                    hintText: '01XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final clean = v.replaceAll(RegExp(r'\D'), '');
                    if (clean.length != 11) {
                      return 'Phone number must be exactly 11 digits';
                    }
                    return null;
                  },
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

