import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/core/sync/models/sync_item.dart';
import 'package:myapp/core/sync/services/connectivity_service.dart';
import 'package:myapp/core/sync/services/local_sync_storage.dart';
import 'package:myapp/core/sync/services/auto_sync_service.dart';
import 'package:myapp/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:myapp/features/cashcard/data/repositories/transaction_repository_impl.dart';
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart';

/// Provider untuk menginisialisasi dan menyediakan sync services
class SyncProvider extends ChangeNotifier {
  ConnectivityService? _connectivityService;
  LocalSyncStorage? _localStorage;
  AutoSyncService? _autoSyncService;

  bool _isInitialized = false;
  String? _initializationError;

  ConnectivityService? get connectivityService => _connectivityService;
  LocalSyncStorage? get localStorage => _localStorage;
  AutoSyncService? get autoSyncService => _autoSyncService;
  bool get isInitialized => _isInitialized;
  String? get initializationError => _initializationError;

  /// Inisialisasi semua sync services
  Future<void> initialize({
    ProfileRepositoryImpl? profileRepository,
    TransactionRepositoryImpl? transactionRepository,
    AccountRepositoryImpl? accountRepository,
  }) async {
    try {
      // Inisialisasi Hive untuk local storage
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }

      // Inisialisasi connectivity service
      _connectivityService = ConnectivityService();

      // Inisialisasi local storage
      _localStorage = LocalSyncStorage();
      await _localStorage!.initialize();

      // Inisialisasi auto sync service
      _autoSyncService = AutoSyncService(
        connectivityService: _connectivityService!,
        localStorage: _localStorage!,
        profileRepository: profileRepository,
        transactionRepository: transactionRepository,
        accountRepository: accountRepository,
      );

      _isInitialized = true;
      _initializationError = null;

      notifyListeners();
    } catch (e) {
      _initializationError = e.toString();
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Dispose semua services
  @override
  void dispose() {
    _autoSyncService?.dispose();
    _connectivityService?.dispose();
    _localStorage?.close();
    super.dispose();
  }
}

/// Widget wrapper untuk menyediakan sync services ke seluruh aplikasi
class SyncServiceProvider extends StatefulWidget {
  final Widget child;
  final ProfileRepositoryImpl? profileRepository;
  final TransactionRepositoryImpl? transactionRepository;
  final AccountRepositoryImpl? accountRepository;

  const SyncServiceProvider({
    super.key,
    required this.child,
    this.profileRepository,
    this.transactionRepository,
    this.accountRepository,
  });

  @override
  State<SyncServiceProvider> createState() => _SyncServiceProviderState();
}

class _SyncServiceProviderState extends State<SyncServiceProvider> {
  late SyncProvider _syncProvider;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _syncProvider = SyncProvider();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    try {
      await _syncProvider.initialize(
        profileRepository: widget.profileRepository,
        transactionRepository: widget.transactionRepository,
        accountRepository: widget.accountRepository,
      );
    } catch (e) {
      // Log error but continue - app should still work without sync
      debugPrint('Sync initialization failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _syncProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing sync services...'),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _syncProvider),
        if (_syncProvider.connectivityService != null)
          ChangeNotifierProvider.value(
            value: _syncProvider.connectivityService!,
          ),
        if (_syncProvider.autoSyncService != null)
          ChangeNotifierProvider.value(value: _syncProvider.autoSyncService!),
      ],
      child: widget.child,
    );
  }
}

/// Mixin untuk mempermudah penggunaan auto sync di repository atau service
mixin AutoSyncMixin {
  /// Tambah operasi ke sync queue
  Future<void> addToSyncQueue({
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
      debugPrint('Failed to add to sync queue: $e');
      // Don't throw - app should continue working even if sync fails
    }
  }

  /// Simpan data untuk offline access
  Future<void> saveOfflineData({
    required BuildContext context,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      await autoSyncService.saveOfflineData(
        entityType: entityType,
        entityId: entityId,
        data: data,
      );
    } catch (e) {
      debugPrint('Failed to save offline data: $e');
    }
  }

  /// Ambil data offline
  Map<String, dynamic>? getOfflineData({
    required BuildContext context,
    required String entityType,
    required String entityId,
  }) {
    try {
      final autoSyncService = context.read<AutoSyncService>();
      return autoSyncService.getOfflineData(entityType, entityId);
    } catch (e) {
      debugPrint('Failed to get offline data: $e');
      return null;
    }
  }

  /// Check if device is connected
  bool isConnected(BuildContext context) {
    try {
      final connectivityService = context.read<ConnectivityService>();
      return connectivityService.isConnected;
    } catch (e) {
      debugPrint('Failed to get connectivity status: $e');
      return true; // Assume connected if service not available
    }
  }
}
