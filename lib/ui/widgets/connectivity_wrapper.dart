import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/connectivity_service.dart';
import '../screens/no_internet_screen.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(
      () => connectivityService.isConnected.value
          ? child
          : NoInternetScreen(onRetry: connectivityService.retryConnection),
    );
  }
}
