import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/core/sync/models/sync_item.dart';
import 'package:clarity/core/sync/services/auto_sync_service.dart';
import 'package:clarity/core/sync/services/connectivity_service.dart';

/// Helper class untuk mengintegrasikan auto sync dengan berbagai provider
class OfflineDataHelper {
  /// Simpan task data untuk offline access
  static Future<void> saveTaskOffline({
    required BuildContext context,
    required String taskId,
    required Map<String, dynamic> taskData,
  }) async {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      await autoSyncService.saveOfflineData(
        entityType: 'task',
        entityId: taskId,
        data: taskData,
      );
    } catch (e) {
      debugPrint('Failed to save task offline: $e');
    }
  }

  /// Load tasks dari offline storage
  static List<Map<String, dynamic>> loadTasksOffline(BuildContext context) {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      return autoSyncService.getAllOfflineDataByType('task');
    } catch (e) {
      debugPrint('Failed to load tasks offline: $e');
      return [];
    }
  }

  /// Simpan transaction data untuk offline access
  static Future<void> saveTransactionOffline({
    required BuildContext context,
    required String transactionId,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      await autoSyncService.saveOfflineData(
        entityType: 'transaction',
        entityId: transactionId,
        data: transactionData,
      );
    } catch (e) {
      debugPrint('Failed to save transaction offline: $e');
    }
  }

  /// Load transactions dari offline storage
  static List<Map<String, dynamic>> loadTransactionsOffline(
    BuildContext context,
  ) {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      return autoSyncService.getAllOfflineDataByType('transaction');
    } catch (e) {
      debugPrint('Failed to load transactions offline: $e');
      return [];
    }
  }

  /// Simpan account data untuk offline access
  static Future<void> saveAccountOffline({
    required BuildContext context,
    required String accountId,
    required Map<String, dynamic> accountData,
  }) async {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      await autoSyncService.saveOfflineData(
        entityType: 'account',
        entityId: accountId,
        data: accountData,
      );
    } catch (e) {
      debugPrint('Failed to save account offline: $e');
    }
  }

  /// Load accounts dari offline storage
  static List<Map<String, dynamic>> loadAccountsOffline(BuildContext context) {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      return autoSyncService.getAllOfflineDataByType('account');
    } catch (e) {
      debugPrint('Failed to load accounts offline: $e');
      return [];
    }
  }

  /// Add any operation to sync queue
  static Future<void> addOperationToSync({
    required BuildContext context,
    required SyncEntityType entityType,
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
    String? customId,
  }) async {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      await autoSyncService.addToSyncQueue(
        entityType: entityType,
        operationType: operationType,
        data: data,
        customId: customId,
      );
    } catch (e) {
      debugPrint('Failed to add operation to sync queue: $e');
    }
  }

  /// Check connectivity status
  static bool isOnline(BuildContext context) {
    try {
      final connectivityService = context.read<ConnectivityService>();
      return connectivityService.isConnected;
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      return true; // Assume online if service not available
    }
  }

  /// Get sync queue status for debugging
  static Map<String, dynamic> getSyncStatus(BuildContext context) {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      return autoSyncService.getSyncQueueStatus();
    } catch (e) {
      debugPrint('Failed to get sync status: $e');
      return {};
    }
  }
}
