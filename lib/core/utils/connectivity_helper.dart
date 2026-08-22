import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();
  static const String offlineTitle = 'ইন্টারনেট সংযোগ নেই';
  static const String offlineRequiredMessage =
      'অ্যাপ ব্যবহার করতে ইন্টারনেট সংযোগ প্রয়োজন।';
  static const String offlineRetryMessage =
      'ইন্টারনেট সংযোগ নেই। অনুগ্রহ করে সংযোগ চালু করে আবার চেষ্টা করুন।';
  static const String offlineShortMessage = 'ইন্টারনেট সংযোগ নেই।';

  /// Check if device has a network connection and real internet access.
  static Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    // Browsers do not support dart:io DNS lookups. A failed
    // InternetAddress.lookup on Flutter Web is therefore not evidence that the
    // user is offline. Actual Firebase requests still surface network errors.
    if (kIsWeb) {
      return true;
    }

    return _hasInternetAccess();
  }

  /// Get current connectivity status
  static Future<List<ConnectivityResult>> getConnectivityStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// Stream connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  static Future<void> ensureConnected() async {
    if (!await isConnected()) {
      throw const NetworkException();
    }
  }

  static Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}

class NetworkException implements Exception {
  const NetworkException();

  String get message => ConnectivityHelper.offlineShortMessage;
}
