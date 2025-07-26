import 'package:hive/hive.dart';
import 'package:myapp/core/sync/models/sync_item.dart';

/// Service untuk menyimpan data sync secara lokal menggunakan Hive
class LocalSyncStorage {
  static const String _syncBoxName = 'sync_queue';
  static const String _offlineDataBoxName = 'offline_data';
  late Box<Map> _syncBox;
  late Box<Map> _offlineDataBox;

  /// Inisialisasi storage
  Future<void> initialize() async {
    _syncBox = await Hive.openBox<Map>(_syncBoxName);
    _offlineDataBox = await Hive.openBox<Map>(_offlineDataBoxName);
  }

  /// Simpan item sync ke queue
  Future<void> addSyncItem(SyncItem item) async {
    await _syncBox.put(item.id, item.toJson());
  }

  /// Ambil semua item sync yang pending
  List<SyncItem> getPendingSyncItems() {
    return _syncBox.values
        .map((json) => SyncItem.fromJson(Map<String, dynamic>.from(json)))
        .where((item) => item.status == SyncStatus.pending)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Ambil semua item sync
  List<SyncItem> getAllSyncItems() {
    return _syncBox.values
        .map((json) => SyncItem.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Update status item sync
  Future<void> updateSyncItem(SyncItem item) async {
    await _syncBox.put(item.id, item.toJson());
  }

  /// Hapus item sync yang sudah berhasil
  Future<void> removeSyncItem(String id) async {
    await _syncBox.delete(id);
  }

  /// Hapus semua item sync yang sudah completed
  Future<void> clearCompletedSyncItems() async {
    final completedItems = _syncBox.values
        .map((json) => SyncItem.fromJson(Map<String, dynamic>.from(json)))
        .where((item) => item.status == SyncStatus.completed)
        .map((item) => item.id)
        .toList();

    for (final id in completedItems) {
      await _syncBox.delete(id);
    }
  }

  /// Simpan data offline untuk entitas tertentu
  Future<void> saveOfflineData(
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    final key = '${entityType}_$entityId';
    await _offlineDataBox.put(key, {
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Ambil data offline untuk entitas tertentu
  Map<String, dynamic>? getOfflineData(String entityType, String entityId) {
    final key = '${entityType}_$entityId';
    final stored = _offlineDataBox.get(key);
    if (stored != null) {
      return Map<String, dynamic>.from(stored['data']);
    }
    return null;
  }

  /// Ambil semua data offline untuk jenis entitas tertentu
  List<Map<String, dynamic>> getAllOfflineDataByType(String entityType) {
    return _offlineDataBox.values
        .where((stored) => stored['entityType'] == entityType)
        .map((stored) => Map<String, dynamic>.from(stored['data']))
        .toList();
  }

  /// Hapus data offline untuk entitas tertentu
  Future<void> removeOfflineData(String entityType, String entityId) async {
    final key = '${entityType}_$entityId';
    await _offlineDataBox.delete(key);
  }

  /// Hapus semua data offline yang sudah sync
  Future<void> clearSyncedOfflineData(List<String> syncedIds) async {
    final keysToDelete = <String>[];

    for (final entry in _offlineDataBox.toMap().entries) {
      final stored = entry.value;
      final entityId = stored['entityId'];
      if (syncedIds.contains(entityId)) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await _offlineDataBox.delete(key);
    }
  }

  /// Dapatkan jumlah item sync pending
  int getPendingSyncCount() {
    return _syncBox.values
        .map((json) => SyncItem.fromJson(Map<String, dynamic>.from(json)))
        .where((item) => item.status == SyncStatus.pending)
        .length;
  }

  /// Dapatkan jumlah data offline
  int getOfflineDataCount() {
    return _offlineDataBox.length;
  }

  /// Bersihkan semua data
  Future<void> clearAll() async {
    await _syncBox.clear();
    await _offlineDataBox.clear();
  }

  /// Tutup storage
  Future<void> close() async {
    await _syncBox.close();
    await _offlineDataBox.close();
  }
}
