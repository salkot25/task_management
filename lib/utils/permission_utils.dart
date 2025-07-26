import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:clarity/features/settings/data/services/permission_service.dart';

/// Utility class for handling app permissions with UI feedback
class PermissionUtils {
  /// Request camera permission for taking photos
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Camera Permission',
        'Camera access is required to take photos. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request photo library permission for selecting images
  static Future<bool> requestPhotosPermission(BuildContext context) async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Photos Permission',
        'Photo library access is required to select images. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request notification permission for task reminders
  static Future<bool> requestNotificationPermission(
    BuildContext context,
  ) async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Notification Permission',
        'Notifications are required for task reminders. Please enable them in Settings.',
      );
    }
    return false;
  }

  /// Request location permission for location-based features
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Location Permission',
        'Location access is required for location-based features. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request storage permission for file operations
  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Storage Permission',
        'Storage access is required to save files. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request calendar permission for task scheduling
  static Future<bool> requestCalendarPermission(BuildContext context) async {
    final status = await Permission.calendar.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Calendar Permission',
        'Calendar access is required to sync tasks. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request microphone permission for voice notes
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Microphone Permission',
        'Microphone access is required for voice notes. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Request contacts permission for sharing features
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final status = await Permission.contacts.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        context,
        'Contacts Permission',
        'Contacts access is required for sharing features. Please enable it in Settings.',
      );
    }
    return false;
  }

  /// Check if a permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Get permission status as user-friendly text
  static String getPermissionStatusText(PermissionStatus status) {
    return PermissionService.getPermissionStatusText(status);
  }

  /// Show permission denied dialog with option to open settings
  static void _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check multiple permissions at once
  static Future<Map<Permission, bool>> checkMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final results = <Permission, bool>{};

    for (final permission in permissions) {
      results[permission] = await isPermissionGranted(permission);
    }

    return results;
  }

  /// Request all essential permissions
  static Future<bool> requestEssentialPermissions(BuildContext context) async {
    final essentialPermissions = [Permission.notification];

    bool allGranted = true;

    for (final permission in essentialPermissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        allGranted = false;
      }
    }

    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some essential permissions were denied'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return allGranted;
  }

  /// Get permission icon based on permission type
  static IconData getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.photos:
        return Icons.photo_library;
      case Permission.notification:
        return Icons.notifications;
      case Permission.storage:
        return Icons.storage;
      case Permission.location:
      case Permission.locationWhenInUse:
        return Icons.location_on;
      case Permission.calendar:
        return Icons.calendar_today;
      case Permission.contacts:
        return Icons.contacts;
      case Permission.microphone:
        return Icons.mic;
      case Permission.phone:
        return Icons.phone;
      default:
        return Icons.security;
    }
  }
}
