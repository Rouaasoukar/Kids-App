import 'package:flutter/material.dart';

/// Color palette for the app â€” bright, cheerful, child-friendly
class AppColors {
  // Main brand colors
  static const Color primary = Color(0xFF6C63FF); // playful purple
  static const Color secondary = Color(0xFFFF6B9D); // pink
  static const Color accent = Color(0xFFFFD93D); // sunny yellow

  // Age group colors (each group has its own feel)
  static const Color earlyGroup = Color(0xFF4CAF50); // green (3-4 years)
  static const Color middleGroup = Color(0xFF2196F3); // blue (4-7 years)
  static const Color advancedGroup = Color(0xFF9C27B0); // purple (7-16 years)

  // Backgrounds
  static const Color background = Color(0xFFF8F4FF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFEDE7FF);

  // Text
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textMedium = Color(0xFF5A5A7A);
  static const Color textLight = Color(0xFF9E9EC8);

  // Feedback
  static const Color correct = Color(0xFF4CAF50); // green = correct
  static const Color wrong = Color(0xFFFF5252); // red = wrong
  static const Color neutral = Color(0xFFBDBDBD);

  // Rewards
  static const Color star = Color(0xFFFFD93D); // gold star
  static const Color pointsBadge = Color(0xFF6C63FF);
}

/// Text styles â€” we use Nunito because it's round and easy for kids to read
class AppTextStyles {
  static const String _fontFamily = 'Nunito';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textMedium,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  // Extra large for letters shown to young kids
  static const TextStyle letterDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

/// The main Flutter ThemeData â€” applied to the whole app
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      // fontFamily: 'Nunito', // re-enable when font files are added
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // App bars are transparent with no shadow â€” we draw our own headers
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineLarge,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),

      // Cards have rounded corners and a subtle shadow
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Big rounded buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),

      // Text fields with rounded borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium,
      ),
    );
  }
}

