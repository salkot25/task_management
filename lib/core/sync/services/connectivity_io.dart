import 'dart:io';
import 'package:flutter/foundation.dart';

/// IO-specific (Mobile/Desktop) connectivity implementation
Future<bool> checkConnectivity() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));

    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    if (kDebugMode) {
      print('IO connectivity check failed: $e');
    }
    return false;
  }
}
