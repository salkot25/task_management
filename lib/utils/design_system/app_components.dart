import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// 🎨 Design System Components
/// Pre-defined component styles following the login screen design patterns
/// These components ensure consistency across the entire application
class AppComponents {
  // ==========================================
  // BORDER RADIUS CONSTANTS
  // ==========================================

  /// Standard border radius used throughout the app
  static const double standardRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 20.0;

  /// Border radius definitions
  static const BorderRadius standardBorderRadius = BorderRadius.all(
    Radius.circular(standardRadius),
  );
  static const BorderRadius smallBorderRadius = BorderRadius.all(
    Radius.circular(smallRadius),
  );
  static const BorderRadius largeBorderRadius = BorderRadius.all(
    Radius.circular(largeRadius),
  );

  // ==========================================
  // INPUT FIELD DECORATION
  // ==========================================

  /// Standard input decoration following login screen pattern
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
    ColorScheme? colorScheme,
  }) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      // Border styles following login screen pattern
      border: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: standardBorderRadius,
        borderSide: BorderSide(color: scheme.error, width: 2.0),
      ),

      // Fill and padding
      filled: true,
      fillColor: scheme.surface,
      contentPadding: AppSpacing.inputFieldPadding,

      // Label and hint styles
      labelStyle: AppTypography.inputLabel.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      hintStyle: AppTypography.inputHint.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  /// Email input decoration with icon
  static InputDecoration emailInputDecoration({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return inputDecoration(
      labelText: 'Email Address',
      hintText: 'Enter your email',
      prefixIcon: Icon(Icons.email_outlined, color: scheme.onSurfaceVariant),
      colorScheme: scheme,
    );
  }

  /// Password input decoration with toggle visibility
  static InputDecoration passwordInputDecoration({
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    ColorScheme? colorScheme,
  }) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return inputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: scheme.onSurfaceVariant,
        ),
        onPressed: onToggleVisibility,
        splashRadius: 20.0,
        tooltip: isPasswordVisible ? 'Hide password' : 'Show password',
      ),
      colorScheme: scheme,
    );
  }

  // ==========================================
  // BUTTON STYLES
  // ==========================================

  /// Primary button style following login screen pattern
  static ButtonStyle primaryButtonStyle({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return ElevatedButton.styleFrom(
      padding: AppSpacing.buttonPadding,
      shape: const RoundedRectangleBorder(borderRadius: standardBorderRadius),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: AppTypography.buttonPrimary,
    );
  }

  /// Secondary button style (outlined)
  static ButtonStyle secondaryButtonStyle({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return OutlinedButton.styleFrom(
      padding: AppSpacing.buttonPadding,
      shape: const RoundedRectangleBorder(borderRadius: standardBorderRadius),
      side: BorderSide(color: scheme.outline),
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      textStyle: AppTypography.buttonSecondary,
    );
  }

  /// Text button style for links
  static ButtonStyle textButtonStyle({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      foregroundColor: scheme.primary,
      textStyle: AppTypography.linkText,
    );
  }

  // ==========================================
  // LOADING INDICATORS
  // ==========================================

  /// Loading button container following login screen pattern
  static Widget loadingButton({
    ColorScheme? colorScheme,
    double height = 52.0,
  }) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: standardBorderRadius,
        color: scheme.primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: SizedBox(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DIVIDERS AND SEPARATORS
  // ==========================================

  /// Divider with text following login screen pattern
  static Widget dividerWithText({
    required String text,
    ColorScheme? colorScheme,
  }) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.0,
            color: scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            text,
            style: AppTypography.dividerText.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.0,
            color: scheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARDS AND CONTAINERS
  // ==========================================

  /// Standard card decoration
  static BoxDecoration cardDecoration({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return BoxDecoration(
      color: scheme.surface,
      borderRadius: standardBorderRadius,
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Form container decoration following login screen pattern
  static BoxDecoration formContainerDecoration({ColorScheme? colorScheme}) {
    final scheme = colorScheme ?? AppColors.lightColorScheme;

    return BoxDecoration(
      color: scheme.surface,
      borderRadius: standardBorderRadius,
    );
  }

  // ==========================================
  // NAVIGATION ITEMS
  // ==========================================

  /// Navigation item icon with animation (from bottom nav refactoring)
  static Widget animatedNavIcon({
    required IconData iconData,
    required bool isSelected,
    required ColorScheme colorScheme,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: isSelected
          ? BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(
                Radius.circular(largeRadius),
              ),
            )
          : null,
      child: Icon(
        iconData,
        color: isSelected
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        size: 24.0,
      ),
    );
  }

  // ==========================================
  // RESPONSIVE HELPERS
  // ==========================================

  /// Get appropriate decoration based on screen size
  static BoxDecoration responsiveContainer({
    required double screenWidth,
    ColorScheme? colorScheme,
  }) {
    return BoxDecoration(
      color: (colorScheme ?? AppColors.lightColorScheme).surface,
      borderRadius: screenWidth > 600 ? standardBorderRadius : null,
    );
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets responsivePadding(double screenWidth) {
    return EdgeInsets.symmetric(
      horizontal: AppSpacing.getHorizontalPadding(screenWidth),
      vertical: AppSpacing.lg,
    );
  }
}
