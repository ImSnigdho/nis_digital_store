import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textColor;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color warning;
  final Color glassBg;
  final Color glassBorder;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textColor,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.warning,
    required this.glassBg,
    required this.glassBorder,
  });

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!.colors;
  }
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final AppColors colors;

  AppColorsExtension(this.colors);

  @override
  ThemeExtension<AppColorsExtension> copyWith({AppColors? colors}) {
    return AppColorsExtension(colors ?? this.colors);
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      AppColors(
        primary: Color.lerp(colors.primary, other.colors.primary, t)!,
        secondary: Color.lerp(colors.secondary, other.colors.secondary, t)!,
        accent: Color.lerp(colors.accent, other.colors.accent, t)!,
        background: Color.lerp(colors.background, other.colors.background, t)!,
        surface: Color.lerp(colors.surface, other.colors.surface, t)!,
        textColor: Color.lerp(colors.textColor, other.colors.textColor, t)!,
        textSecondary: Color.lerp(colors.textSecondary, other.colors.textSecondary, t)!,
        error: Color.lerp(colors.error, other.colors.error, t)!,
        success: Color.lerp(colors.success, other.colors.success, t)!,
        warning: Color.lerp(colors.warning, other.colors.warning, t)!,
        glassBg: Color.lerp(colors.glassBg, other.colors.glassBg, t)!,
        glassBorder: Color.lerp(colors.glassBorder, other.colors.glassBorder, t)!,
      ),
    );
  }
}

class AppTheme {
  static const Map<String, AppColors> themePalettes = {
    'Light': AppColors(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF64748B),
      accent: Color(0xFF06B6D4),
      background: Color(0xFFF1F5F9),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
      error: Color(0xFFEF4444),
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x33000000),
    ),
    'Dark': AppColors(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF64748B),
      accent: Color(0xFF06B6D4),
      background: Color(0xFF0F172A),
      surface: Color(0xFF1E293B),
      textColor: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      error: Color(0xFFEF4444),
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0x1AFFFFFF),
      glassBorder: Color(0x33FFFFFF),
    ),
    'Grey': AppColors(
      primary: Color(0xFF4B5563),
      secondary: Color(0xFF9CA3AF),
      accent: Color(0xFF6B7280),
      background: Color(0xFF111827),
      surface: Color(0xFF1F2937),
      textColor: Color(0xFFF3F4F6),
      textSecondary: Color(0xFFD1D5DB),
      error: Color(0xFFEF4444),
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0x1AFFFFFF),
      glassBorder: Color(0x33FFFFFF),
    ),
    'Ocean': AppColors(
      primary: Color(0xFF0284C7),
      secondary: Color(0xFF0369A1),
      accent: Color(0xFF0EA5E9),
      background: Color(0xFFF0F9FF),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF0C4A6E),
      textSecondary: Color(0xFF0284C7),
      error: Color(0xFFE11D48),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x330284C7),
    ),
    'Pearl': AppColors(
      primary: Color(0xFFD4A373),
      secondary: Color(0xFFFAEDCD),
      accent: Color(0xFFFEFAE0),
      background: Color(0xFFFEFAE0),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF5E503F),
      textSecondary: Color(0xFF8B7D6B),
      error: Color(0xFFE63946),
      success: Color(0xFF2A9D8F),
      warning: Color(0xFFE9C46A),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x33D4A373),
    ),
    'Forest': AppColors(
      primary: Color(0xFF059669),
      secondary: Color(0xFF10B981),
      accent: Color(0xFF34D399),
      background: Color(0xFF064E3B),
      surface: Color(0xFF065F46),
      textColor: Color(0xFFECFDF5),
      textSecondary: Color(0xFFA7F3D0),
      error: Color(0xFFEF4444),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0x1AFFFFFF),
      glassBorder: Color(0x33FFFFFF),
    ),
    'Sunset': AppColors(
      primary: Color(0xFFEA580C),
      secondary: Color(0xFFF97316),
      accent: Color(0xFFFB923C),
      background: Color(0xFFFFF7ED),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF7C2D12),
      textSecondary: Color(0xFFC2410C),
      error: Color(0xFFDC2626),
      success: Color(0xFF16A34A),
      warning: Color(0xFFD97706),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x33EA580C),
    ),
    'Midnight': AppColors(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF4F46E5),
      accent: Color(0xFF818CF8),
      background: Color(0xFF020617),
      surface: Color(0xFF0F172A),
      textColor: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      error: Color(0xFFEF4444),
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0x1AFFFFFF),
      glassBorder: Color(0x33FFFFFF),
    ),
    'Cyberpunk': AppColors(
      primary: Color(0xFFF43F5E),
      secondary: Color(0xFFE11D48),
      accent: Color(0xFF10B981),
      background: Color(0xFF000000),
      surface: Color(0xFF121212),
      textColor: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF9CA3AF),
      error: Color(0xFFEF4444),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      glassBg: Color(0x1AFFFFFF),
      glassBorder: Color(0x33F43F5E),
    ),
    'Rose': AppColors(
      primary: Color(0xFFE11D48),
      secondary: Color(0xFFF43F5E),
      accent: Color(0xFFFDA4AF),
      background: Color(0xFFFFF1F2),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF881337),
      textSecondary: Color(0xFFBE123C),
      error: Color(0xFFB91C1C),
      success: Color(0xFF15803D),
      warning: Color(0xFFB45309),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x33E11D48),
    ),
    'Lavender': AppColors(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFF7C3AED),
      accent: Color(0xFFA78BFA),
      background: Color(0xFFF5F3FF),
      surface: Color(0xFFFFFFFF),
      textColor: Color(0xFF4C1D95),
      textSecondary: Color(0xFF6D28D9),
      error: Color(0xFFDC2626),
      success: Color(0xFF16A34A),
      warning: Color(0xFFD97706),
      glassBg: Color(0xB3FFFFFF),
      glassBorder: Color(0x338B5CF6),
    ),
  };

  static ThemeData getTheme(String themeId) {
    final colors = themePalettes[themeId] ?? themePalettes['Light']!;
    final isDark = colors.background.computeLuminance() < 0.5;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textColor,
      ),
      extensions: [AppColorsExtension(colors)],
      textTheme: GoogleFonts.interTextTheme(
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
              headlineLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
                letterSpacing: -0.5,
              ),
              headlineMedium: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
                letterSpacing: -0.3,
              ),
              headlineSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
              titleLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
              titleMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textColor,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: colors.textColor,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
              bodySmall: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
              labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
        ),
        iconTheme: IconThemeData(color: colors.textColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

class GlassDecoration extends BoxDecoration {
  GlassDecoration({
    double borderRadius = 16,
    Color? color,
    required BuildContext context,
  }) : super(
          color: color ?? AppColors.of(context).glassBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.of(context).glassBorder, width: 0.5),
        );
}
