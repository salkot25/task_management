import 'package:flutter/material.dart';

/// ✏️ Design System Typography
/// Consistent typography scale following the login screen design patterns
/// and Material Design 3 typography guidelines
class AppTypography {
  // ==========================================
  // FONT FAMILY
  // ==========================================

  /// Default font family for the app
  static const String defaultFontFamily = 'System'; // Uses system font

  // ==========================================
  // FONT WEIGHTS
  // ==========================================

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ==========================================
  // LOGIN SCREEN TYPOGRAPHY
  // ==========================================

  /// Main title style (TASKS MANAGEMENT)
  static const TextStyle loginTitle = TextStyle(
    fontSize: 28.0,
    fontWeight: semiBold, // w600
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Subtitle style (Sign in to continue)
  static const TextStyle loginSubtitle = TextStyle(
    fontSize: 16.0,
    fontWeight: regular, // w400
    height: 1.4,
  );

  /// Input field label style
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: medium, // w500
    height: 1.4,
  );

  /// Input field hint style
  static const TextStyle inputHint = TextStyle(
    fontSize: 14.0,
    fontWeight: regular, // w400
    height: 1.4,
  );

  /// Primary button text style
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16.0,
    fontWeight: semiBold, // w600
    height: 1.2,
  );

  /// Secondary button text style
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16.0,
    fontWeight: medium, // w500
    height: 1.2,
  );

  /// Link text style (Forgot Password, Sign up)
  static const TextStyle linkText = TextStyle(
    fontSize: 14.0,
    fontWeight: medium, // w500
    height: 1.4,
  );

  /// Divider text style (or continue with)
  static const TextStyle dividerText = TextStyle(
    fontSize: 12.0,
    fontWeight: medium, // w500
    height: 1.4,
  );

  /// Body text style
  static const TextStyle bodyText = TextStyle(
    fontSize: 14.0,
    fontWeight: regular, // w400
    height: 1.4,
  );

  // ==========================================
  // MATERIAL DESIGN 3 TYPOGRAPHY SCALE
  // ==========================================

  /// Display styles for large text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0,
    fontWeight: regular,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45.0,
    fontWeight: regular,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36.0,
    fontWeight: regular,
    height: 1.22,
  );

  /// Headline styles for titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: regular,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: semiBold, // w600 - used in login title
    height: 1.29,
    letterSpacing: 0.5,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: regular,
    height: 1.33,
  );

  /// Title styles for headers
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: regular,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: medium, // w500
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: medium, // w500
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Label styles for buttons and tabs
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: medium, // w500
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: medium, // w500
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: medium, // w500
    height: 1.45,
    letterSpacing: 0.5,
  );

  /// Body styles for content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: regular, // w400
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: regular, // w400
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: regular, // w400
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply font weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply font size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create TextTheme for Material Design
  static TextTheme get defaultTextTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
}
