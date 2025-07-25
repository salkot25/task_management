/// 🎨 Design System Export
/// Centralized export file for all design system components
/// This allows easy import of the entire design system with a single import

// Core design system components
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_components.dart';
export 'app_theme.dart';

/// Design System Usage:
/// 
/// ```dart
/// import 'package:myapp/utils/design_system/design_system.dart';
/// 
/// // Use anywhere in your app:
/// Container(
///   padding: AppSpacing.pagePaddingMobile,
///   decoration: AppComponents.cardDecoration(),
///   child: Text(
///     'Hello World',
///     style: AppTypography.headlineMedium.copyWith(
///       color: AppColors.primaryColor,
///     ),
///   ),
/// )
/// ```
