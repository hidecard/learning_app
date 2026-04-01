import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../screens/no_internet_screen.dart';
import '../../data/services/connectivity_service.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the service if not already done
    final connectivityService = Get.put(ConnectivityService());
    
    return Obx(() {
      if (kDebugMode) {
        print('ConnectivityWrapper: isConnected = ${connectivityService.isConnected.value}');
      }
      
      return connectivityService.isConnected.value
          ? child
          : NoInternetScreen(
              onRetry: () {
                connectivityService.retryConnection();
              },
            );
    });
  }
}
