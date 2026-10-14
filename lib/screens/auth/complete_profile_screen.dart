import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _discordController;
  late TextEditingController _nameController;
  String _selectedCountry = 'BD';
  bool _isLoading = false;

  final List<String> _countries = [
    'BD', 'US', 'UK', 'CA', 'AU', 'IN', 'PK', 'SG', 'AE'
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final profile = auth.profile;
    
    _nameController = TextEditingController(
      text: profile?.fullName ?? user?.userMetadata?['full_name'] ?? '',
    );
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _discordController = TextEditingController(text: profile?.discordUsername ?? '');
    _selectedCountry = profile?.country ?? 'BD';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _discordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    
    // Create updated profile
    final userId = auth.user?.id ?? Supabase.instance.client.auth.currentUser?.id ?? '';
    final currentProfile = auth.profile ??
        Profile(
          id: userId,
          fullName: _nameController.text.trim(),
          country: _selectedCountry,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updatedProfile = currentProfile.copyWith(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      discordUsername: _discordController.text.trim(),
      country: _selectedCountry,
    );

    try {
      await auth.updateProfile(updatedProfile);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: AppColors.of(context).error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final avatarUrl = auth.profile?.avatarUrl ?? auth.user?.userMetadata?['avatar_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Just a few more details to get started!',
                  style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 16),
                ),
                SizedBox(height: 32),
                
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.of(context).surface,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 50, color: AppColors.of(context).textSecondary)
                      : null,
                ),
                SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppColors.of(context).textColor),
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
                  style: TextStyle(color: AppColors.of(context).textColor),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (11 digits required)',
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
                SizedBox(height: 16),

                // Discord
                TextFormField(
                  controller: _discordController,
                  style: TextStyle(color: AppColors.of(context).textColor),
                  decoration: const InputDecoration(
                    labelText: 'Discord Username (Optional)',
                    prefixIcon: Icon(Icons.discord),
                  ),
                ),
                const SizedBox(height: 16),

                // Country Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  dropdownColor: AppColors.of(context).surface,
                  style: TextStyle(color: AppColors.of(context).textColor),
                  items: _countries.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCountry = val);
                    }
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Complete Setup'),
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

