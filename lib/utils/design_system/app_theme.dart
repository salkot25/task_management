import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_components.dart';
import 'app_spacing.dart';

/// 🎨 Comprehensive App Theme
/// Centralized theme management following the design patterns established
/// in the login screen and extended across the entire application
class AppTheme {
  // ==========================================
  // LIGHT THEME
  // ==========================================

  static ThemeData get lightTheme => ThemeData(
    // Core theme setup
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Typography
    textTheme: AppTypography.defaultTextTheme,

    // App Bar Theme following login screen principles
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightColorScheme.surface,
      foregroundColor: AppColors.lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.lightColorScheme.onSurface,
        fontWeight: AppTypography.semiBold,
      ),
      toolbarTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightColorScheme.onSurface,
      ),
    ),

    // Elevated Button Theme following login screen pattern
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppComponents.primaryButtonStyle(
        colorScheme: AppColors.lightColorScheme,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppComponents.secondaryButtonStyle(
        colorScheme: AppColors.lightColorScheme,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: AppComponents.textButtonStyle(
        colorScheme: AppColors.lightColorScheme,
      ),
    ),

    // Input Decoration Theme following login screen pattern
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(
          color: AppColors.lightColorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.lightColorScheme.error),
      ),
      filled: true,
      fillColor: AppColors.lightColorScheme.surface,
      contentPadding: AppSpacing.inputFieldPadding,
      labelStyle: AppTypography.inputLabel.copyWith(
        color: AppColors.lightColorScheme.onSurfaceVariant,
      ),
      hintStyle: AppTypography.inputHint.copyWith(
        color: AppColors.lightColorScheme.onSurfaceVariant,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightColorScheme.primary,
      foregroundColor: AppColors.lightColorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.largeBorderRadius,
      ),
      elevation: 4.0,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.standardBorderRadius,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.lightColorScheme.surface,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.standardBorderRadius,
      ),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.lightColorScheme.onSurface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightColorScheme.onSurface,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightColorScheme.surface,
      selectedItemColor: AppColors.lightColorScheme.primary,
      unselectedItemColor: AppColors.lightColorScheme.onSurfaceVariant
          .withValues(alpha: 0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: AppTypography.labelMedium.copyWith(
        fontWeight: AppTypography.semiBold,
      ),
      unselectedLabelStyle: AppTypography.labelMedium,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.lightColorScheme.outline.withValues(alpha: 0.3),
      thickness: 1.0,
      space: 1.0,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.lightColorScheme.primary;
        }
        return AppColors.lightColorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.lightColorScheme.primary.withValues(alpha: 0.3);
        }
        return AppColors.lightColorScheme.outline.withValues(alpha: 0.3);
      }),
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightColorScheme.inverseSurface,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightColorScheme.onInverseSurface,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.smallBorderRadius,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==========================================
  // DARK THEME
  // ==========================================

  static ThemeData get darkTheme => ThemeData(
    // Core theme setup
    useMaterial3: true,
    colorScheme: AppColors.darkColorScheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Typography
    textTheme: AppTypography.defaultTextTheme.apply(
      bodyColor: AppColors.darkColorScheme.onSurface,
      displayColor: AppColors.darkColorScheme.onSurface,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkColorScheme.surface,
      foregroundColor: AppColors.darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.darkColorScheme.onSurface,
        fontWeight: AppTypography.semiBold,
      ),
      toolbarTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkColorScheme.onSurface,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppComponents.primaryButtonStyle(
        colorScheme: AppColors.darkColorScheme,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppComponents.secondaryButtonStyle(
        colorScheme: AppColors.darkColorScheme,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: AppComponents.textButtonStyle(
        colorScheme: AppColors.darkColorScheme,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.darkColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(
          color: AppColors.darkColorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppComponents.standardBorderRadius,
        borderSide: BorderSide(color: AppColors.darkColorScheme.error),
      ),
      filled: true,
      fillColor: AppColors.darkColorScheme.surface,
      contentPadding: AppSpacing.inputFieldPadding,
      labelStyle: AppTypography.inputLabel.copyWith(
        color: AppColors.darkColorScheme.onSurfaceVariant,
      ),
      hintStyle: AppTypography.inputHint.copyWith(
        color: AppColors.darkColorScheme.onSurfaceVariant,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkColorScheme.primary,
      foregroundColor: AppColors.darkColorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.largeBorderRadius,
      ),
      elevation: 4.0,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.standardBorderRadius,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.darkColorScheme.surface,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.standardBorderRadius,
      ),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.darkColorScheme.onSurface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkColorScheme.onSurface,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkColorScheme.surface,
      selectedItemColor: AppColors.darkColorScheme.primary,
      unselectedItemColor: AppColors.darkColorScheme.onSurfaceVariant
          .withValues(alpha: 0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: AppTypography.labelMedium.copyWith(
        fontWeight: AppTypography.semiBold,
      ),
      unselectedLabelStyle: AppTypography.labelMedium,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.darkColorScheme.outline.withValues(alpha: 0.3),
      thickness: 1.0,
      space: 1.0,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkColorScheme.primary;
        }
        return AppColors.darkColorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkColorScheme.primary.withValues(alpha: 0.3);
        }
        return AppColors.darkColorScheme.outline.withValues(alpha: 0.3);
      }),
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkColorScheme.inverseSurface,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkColorScheme.onInverseSurface,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppComponents.smallBorderRadius,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ==========================================
  // THEME HELPERS
  // ==========================================

  /// Get appropriate theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get color scheme from context
  static ColorScheme colorSchemeOf(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  /// Get text theme from context
  static TextTheme textThemeOf(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}
