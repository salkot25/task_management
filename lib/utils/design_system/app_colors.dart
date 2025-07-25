import 'package:flutter/material.dart';

/// 🎨 Design System Colors
/// Centralized color management following Material Design 3 principles
/// and the established design patterns from the login screen
class AppColors {
  // ==========================================
  // PRIMARY COLOR PALETTE
  // ==========================================

  /// Main brand color - used for primary actions, logos, and key UI elements
  static const Color primarySeedColor = Color(0xFF00BCD4); // Cyan/Teal
  static const Color primaryColor = primarySeedColor;
  static const Color primaryLightColor = Color(0xFFB2EBF2);
  static const Color primaryDarkColor = Color(0xFF00838F);

  // ==========================================
  // SECONDARY COLOR PALETTE
  // ==========================================

  /// Accent colors for secondary actions and highlights
  static const Color secondaryColor = Color(0xFFFFC107); // Amber
  static const Color secondaryLightColor = Color(0xFFFFECB3);
  static const Color secondaryDarkColor = Color(0xFFFFA000);

  // ==========================================
  // SEMANTIC COLORS
  // ==========================================

  /// Error states and validation feedback
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorLightColor = Color(0xFFEF9A9A);
  static const Color errorDarkColor = Color(0xFFD32F2F);

  /// Success states and positive feedback
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successLightColor = Color(0xFFC8E6C9);
  static const Color successDarkColor = Color(0xFF2E7D32);

  /// Warning states and caution indicators
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningLightColor = Color(0xFFFFE0B2);
  static const Color warningDarkColor = Color(0xFFEF6C00);

  /// Information and neutral feedback
  static const Color infoColor = primaryColor;
  static const Color infoLightColor = primaryLightColor;
  static const Color infoDarkColor = primaryDarkColor;

  // ==========================================
  // NEUTRAL COLORS
  // ==========================================

  /// Pure colors for backgrounds and text
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

  /// Grayscale palette for subtle UI elements
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color greyLightColor = Color(0xFFE0E0E0);
  static const Color greyDarkColor = Color(0xFF616161);
  static const Color greyExtraLightColor = Color(0xFFF5F5F5);
  static const Color greyExtraDarkColor = Color(0xFF424242);

  // ==========================================
  // LOGIN SCREEN SPECIFIC COLORS
  // ==========================================

  /// Colors specifically designed for authentication screens
  static const Color loginBackgroundColor = whiteColor;
  static const Color loginCardBackgroundColor = whiteColor;
  static const Color loginInputFillColor = greyExtraLightColor;
  static const Color loginInputBorderColor = greyLightColor;
  static const Color loginInputFocusColor = primaryColor;
  static const Color loginTextPrimaryColor = blackColor;
  static const Color loginTextSecondaryColor = greyDarkColor;
  static const Color loginButtonBackgroundColor = primaryColor;
  static const Color loginButtonTextColor = whiteColor;
  static const Color loginDividerColor = greyLightColor;
  static const Color loginSocialButtonBackgroundColor = whiteColor;
  static const Color loginSocialButtonBorderColor = greyLightColor;

  // ==========================================
  // SHADOW AND OVERLAY COLORS
  // ==========================================

  /// Shadow colors for depth and elevation
  static const Color shadowLightColor = Color(0x1A000000); // 10% black
  static const Color shadowMediumColor = Color(0x33000000); // 20% black
  static const Color shadowDarkColor = Color(0x4D000000); // 30% black

  /// Overlay colors for modals and backgrounds
  static const Color overlayLightColor = Color(0x80FFFFFF); // 50% white
  static const Color overlayDarkColor = Color(0x80000000); // 50% black

  // ==========================================
  // GRADIENT COLORS
  // ==========================================

  /// Gradient definitions for modern UI elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDarkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [whiteColor, greyExtraLightColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Get color with opacity using the new withValues method
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get appropriate text color based on background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? blackColor : whiteColor;
  }

  /// Get contrast color for better accessibility
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? blackColor : whiteColor;
  }

  // ==========================================
  // COLOR SCHEMES
  // ==========================================

  /// Light color scheme for Material Design 3
  static ColorScheme get lightColorScheme =>
      ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: whiteColor,
        onSurface: blackColor,
        surfaceContainerHighest: greyExtraLightColor,
        onSurfaceVariant: greyDarkColor,
        outline: greyLightColor,
        shadow: shadowMediumColor,
      );

  /// Dark color scheme for Material Design 3
  static ColorScheme get darkColorScheme =>
      ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryLightColor,
        secondary: secondaryLightColor,
        error: errorLightColor,
        surface: greyExtraDarkColor,
        onSurface: whiteColor,
        surfaceContainerHighest: greyDarkColor,
        onSurfaceVariant: greyLightColor,
        outline: greyColor,
        shadow: shadowDarkColor,
      );
}
