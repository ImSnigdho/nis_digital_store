import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_screen.dart';
import 'complete_profile_screen.dart';
import '../../widgets/welcome_logo.dart';
import '../../widgets/ambient_side_gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    // Admin intercept
    if (_emailController.text.trim() == 'admin' && _passwordController.text == '0001') {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      if (!authProvider.isProfileComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else if (mounted) {
      final rawError = authProvider.error ?? 'Invalid email or password';
      final lower = rawError.toLowerCase();
      final isInvalidCreds = lower.contains('invalid') ||
          lower.contains('credential') ||
          lower.contains('not found') ||
          lower.contains('no user');

      if (isInvalidCreds) {
        final typedEmail = _emailController.text.trim();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegisterScreen(
              initialEmail: typedEmail,
              redirectMessage: 'No account found with $typedEmail. Please sign up to create your account!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_cleanAuthError(rawError)),
            backgroundColor: AppColors.of(context).error,
          ),
        );
      }
    }
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
    if (lower.contains('invalid') &&
        (lower.contains('credential') ||
            lower.contains('login') ||
            lower.contains('password') ||
            lower.contains('grant'))) {
      return 'Invalid email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email address or try signing up.';
    }
    if (lower.contains('rate') && lower.contains('limit')) {
      return 'Too many login attempts. Please wait a minute before trying again.';
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
                  const WelcomeLogo(size: 84),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue shopping',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Glass login card
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
                                  prefixIcon: Icon(Icons.lock_outlined,
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
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Login button
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          auth.isLoading ? null : _handleLogin,
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
                                              'Sign In',
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

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.of(context).textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
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

