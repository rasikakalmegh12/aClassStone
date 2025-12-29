import 'package:flutter/material.dart';

/// App Colors - Eye-catching colors for AP Class Stones marketing app
class AppColors {
  // Primary Brand Colors
  static const Color primaryGold = Color(0xFFDAA520);
  static const Color primaryGoldDark = Color(0xFFB8860B);
  static const Color primaryGoldLight = Color(0xFFFFD700);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlueLight = Color(0xFF3B82F6);
  static const Color secondaryBlueDark = Color(0xFF1E40AF);

  // Primary Teal & Deep Blue (as per wireframes)
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryTealDark = Color(0xFF0F766E);
  static const Color primaryTealLight = Color(0xFF5EEAD4);
  static const Color primaryDeepBlue = Color(0xFF0F172A);
  static const Color primaryDeepBlueLight = Color(0xFF1E293B);

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF6F7FB); // Main background as per wireframes
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textLight = Color(0xFF64748B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral gradients (existing)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGoldLight, primaryGold, primaryGoldDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeepBlue, primaryDeepBlueLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGoldLight, primaryGold, primaryGoldDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grey50, white],
  );

  static const LinearGradient backgroundGradient2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.grey100,grey50,],
  );

  // Card & Surface Colors
  static const Color cardBackground = white;
  static const Color surfaceBackground = grey50;
  static const Color divider = grey200;

  // Additional text colors for consistency
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = white;

  // -------------------------
  // SuperAdmin palette (new)
  // A designated color set for Super Admin screens. These are additive and do
  // not replace existing app colors. Use these in Super Admin UI only.
  // -------------------------
  static const Color superAdminPrimary = Color(0xFF0B3566); // deep indigo-blue
  static const Color superAdminPrimaryDark = Color(0xFF07243F);
  static const Color superAdminPrimaryLight = Color(0xFF516679);
  static const Color superAdminLight = Color(0xFFBCD7FF);
  static const Color superAdminAccent = Color(0xFFFFB627); // warm gold accent
  static const Color superAdminCard = Color(0xFFF4F8FF);

  static const LinearGradient superAdminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [superAdminPrimary, superAdminPrimaryDark],
  );
}

/// Color Scheme Extensions
extension AppColorScheme on ColorScheme {
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primaryGold,
    brightness: Brightness.light,
    primary: AppColors.primaryGold,
    secondary: AppColors.secondaryBlue,
    tertiary: AppColors.accentOrange,
    surface: AppColors.white,
    error: AppColors.error,
  );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primaryGold,
    brightness: Brightness.dark,
    primary: AppColors.primaryGoldLight,
    secondary: AppColors.secondaryBlueLight,
    tertiary: AppColors.accentOrange,
    surface: AppColors.grey800,
    error: AppColors.error,
  );
}
