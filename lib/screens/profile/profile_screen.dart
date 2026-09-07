import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/orders/order_history_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final profile = auth.profile;
          final userMeta = auth.user?.userMetadata;
          final avatarUrl = profile?.avatarUrl ?? userMeta?['avatar_url'] ?? userMeta?['picture'];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar & Name
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.of(context).primary, AppColors.of(context).accent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.of(context).primary.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            image: avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarUrl == null
                              ? Center(
                                  child: Text(
                                    (profile?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (auth.isAdmin)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?.fullName ?? 'User',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.user?.email ?? '',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                    if (profile?.discordUsername != null && profile!.discordUsername!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.discord, size: 16, color: AppColors.of(context).primary),
                            SizedBox(width: 4),
                            Text(
                              profile.discordUsername!,
                              style: TextStyle(color: AppColors.of(context).primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Country / Currency Section
              _buildSectionTitle(context, 'Region & Currency'),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: GlassDecoration(context: context),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCountryOption(
                            context: context,
                            label: '🇧🇩 Bangladesh',
                            subtitle: 'BDT ৳',
                            isSelected: auth.country == 'BD',
                            onTap: () => auth.updateCountry('BD'),
                          ),
                        ),
                        Expanded(
                          child: _buildCountryOption(
                            context: context,
                            label: '🌍 International',
                            subtitle: 'USD \$',
                            isSelected: auth.country != 'BD',
                            onTap: () => auth.updateCountry('OTHER'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Preferences Section
              _buildSectionTitle(context, 'Preferences'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: GlassDecoration(context: context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select Theme',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headlineLarge?.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: AppTheme.themePalettes.keys.length,
                        itemBuilder: (context, index) {
                          final themeId = AppTheme.themePalettes.keys.elementAt(index);
                          final colors = AppTheme.themePalettes[themeId]!;
                          final isSelected = themeProvider.currentThemeId == themeId;
                          
                          return GestureDetector(
                            onTap: () => themeProvider.setTheme(themeId),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 72,
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: colors.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [colors.primary, colors.accent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: colors.surface, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    themeId,
                                    style: TextStyle(
                                      color: isSelected ? colors.primary : Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Account Menu
              _buildSectionTitle(context, 'Account'),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                isLight: !themeProvider.isDarkMode,
                icon: Icons.receipt_long_outlined,
                title: 'Order History',
                subtitle: 'View your past orders',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                isLight: !themeProvider.isDarkMode,
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your information',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 28),

              _buildSectionTitle(context, 'App'),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                isLight: !themeProvider.isDarkMode,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'NIS Digital Store v1.0.0',
                onTap: () {},
              ),
              const SizedBox(height: 28),

              // Sign Out
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: Icon(Icons.logout, color: AppColors.of(context).error),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.of(context).error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.of(context).error.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.of(context).textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCountryOption({
    required BuildContext context,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.of(context).primary : Theme.of(context).textTheme.headlineLarge?.color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? AppColors.of(context).primary.withValues(alpha: 0.7)
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required bool isLight,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: GlassDecoration(context: context),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.of(context).primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.of(context).textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

