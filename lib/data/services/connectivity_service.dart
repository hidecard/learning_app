import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConnectivityService extends GetxController {
  RxBool isConnected = true.obs;
  Timer? _connectivityTimer;
  int _checkCount = 0;
  
  @override
  void onInit() {
    super.onInit();
    _startConnectivityCheck();
  }
  
  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }
  
  void _startConnectivityCheck() {
    // Check connectivity every 5 seconds (increased from 3 to reduce overhead)
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnectivity();
    });
    
    // Initial check after a short delay to allow app to fully initialize
    Future.delayed(const Duration(seconds: 1), () {
      _checkConnectivity();
    });
  }
  
  Future<void> _checkConnectivity() async {
    try {
      _checkCount++;
      final result = await _performConnectivityCheck();
      
      if (kDebugMode) {
        print('Connectivity check #$_checkCount: ${result ? "Connected" : "Disconnected"}');
      }
      
      // Direct update - if status changes, update immediately
      if (isConnected.value != result) {
        isConnected.value = result;
        if (kDebugMode) {
          print('Connectivity changed: ${result ? "Connected" : "Disconnected"}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      if (isConnected.value != false) {
        isConnected.value = false;
        if (kDebugMode) {
          print('Connectivity changed: Disconnected (due to error)');
        }
      }
    }
  }
  
  Future<bool> _performConnectivityCheck() async {
    try {
      // Use a simpler approach - try to connect to a reliable endpoint
      // with HEAD request which is lighter than GET
      final response = await http.head(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 3));
      
      final isConnected = response.statusCode >= 200 && response.statusCode < 300;
      
      if (kDebugMode) {
        print('HTTP HEAD to google.com: Status ${response.statusCode}, Connected: $isConnected');
      }
      
      return isConnected;
    } catch (e) {
      if (kDebugMode) {
        print('HTTP HEAD failed: $e');
      }
      return false;
    }
  }
  
  void retryConnection() {
    _checkConnectivity();
  }
  
  // For testing - force offline state
  void forceOffline() {
    isConnected.value = false;
    if (kDebugMode) {
      print('Connectivity: Forced offline for testing');
    }
  }
  
  // For testing - force online state
  void forceOnline() {
    isConnected.value = true;
    if (kDebugMode) {
      print('Connectivity: Forced online for testing');
    }
  }
}
