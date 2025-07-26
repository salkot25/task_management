import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clarity/features/settings/data/services/permission_service.dart';
import 'package:clarity/features/settings/domain/entities/permission_item.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import 'package:go_router/go_router.dart';

class PermissionSettingsPage extends StatefulWidget {
  const PermissionSettingsPage({super.key});

  @override
  State<PermissionSettingsPage> createState() => _PermissionSettingsPageState();
}

class _PermissionSettingsPageState extends State<PermissionSettingsPage> {
  final Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);

    try {
      for (final permissionItem in PermissionService.allPermissions) {
        if (permissionItem.permission != Permission.unknown) {
          final status = await PermissionService.checkPermission(
            permissionItem.permission,
          );
          _permissionStatuses[permissionItem.permission] = status;
        }
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _requestPermission(PermissionItem permissionItem) async {
    if (permissionItem.permission == Permission.unknown) {
      // Handle biometric authentication separately
      _showBiometricDialog();
      return;
    }

    final currentStatus = _permissionStatuses[permissionItem.permission];

    if (currentStatus == PermissionStatus.permanentlyDenied) {
      _showOpenSettingsDialog(permissionItem);
      return;
    }

    final granted = await PermissionService.requestPermission(
      permissionItem.permission,
    );

    if (granted) {
      setState(() {
        _permissionStatuses[permissionItem.permission] =
            PermissionStatus.granted;
      });
      _showSuccessSnackBar('${permissionItem.title} permission granted');
    } else {
      final newStatus = await PermissionService.checkPermission(
        permissionItem.permission,
      );
      setState(() {
        _permissionStatuses[permissionItem.permission] = newStatus;
      });

      if (newStatus == PermissionStatus.permanentlyDenied) {
        _showOpenSettingsDialog(permissionItem);
      } else {
        _showErrorSnackBar('${permissionItem.title} permission denied');
      }
    }
  }

  void _showBiometricDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text(
          'Biometric authentication can be enabled in your device settings. '
          'This will allow you to unlock the app using fingerprint or face recognition.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog(PermissionItem permissionItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${permissionItem.title} Permission'),
        content: Text(
          'This permission has been permanently denied. '
          'To enable ${permissionItem.title.toLowerCase()}, please go to Settings > Apps > Clarity > Permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestAllEssentialPermissions() async {
    final essentialPermissions = PermissionService.allPermissions
        .where(
          (item) => item.isRequired && item.permission != Permission.unknown,
        )
        .map((item) => item.permission)
        .toList();

    if (essentialPermissions.isEmpty) return;

    final granted = await PermissionService.requestMultiplePermissions(
      essentialPermissions,
    );

    if (granted) {
      _showSuccessSnackBar('All essential permissions granted');
    } else {
      _showErrorSnackBar('Some essential permissions were denied');
    }

    _checkAllPermissions();
  }

  Widget _buildPermissionTile(PermissionItem permissionItem) {
    final status = _permissionStatuses[permissionItem.permission];
    final isGranted =
        status != null && PermissionService.isPermissionGranted(status);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              permissionItem.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                permissionItem.title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (permissionItem.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              permissionItem.description,
              style: AppTypography.bodyText.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isGranted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGranted ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isGranted ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status != null
                            ? PermissionService.getPermissionStatusText(status)
                            : 'Unknown',
                        style: AppTypography.bodySmall.copyWith(
                          color: isGranted ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _requestPermission(permissionItem),
          icon: Icon(
            isGranted ? Icons.settings : Icons.arrow_forward_ios,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            size: 20,
          ),
        ),
        onTap: () => _requestPermission(permissionItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'App Permissions',
          style: AppTypography.headlineSmall.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        systemOverlayStyle: isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.getHorizontalPadding(screenWidth),
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.security, size: 48, color: Colors.blue),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'App Permissions',
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Manage which permissions Clarity can access. Some features may not work properly without certain permissions.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyText.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _requestAllEssentialPermissions,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Grant Essential'),
                          style: AppComponents.primaryButtonStyle().copyWith(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _checkAllPermissions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Status'),
                          style: AppComponents.secondaryButtonStyle().copyWith(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Permissions list
                  Text(
                    'All Permissions',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: PermissionService.allPermissions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final permissionItem =
                          PermissionService.allPermissions[index];
                      return _buildPermissionTile(permissionItem);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Footer info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Privacy Notice',
                          style: AppTypography.bodyLarge.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Clarity respects your privacy. Permissions are only used for their intended features and your data is never shared with third parties.',
                          textAlign: TextAlign.center,
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
            ),
    );
  }
}
