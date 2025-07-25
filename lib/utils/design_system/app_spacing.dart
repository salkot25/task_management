import 'package:flutter/material.dart';

/// 📐 Design System Spacing
/// Consistent spacing values following 8px grid system
/// used throughout the login screen and entire app
class AppSpacing {
  // ==========================================
  // BASE GRID SYSTEM (8px)
  // ==========================================

  /// Base unit for all spacing calculations
  static const double baseUnit = 8.0;

  // ==========================================
  // SPACING SCALE
  // ==========================================

  /// Extra small spacing (4px) - tight spacing
  static const double xs = baseUnit * 0.5; // 4px

  /// Small spacing (8px) - base unit
  static const double sm = baseUnit; // 8px

  /// Medium spacing (16px) - comfortable spacing
  static const double md = baseUnit * 2; // 16px

  /// Large spacing (24px) - section spacing
  static const double lg = baseUnit * 3; // 24px

  /// Extra large spacing (32px) - page spacing
  static const double xl = baseUnit * 4; // 32px

  /// 2X large spacing (40px) - major section spacing
  static const double xxl = baseUnit * 5; // 40px

  /// 3X large spacing (48px) - page margins
  static const double xxxl = baseUnit * 6; // 48px

  // ==========================================
  // LOGIN SCREEN SPECIFIC SPACING
  // ==========================================

  /// Spacing used specifically in authentication screens
  static const double loginLogoBottomSpacing = lg; // 24px
  static const double loginTitleBottomSpacing = sm; // 8px
  static const double loginSubtitleBottomSpacing = xl; // 32px
  static const double loginInputSpacing = md; // 16px (updated from 20px)
  static const double loginButtonTopSpacing = xl; // 32px
  static const double loginDividerSpacing = xl; // 32px
  static const double loginSocialButtonSpacing = lg; // 24px
  static const double loginBottomLinkSpacing = xl; // 32px

  /// Container padding for different screen sizes
  static const double loginPaddingMobile = lg; // 24px
  static const double loginPaddingTablet = xxxl; // 48px

  /// Maximum width for form containers
  static const double loginMaxWidthTablet = 400.0;

  // ==========================================
  // COMPONENT SPACING
  // ==========================================

  /// Button internal padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: md, // 16px
    horizontal: lg, // 24px
  );

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md); // 16px

  /// Input field padding
  static const EdgeInsets inputFieldPadding = EdgeInsets.symmetric(
    vertical: md, // 16px
    horizontal: md, // 16px
  );

  /// Page padding for mobile
  static const EdgeInsets pagePaddingMobile = EdgeInsets.all(lg); // 24px

  /// Page padding for tablet
  static const EdgeInsets pagePaddingTablet = EdgeInsets.all(xxxl); // 48px

  // ==========================================
  // RESPONSIVE SPACING HELPERS
  // ==========================================

  /// Get appropriate page padding based on screen width
  static EdgeInsets getPagePadding(double screenWidth) {
    return screenWidth > 600 ? pagePaddingTablet : pagePaddingMobile;
  }

  /// Get appropriate horizontal padding based on screen width
  static double getHorizontalPadding(double screenWidth) {
    return screenWidth > 600 ? loginPaddingTablet : loginPaddingMobile;
  }

  /// Get appropriate container width based on screen width
  static double getContainerWidth(double screenWidth) {
    return screenWidth > 600 ? loginMaxWidthTablet : double.infinity;
  }
}
