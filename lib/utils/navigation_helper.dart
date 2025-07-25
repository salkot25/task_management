import 'package:flutter/material.dart';

/// Helper class to prevent re-entrant navigation calls
class NavigationHelper {
  static bool _isNavigating = false;

  /// Safe navigation pop that prevents re-entrant calls
  static void safePop(BuildContext context, [Object? result]) {
    if (_isNavigating) return;

    _isNavigating = true;

    // Use addPostFrameCallback to ensure the navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context, result);
      }
      _isNavigating = false;
    });
  }

  /// Safe navigation push that prevents re-entrant calls
  static Future<T?> safePush<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (_isNavigating) return null;

    _isNavigating = true;

    try {
      final result = await Navigator.push(context, route);
      return result;
    } finally {
      _isNavigating = false;
    }
  }

  /// Safe dialog dismissal
  static void safePopDialog(BuildContext context, [Object? result]) {
    if (_isNavigating) return;

    if (context.mounted) {
      _isNavigating = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(result);
        }
        _isNavigating = false;
      });
    }
  }

  /// Safe show dialog that prevents overlapping dialogs
  static Future<T?> safeShowDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    if (_isNavigating) return null;

    _isNavigating = true;

    try {
      final result = await showDialog<T>(
        context: context,
        builder: builder,
        barrierDismissible: barrierDismissible,
      );
      return result;
    } finally {
      _isNavigating = false;
    }
  }

  /// Safe show modal bottom sheet
  static Future<T?> safeShowModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) async {
    if (_isNavigating) return null;

    _isNavigating = true;

    try {
      final result = await showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        barrierLabel: barrierLabel,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        barrierColor: barrierColor,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        routeSettings: routeSettings,
        transitionAnimationController: transitionAnimationController,
        anchorPoint: anchorPoint,
      );
      return result;
    } finally {
      _isNavigating = false;
    }
  }

  /// Reset navigation state (use with caution)
  static void resetNavigationState() {
    _isNavigating = false;
  }
}
