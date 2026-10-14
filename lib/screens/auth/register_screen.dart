import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'complete_profile_screen.dart';
import '../../widgets/welcome_logo.dart';
import '../../widgets/ambient_side_gradient_background.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialEmail;
  final String? redirectMessage;
  const RegisterScreen({super.key, this.initialEmail, this.redirectMessage});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountry = 'BD';

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _cleanAuthError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('sign_in_failed') && (lower.contains('10') || lower.contains('developer_error'))) {
      return 'Google Sign-In SHA-1 mismatch (Error 10). Please add the release SHA-1 to Google Cloud Console.';
    }
    if (lower.contains('email logins are disabled') ||
        lower.contains('email signups are disabled') ||
        lower.contains('email_provider_disabled')) {
      return 'Email authentication is disabled in Supabase. Please enable Email Provider in Supabase Dashboard.';
    }
    if (lower.contains('already') &&
        (lower.contains('registered') || lower.contains('exists') || lower.contains('user'))) {
      return 'This email is already registered. Please Sign In!';
    }
    if (lower.contains('password') &&
        (lower.contains('least') || lower.contains('short') || lower.contains('weak') || lower.contains('6'))) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('invalid') && lower.contains('email')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('rate') && lower.contains('limit')) {
      return 'Too many attempts. Please wait 1 minute before trying again.';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('failed host lookup')) {
      return 'Network connection error. Please check your internet.';
    }
    final match = RegExp(r'message:\s*([^,)]+)').firstMatch(error);
    if (match != null) {
      final extracted = match.group(1)?.trim();
      if (extracted != null && extracted.isNotEmpty) return extracted;
    }
    return error.replaceAll('Exception:', '').replaceAll('AuthApiException:', '').trim();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      country: _selectedCountry,
    );

    if (success && mounted) {
      if (authProvider.user == null) {
        // Email confirmation is required by Supabase Auth!
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    color: Color(0xFF6366F1)),
                SizedBox(width: 8),
                Text('Check Your Email',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'A confirmation link has been sent to ${_emailController.text.trim()}.\n\nPlease check your email inbox to verify your account, then return to sign in.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Return to login screen
                },
                child: const Text('Back to Sign In'),
              ),
            ],
          ),
        );
      } else if (!authProvider.isProfileComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else if (mounted && authProvider.error != null) {
      final msg = _cleanAuthError(authProvider.error!);
      final isAlreadyRegistered = msg.contains('already registered');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.of(context).error,
          action: isAlreadyRegistered
              ? SnackBarAction(
                  label: 'Sign In',
                  textColor: Colors.white,
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      if (!authProvider.isProfileComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else if (!success && mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanAuthError(authProvider.error!)),
          backgroundColor: AppColors.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: AmbientSideGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome Logo with circular icon1.png & breathing pulse
                  const WelcomeLogo(size: 78),
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join NIS Digital Store',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.redirectMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6366F1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF818CF8), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.redirectMessage!,
                              style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Glass register card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).glassBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppColors.of(context).glassBorder, width: 0.5),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Name field
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(
                                    color: AppColors.of(context).textColor),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(
                                      color: AppColors.of(context).textSecondary),
                                  prefixIcon: Icon(Icons.person_outlined,
                                      color: AppColors.of(context).textSecondary),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    color: AppColors.of(context).textColor),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      color: AppColors.of(context).textSecondary),
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: AppColors.of(context).textSecondary),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Country selector
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).glassBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.of(context).glassBorder),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedCountry,
                                  dropdownColor: AppColors.of(context).surface,
                                  style: TextStyle(
                                      color: AppColors.of(context).textColor),
                                  decoration: InputDecoration(
                                    labelText: 'Country',
                                    labelStyle: TextStyle(
                                        color: AppColors.of(context).textSecondary),
                                    prefixIcon: Icon(
                                        Icons.public_outlined,
                                        color: AppColors.of(context).textSecondary),
                                    border: InputBorder.none,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'BD',
                                      child: Text('🇧🇩 Bangladesh (BDT)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'OTHER',
                                      child: Text('🌍 Other (USD)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCountry = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                    color: AppColors.of(context).textColor),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                      color: AppColors.of(context).textSecondary),
                                  prefixIcon: Icon(
                                      Icons.lock_outlined,
                                      color: AppColors.of(context).textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.of(context).textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirm password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(
                                    color: AppColors.of(context).textColor),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                      color: AppColors.of(context).textSecondary),
                                  prefixIcon: Icon(
                                      Icons.lock_outlined,
                                      color: AppColors.of(context).textSecondary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.of(context).textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Register button
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading
                                          ? null
                                          : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.of(context).primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Google Sign in
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                                      icon: Icon(Icons.g_mobiledata, color: AppColors.of(context).textColor, size: 28),
                                      label: Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: AppColors.of(context).textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.of(context).glassBorder),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.of(context).textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.of(context).primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

