import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConnectivityService extends GetxController {
  final RxBool isConnected = true.obs;
  Timer? _connectivityTimer;
  bool _isChecking = false;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkConnectivity() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final result = await _performConnectivityCheck();
      if (isConnected.value != result) {
        isConnected.value = result;
      }
    } finally {
      _isChecking = false;
    }
  }

  Future<bool> _performConnectivityCheck() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Connectivity check failed: $error');
      }
      return false;
    }
  }

  Future<void> retryConnection() => _checkConnectivity();

  @visibleForTesting
  void forceOffline() => isConnected.value = false;

  @visibleForTesting
  void forceOnline() => isConnected.value = true;
}
