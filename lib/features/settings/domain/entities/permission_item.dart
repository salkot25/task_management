import 'package:permission_handler/permission_handler.dart';

class PermissionItem {
  final Permission permission;
  final String title;
  final String description;
  final String icon;
  final bool isRequired;

  const PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    this.isRequired = false,
  });
}
