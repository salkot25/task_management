import 'dart:async';
import 'package:flutter/foundation.dart';

// Platform conditional imports
import 'connectivity_io.dart'
    if (dart.library.html) 'connectivity_web.dart'
    as connectivity_impl;

/// Service untuk memantau koneksi internet
class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  bool _isOnline = true;
  Timer? _connectivityTimer;

  bool get isConnected => _isConnected;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _startConnectivityCheck();
  }

  /// Memulai pengecekan koneksi secara berkala
  void _startConnectivityCheck() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );
    _checkConnectivity(); // Check immediately
  }

  /// Cek koneksi internet
  Future<void> _checkConnectivity() async {
    try {
      final wasConnected = _isConnected;

      // Use platform-specific implementation
      _isConnected = await connectivity_impl.checkConnectivity();
      _isOnline = _isConnected;

      // Notify listeners only if status changed
      if (wasConnected != _isConnected) {
        notifyListeners();
        if (kDebugMode) {
          print(
            'Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}',
          );
        }
      }
    } catch (e) {
      final wasConnected = _isConnected;
      _isConnected = false;
      _isOnline = false;

      if (wasConnected) {
        notifyListeners();
        if (kDebugMode) {
          print('Connectivity check failed: $e');
        }
      }
    }
  }

  /// Force check connectivity manually
  Future<bool> checkConnectivityNow() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Simulate offline mode for testing
  void setOfflineMode(bool offline) {
    if (!offline) {
      _checkConnectivity();
      return;
    }

    _isConnected = false;
    _isOnline = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}
