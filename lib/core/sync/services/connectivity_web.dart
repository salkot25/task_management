import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

/// Web-specific connectivity implementation
Future<bool> checkConnectivity() async {
  try {
    // For web, check if navigator.onLine is available and true
    return web.window.navigator.onLine;

    // Fallback: assume connected if we can reach here
    // In a web environment, if the page loaded, there was connectivity
  } catch (e) {
    if (kDebugMode) {
      print('Web connectivity check failed: $e');
    }
    // Assume connected on web as a fallback
    return true;
  }
}
