import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:clarity/features/settings/domain/entities/permission_item.dart';

class PermissionService {
  static List<PermissionItem> get allPermissions => [
    // Essential permissions
    const PermissionItem(
      permission: Permission.camera,
      title: 'Camera',
      description:
          'Access camera to take photos for profile and task attachments',
      icon: '📷',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.photos,
      title: 'Photos',
      description:
          'Access photo library to select images for profile and tasks',
      icon: '🖼️',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.notification,
      title: 'Notifications',
      description: 'Send task reminders and important updates',
      icon: '🔔',
      isRequired: true,
    ),
    const PermissionItem(
      permission: Permission.storage,
      title: 'Storage',
      description: 'Save files and documents for task attachments',
      icon: '💾',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.location,
      title: 'Location',
      description: 'Enable location-based task reminders and geofencing',
      icon: '📍',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.locationWhenInUse,
      title: 'Location (When in Use)',
      description: 'Access location only when app is active for task features',
      icon: '📍',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.calendar,
      title: 'Calendar',
      description: 'Sync tasks with your calendar and create calendar events',
      icon: '📅',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.contacts,
      title: 'Contacts',
      description: 'Share tasks with contacts and collaborate on projects',
      icon: '👥',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.microphone,
      title: 'Microphone',
      description: 'Record voice notes and audio memos for tasks',
      icon: '🎤',
      isRequired: false,
    ),
    const PermissionItem(
      permission: Permission.phone,
      title: 'Phone',
      description: 'Access phone state for better app integration',
      icon: '📞',
      isRequired: false,
    ),
    // Biometric permission (platform specific)
    if (Platform.isAndroid || Platform.isIOS)
      const PermissionItem(
        permission: Permission.unknown, // Will handle biometric separately
        title: 'Biometric Authentication',
        description: 'Use fingerprint or face unlock for secure access',
        icon: '🔐',
        isRequired: false,
      ),
    // Background permissions
    if (Platform.isAndroid) ...[
      const PermissionItem(
        permission: Permission.scheduleExactAlarm,
        title: 'Exact Alarms',
        description: 'Set precise task reminders and notifications',
        icon: '⏰',
        isRequired: false,
      ),
      const PermissionItem(
        permission: Permission.ignoreBatteryOptimizations,
        title: 'Battery Optimization',
        description: 'Run in background for timely notifications',
        icon: '🔋',
        isRequired: false,
      ),
      const PermissionItem(
        permission: Permission.systemAlertWindow,
        title: 'Display over other apps',
        description: 'Show floating task reminders over other apps',
        icon: '📱',
        isRequired: false,
      ),
    ],
    // iOS specific permissions
    if (Platform.isIOS) ...[
      const PermissionItem(
        permission: Permission.appTrackingTransparency,
        title: 'App Tracking',
        description: 'Track app usage for better experience',
        icon: '📊',
        isRequired: false,
      ),
      const PermissionItem(
        permission: Permission.reminders,
        title: 'Reminders',
        description: 'Access iOS Reminders app for task sync',
        icon: '📝',
        isRequired: false,
      ),
    ],
  ];

  static Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = allPermissions
        .where((item) => item.permission != Permission.unknown)
        .map((item) => item.permission)
        .toList();

    return await permissions.request();
  }

  static Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  static Future<bool> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  static bool isPermissionGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }
}
