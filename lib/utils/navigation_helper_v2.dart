import 'package:flutter/material.dart';

/// Helper class to prevent re-entrant navigation calls
class NavigationHelper {
  static bool _isNavigating = false;
  static final Set<String> _activeDialogs = <String>{};

  /// Safe navigation pop that prevents re-entrant calls
  static void safePop(BuildContext context, [Object? result]) {
    if (_isNavigating || !context.mounted) return;

    _isNavigating = true;

    // Use addPostFrameCallback to ensure the navigation happens after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context, result);
        }
      } catch (e) {
        debugPrint('SafePop error: $e');
      } finally {
        _isNavigating = false;
      }
    });
  }

  /// Safe navigation push that prevents re-entrant calls
  static Future<T?> safePush<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (_isNavigating || !context.mounted) return null;

    _isNavigating = true;

    try {
      final result = await Navigator.push(context, route);
      return result;
    } catch (e) {
      debugPrint('SafePush error: $e');
      return null;
    } finally {
      _isNavigating = false;
    }
  }

  /// Safe dialog dismissal
  static void safePopDialog(BuildContext context, [Object? result]) {
    if (_isNavigating || !context.mounted) return;

    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(result);
        }
      } catch (e) {
        debugPrint('SafePopDialog error: $e');
      } finally {
        _isNavigating = false;
      }
    });
  }

  /// Safe show dialog that prevents overlapping dialogs
  static Future<T?> safeShowDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    String? dialogId,
  }) async {
    if (_isNavigating || !context.mounted) return null;

    // Use a unique ID to prevent duplicate dialogs
    final id = dialogId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_activeDialogs.contains(id)) return null;

    _isNavigating = true;
    _activeDialogs.add(id);

    try {
      final result = await showDialog<T>(
        context: context,
        builder: builder,
        barrierDismissible: barrierDismissible,
      );
      return result;
    } catch (e) {
      debugPrint('SafeShowDialog error: $e');
      return null;
    } finally {
      _isNavigating = false;
      _activeDialogs.remove(id);
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
    String? sheetId,
  }) async {
    if (_isNavigating || !context.mounted) return null;

    // Use a unique ID to prevent duplicate bottom sheets
    final id = sheetId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_activeDialogs.contains(id)) return null;

    _isNavigating = true;
    _activeDialogs.add(id);

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
    } catch (e) {
      debugPrint('SafeShowModalBottomSheet error: $e');
      return null;
    } finally {
      _isNavigating = false;
      _activeDialogs.remove(id);
    }
  }

  /// Reset navigation state (use with caution)
  static void resetNavigationState() {
    _isNavigating = false;
    _activeDialogs.clear();
  }

  /// Check if navigation is currently in progress
  static bool get isNavigating => _isNavigating;

  /// Get count of active dialogs
  static int get activeDialogCount => _activeDialogs.length;
}
