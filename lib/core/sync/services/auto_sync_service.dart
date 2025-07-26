import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clarity/core/sync/models/sync_item.dart';
import 'package:clarity/core/sync/services/connectivity_service.dart';
import 'package:clarity/core/sync/services/local_sync_storage.dart';
import 'package:clarity/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:clarity/features/cashcard/data/repositories/transaction_repository_impl.dart';
import 'package:clarity/features/account_management/data/repositories/account_repository_impl.dart';
import 'package:uuid/uuid.dart';

/// Service utama untuk mengelola auto sync
class AutoSyncService extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  final LocalSyncStorage _localStorage;
  final ProfileRepositoryImpl? _profileRepository;
  final TransactionRepositoryImpl? _transactionRepository;
  final AccountRepositoryImpl? _accountRepository;

  Timer? _syncTimer;
  bool _isSyncing = false;
  int _pendingSyncCount = 0;
  DateTime? _lastSyncTime;
  String? _lastSyncError;

  bool get isSyncing => _isSyncing;
  int get pendingSyncCount => _pendingSyncCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncError => _lastSyncError;
  bool get isAutoSyncEnabled => _syncTimer != null;

  AutoSyncService({
    required ConnectivityService connectivityService,
    required LocalSyncStorage localStorage,
    ProfileRepositoryImpl? profileRepository,
    TransactionRepositoryImpl? transactionRepository,
    AccountRepositoryImpl? accountRepository,
  }) : _connectivityService = connectivityService,
       _localStorage = localStorage,
       _profileRepository = profileRepository,
       _transactionRepository = transactionRepository,
       _accountRepository = accountRepository {
    _initialize();
  }

  /// Inisialisasi service
  void _initialize() {
    // Listen untuk perubahan koneksi
    _connectivityService.addListener(_onConnectivityChanged);

    // Update initial count
    _updatePendingSyncCount();

    // Start auto sync if connected
    if (_connectivityService.isConnected) {
      startAutoSync();
    }
  }

  /// Callback ketika koneksi berubah
  void _onConnectivityChanged() {
    if (_connectivityService.isConnected) {
      if (kDebugMode) {
        print('Connection restored, starting sync...');
      }
      startAutoSync();
      _triggerImmediateSync();
    } else {
      if (kDebugMode) {
        print('Connection lost, stopping auto sync...');
      }
      stopAutoSync();
    }
    notifyListeners();
  }

  /// Mulai auto sync
  void startAutoSync() {
    if (_syncTimer != null) return;

    _syncTimer = Timer.periodic(
      const Duration(seconds: 30), // Sync every 30 seconds
      (_) => _performSync(),
    );

    if (kDebugMode) {
      print('Auto sync started');
    }
    notifyListeners();
  }

  /// Hentikan auto sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;

    if (kDebugMode) {
      print('Auto sync stopped');
    }
    notifyListeners();
  }

  /// Toggle auto sync
  void toggleAutoSync() {
    if (isAutoSyncEnabled) {
      stopAutoSync();
    } else if (_connectivityService.isConnected) {
      startAutoSync();
    }
  }

  /// Trigger immediate sync
  Future<void> _triggerImmediateSync() async {
    // Add small delay to avoid immediate sync after connection
    await Future.delayed(const Duration(seconds: 2));
    if (_connectivityService.isConnected) {
      await _performSync();
    }
  }

  /// Tambah item ke sync queue
  Future<void> addToSyncQueue({
    required SyncEntityType entityType,
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
    String? customId,
  }) async {
    final syncId = customId ?? const Uuid().v4();

    final syncItem = SyncItem(
      id: syncId,
      entityType: entityType,
      operationType: operationType,
      data: data,
      createdAt: DateTime.now(),
    );

    await _localStorage.addSyncItem(syncItem);
    _updatePendingSyncCount();

    if (kDebugMode) {
      print('Added to sync queue: ${entityType.name} ${operationType.name}');
    }

    // Trigger sync if connected
    if (_connectivityService.isConnected && !_isSyncing) {
      _performSync();
    }

    notifyListeners();
  }

  /// Simpan data untuk offline access
  Future<void> saveOfflineData({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    await _localStorage.saveOfflineData(entityType, entityId, data);

    if (kDebugMode) {
      print('Saved offline data: $entityType - $entityId');
    }
  }

  /// Ambil data offline
  Map<String, dynamic>? getOfflineData(String entityType, String entityId) {
    return _localStorage.getOfflineData(entityType, entityId);
  }

  /// Ambil semua data offline berdasarkan tipe
  List<Map<String, dynamic>> getAllOfflineDataByType(String entityType) {
    return _localStorage.getAllOfflineDataByType(entityType);
  }

  /// Perform manual sync
  Future<void> performManualSync() async {
    if (!_connectivityService.isConnected) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }

    await _performSync();
  }

  /// Perform sync operation
  Future<void> _performSync() async {
    if (_isSyncing || !_connectivityService.isConnected) return;

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      final pendingItems = _localStorage.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        _lastSyncTime = DateTime.now();
        return;
      }

      if (kDebugMode) {
        print('Starting sync for ${pendingItems.length} items');
      }

      int successCount = 0;
      int failCount = 0;

      for (final item in pendingItems) {
        try {
          // Update status to syncing
          final syncingItem = item.copyWith(
            status: SyncStatus.syncing,
            lastAttemptAt: DateTime.now(),
          );
          await _localStorage.updateSyncItem(syncingItem);

          // Perform actual sync based on entity type
          await _syncItem(item);

          // Mark as completed
          final completedItem = item.copyWith(
            status: SyncStatus.completed,
            lastAttemptAt: DateTime.now(),
          );
          await _localStorage.updateSyncItem(completedItem);
          successCount++;

          if (kDebugMode) {
            print(
              'Synced successfully: ${item.entityType.name} ${item.operationType.name}',
            );
          }
        } catch (e) {
          failCount++;
          final failedItem = item.copyWith(
            status: SyncStatus.failed,
            lastAttemptAt: DateTime.now(),
            retryCount: item.retryCount + 1,
            errorMessage: e.toString(),
          );
          await _localStorage.updateSyncItem(failedItem);

          if (kDebugMode) {
            print(
              'Sync failed: ${item.entityType.name} ${item.operationType.name} - $e',
            );
          }

          // Remove item if retry count exceeds limit
          if (failedItem.retryCount >= 3) {
            await _localStorage.removeSyncItem(failedItem.id);
            if (kDebugMode) {
              print('Removed item after 3 failed attempts: ${failedItem.id}');
            }
          }
        }
      }

      // Clean up completed items
      await _localStorage.clearCompletedSyncItems();

      _lastSyncTime = DateTime.now();

      if (kDebugMode) {
        print('Sync completed: $successCount success, $failCount failed');
      }
    } catch (e) {
      _lastSyncError = e.toString();
      if (kDebugMode) {
        print('Sync error: $e');
      }
    } finally {
      _isSyncing = false;
      _updatePendingSyncCount();
      notifyListeners();
    }
  }

  /// Sync individual item based on entity type
  Future<void> _syncItem(SyncItem item) async {
    switch (item.entityType) {
      case SyncEntityType.profile:
        await _syncProfileItem(item);
        break;
      case SyncEntityType.task:
        await _syncTaskItem(item);
        break;
      case SyncEntityType.transaction:
        await _syncTransactionItem(item);
        break;
      case SyncEntityType.account:
        await _syncAccountItem(item);
        break;
    }
  }

  /// Sync profile item
  Future<void> _syncProfileItem(SyncItem item) async {
    if (_profileRepository == null)
      throw Exception('Profile repository not available');

    switch (item.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        // Implementation depends on your profile repository methods
        // This is a placeholder - implement based on your actual repository interface
        if (kDebugMode) {
          print('Syncing profile: ${item.operationType.name}');
        }
        break;
      case SyncOperationType.delete:
        if (kDebugMode) {
          print('Deleting profile: ${item.data['id']}');
        }
        break;
    }
  }

  /// Sync task item
  Future<void> _syncTaskItem(SyncItem item) async {
    // Task repository not implemented yet - placeholder for future implementation
    switch (item.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        if (kDebugMode) {
          print('Syncing task: ${item.operationType.name} (placeholder)');
        }
        break;
      case SyncOperationType.delete:
        if (kDebugMode) {
          print('Deleting task: ${item.data['id']} (placeholder)');
        }
        break;
    }
  }

  /// Sync transaction item
  Future<void> _syncTransactionItem(SyncItem item) async {
    if (_transactionRepository == null)
      throw Exception('Transaction repository not available');

    switch (item.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        if (kDebugMode) {
          print('Syncing transaction: ${item.operationType.name}');
        }
        break;
      case SyncOperationType.delete:
        if (kDebugMode) {
          print('Deleting transaction: ${item.data['id']}');
        }
        break;
    }
  }

  /// Sync account item
  Future<void> _syncAccountItem(SyncItem item) async {
    if (_accountRepository == null)
      throw Exception('Account repository not available');

    switch (item.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        if (kDebugMode) {
          print('Syncing account: ${item.operationType.name}');
        }
        break;
      case SyncOperationType.delete:
        if (kDebugMode) {
          print('Deleting account: ${item.data['id']}');
        }
        break;
    }
  }

  /// Update pending sync count
  void _updatePendingSyncCount() {
    _pendingSyncCount = _localStorage.getPendingSyncCount();
  }

  /// Get sync queue status
  Map<String, dynamic> getSyncQueueStatus() {
    final allItems = _localStorage.getAllSyncItems();

    final byStatus = <SyncStatus, int>{};
    final byEntity = <SyncEntityType, int>{};

    for (final item in allItems) {
      byStatus[item.status] = (byStatus[item.status] ?? 0) + 1;
      byEntity[item.entityType] = (byEntity[item.entityType] ?? 0) + 1;
    }

    return {
      'total': allItems.length,
      'pending': byStatus[SyncStatus.pending] ?? 0,
      'syncing': byStatus[SyncStatus.syncing] ?? 0,
      'completed': byStatus[SyncStatus.completed] ?? 0,
      'failed': byStatus[SyncStatus.failed] ?? 0,
      'byEntity': byEntity.map((key, value) => MapEntry(key.name, value)),
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'lastSyncError': _lastSyncError,
      'isConnected': _connectivityService.isConnected,
      'isAutoSyncEnabled': isAutoSyncEnabled,
    };
  }

  /// Clear all sync data
  Future<void> clearAllSyncData() async {
    await _localStorage.clearAll();
    _updatePendingSyncCount();
    _lastSyncTime = null;
    _lastSyncError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _syncTimer?.cancel();
    super.dispose();
  }
}
