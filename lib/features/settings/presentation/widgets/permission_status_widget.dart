import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clarity/features/settings/data/services/permission_service.dart';
import 'package:clarity/utils/design_system/design_system.dart';

class PermissionStatusWidget extends StatefulWidget {
  const PermissionStatusWidget({super.key});

  @override
  State<PermissionStatusWidget> createState() => _PermissionStatusWidgetState();
}

class _PermissionStatusWidgetState extends State<PermissionStatusWidget> {
  final Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    final essentialPermissions = [
      Permission.notification,
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ];

    try {
      for (final permission in essentialPermissions) {
        final status = await PermissionService.checkPermission(permission);
        _permissionStatuses[permission] = status;
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final grantedCount = _permissionStatuses.values
        .where((status) => PermissionService.isPermissionGranted(status))
        .length;
    final totalCount = _permissionStatuses.length;

    // Handle empty permission list
    if (totalCount == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permission Status',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No permissions to monitor at this time',
                          style: AppTypography.bodyText.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Permission Status',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: grantedCount == totalCount
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$grantedCount/$totalCount',
                    style: AppTypography.bodySmall.copyWith(
                      color: grantedCount == totalCount
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Permission progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalCount > 0 ? grantedCount / totalCount : 0.0,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  grantedCount == totalCount ? Colors.green : Colors.orange,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              grantedCount == totalCount
                  ? 'All essential permissions are granted'
                  : '${totalCount - grantedCount} permissions need attention',
              style: AppTypography.bodyText.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            if (grantedCount < totalCount) ...[
              const SizedBox(height: 8),
              Text(
                'Tap "App Permissions" to manage permissions',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
