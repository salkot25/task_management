import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/sync/services/auto_sync_service.dart';
import 'package:myapp/core/sync/services/connectivity_service.dart';
import 'package:myapp/utils/design_system/design_system.dart';

/// Widget untuk menampilkan status sync
class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({super.key, this.showDetails = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AutoSyncService, ConnectivityService>(
      builder: (context, autoSyncService, connectivityService, child) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48, // Match ActionButton height
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(
                autoSyncService,
                connectivityService,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                12,
              ), // Match ActionButton border radius
              border: Border.all(
                color: _getStatusColor(
                  autoSyncService,
                  connectivityService,
                ).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(autoSyncService, connectivityService),
                const SizedBox(width: 8),
                if (showDetails) ...[
                  Expanded(
                    child: _buildStatusText(
                      autoSyncService,
                      connectivityService,
                    ),
                  ),
                ] else ...[
                  _buildStatusText(autoSyncService, connectivityService),
                ],
                if (autoSyncService.pendingSyncCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${autoSyncService.pendingSyncCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(
    AutoSyncService autoSyncService,
    ConnectivityService connectivityService,
  ) {
    if (autoSyncService.isSyncing) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            _getStatusColor(autoSyncService, connectivityService),
          ),
        ),
      );
    }

    IconData iconData;
    if (!connectivityService.isConnected) {
      iconData = Icons.cloud_off_outlined;
    } else if (autoSyncService.pendingSyncCount > 0) {
      iconData = Icons.cloud_upload_outlined;
    } else if (autoSyncService.lastSyncError != null) {
      iconData = Icons.error_outline;
    } else {
      iconData = Icons.cloud_done_outlined;
    }

    return Icon(
      iconData,
      size: 16,
      color: _getStatusColor(autoSyncService, connectivityService),
    );
  }

  Widget _buildStatusText(
    AutoSyncService autoSyncService,
    ConnectivityService connectivityService,
  ) {
    String text;
    if (autoSyncService.isSyncing) {
      text = 'Syncing...';
    } else if (!connectivityService.isConnected) {
      text = 'Offline';
    } else if (autoSyncService.pendingSyncCount > 0) {
      text = '${autoSyncService.pendingSyncCount} pending';
    } else if (autoSyncService.lastSyncError != null) {
      text = 'Sync error';
    } else {
      text = 'Synced';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _getStatusColor(autoSyncService, connectivityService),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getStatusColor(
    AutoSyncService autoSyncService,
    ConnectivityService connectivityService,
  ) {
    if (!connectivityService.isConnected) {
      return Colors.grey;
    } else if (autoSyncService.isSyncing) {
      return AppColors.primaryColor;
    } else if (autoSyncService.pendingSyncCount > 0) {
      return AppColors.warningColor;
    } else if (autoSyncService.lastSyncError != null) {
      return AppColors.errorColor;
    } else {
      return AppColors.successColor;
    }
  }
}

/// Dialog untuk menampilkan detail sync
class SyncDetailsDialog extends StatelessWidget {
  const SyncDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AutoSyncService, ConnectivityService>(
      builder: (context, autoSyncService, connectivityService, child) {
        final status = autoSyncService.getSyncQueueStatus();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.sync, size: 24),
              SizedBox(width: 8),
              Text('Sync Status'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Connection Status
                _buildStatusRow(
                  'Connection',
                  connectivityService.isConnected ? 'Online' : 'Offline',
                  connectivityService.isConnected
                      ? AppColors.successColor
                      : AppColors.errorColor,
                ),
                const SizedBox(height: 8),

                // Auto Sync Status
                _buildStatusRow(
                  'Auto Sync',
                  autoSyncService.isAutoSyncEnabled ? 'Enabled' : 'Disabled',
                  autoSyncService.isAutoSyncEnabled
                      ? AppColors.successColor
                      : Colors.grey,
                ),
                const SizedBox(height: 8),

                // Queue Status
                _buildStatusRow(
                  'Pending Items',
                  '${status['pending']}',
                  status['pending'] > 0
                      ? AppColors.warningColor
                      : AppColors.successColor,
                ),
                const SizedBox(height: 8),

                _buildStatusRow(
                  'Total Items',
                  '${status['total']}',
                  Colors.grey[700]!,
                ),
                const SizedBox(height: 8),

                // Last Sync Time
                if (status['lastSyncTime'] != null) ...[
                  _buildStatusRow(
                    'Last Sync',
                    _formatDateTime(DateTime.parse(status['lastSyncTime'])),
                    Colors.grey[700]!,
                  ),
                  const SizedBox(height: 8),
                ],

                // Error Message
                if (status['lastSyncError'] != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Last Error:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status['lastSyncError'],
                    style: TextStyle(fontSize: 12, color: AppColors.errorColor),
                  ),
                ],

                // Entity Breakdown
                if (status['byEntity'].isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'By Entity Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...status['byEntity'].entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toString().toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (connectivityService.isConnected &&
                autoSyncService.pendingSyncCount > 0)
              ElevatedButton(
                onPressed: autoSyncService.isSyncing
                    ? null
                    : () async {
                        await autoSyncService.performManualSync();
                      },
                child: autoSyncService.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sync Now'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Bottom sheet untuk pengaturan sync
class SyncSettingsBottomSheet extends StatelessWidget {
  const SyncSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AutoSyncService, ConnectivityService>(
      builder: (context, autoSyncService, connectivityService, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sync Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Auto Sync Toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.sync,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Auto Sync'),
                subtitle: Text(
                  autoSyncService.isAutoSyncEnabled
                      ? 'Automatically sync when online'
                      : 'Manual sync only',
                ),
                trailing: Switch(
                  value: autoSyncService.isAutoSyncEnabled,
                  onChanged: connectivityService.isConnected
                      ? (_) => autoSyncService.toggleAutoSync()
                      : null,
                ),
              ),

              const Divider(),

              // Manual Sync Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.cloud_sync,
                  color: connectivityService.isConnected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: const Text('Sync Now'),
                subtitle: Text(
                  connectivityService.isConnected
                      ? 'Force sync all pending items'
                      : 'No internet connection',
                ),
                trailing:
                    connectivityService.isConnected &&
                        autoSyncService.pendingSyncCount > 0
                    ? Badge(
                        label: Text('${autoSyncService.pendingSyncCount}'),
                        child: const Icon(Icons.arrow_forward_ios),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap:
                    connectivityService.isConnected &&
                        !autoSyncService.isSyncing
                    ? () async {
                        Navigator.pop(context);
                        await autoSyncService.performManualSync();
                      }
                    : null,
              ),

              const Divider(),

              // Clear Sync Data
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outline,
                  color: AppColors.errorColor,
                ),
                title: const Text('Clear Sync Data'),
                subtitle: const Text('Remove all pending sync items'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Sync Data'),
                      content: const Text(
                        'This will remove all pending sync items. '
                        'Unsaved changes will be lost. Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorColor,
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await autoSyncService.clearAllSyncData();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sync data cleared'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
