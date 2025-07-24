import 'package:flutter/material.dart';

class AppColors {
  // Define primary seed color (matching the image)
  static const Color primarySeedColor = Color(0xFF00BCD4); // Closer to the cyan/teal in the image

  // Primary Colors (derived from the seed)
  static const Color primaryColor = primarySeedColor;
  static const Color primaryLightColor = Color(0xFFB2EBF2); // Lighter shade
  static const Color primaryDarkColor = Color(0xFF00838F); // Darker shade

  // Secondary Colors (can be adjusted to complement primary, keeping current for now)
  static const Color secondaryColor = Color(0xFFFFC107); 
  static const Color secondaryLightColor = Color(0xFFFFECB3);
  static const Color secondaryDarkColor = Color(0xFFFFA000);

  // Tertiary Colors (keeping current for now)
  static const Color tertiaryColor = Color(0xFF2196F3);
  static const Color tertiaryLightColor = Color(0xFFBBDEFB);
  static const Color tertiaryDarkColor = Color(0xFF1565C0);

  // Error Colors (keeping current for now)
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorLightColor = Color(0xFFEF9A9A);
  static const Color errorDarkColor = Color(0xFFD32F2F);

  // Other Utility Colors (keeping current for now)
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = primaryColor; // Info color often matches primary

  // Neutral Colors (for text, background, border, etc.)
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color greyLightColor = Color(0xFFE0E0E0);
  static const Color greyDarkColor = Color(0xFF616161);
}
