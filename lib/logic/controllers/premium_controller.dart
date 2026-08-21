import 'package:get/get.dart';

import '../../data/services/activation_service.dart';
import 'auth_controller.dart';

class PremiumController extends GetxController {
  final ActivationService _activationService = ActivationService();
  final RxBool isRedeeming = false.obs;

  Future<bool> redeemKey(String keyCode) async {
    final normalizedKey = keyCode.trim();
    if (normalizedKey.isEmpty) {
      Get.snackbar('Activation key required', 'Enter your key to continue.');
      return false;
    }

    isRedeeming.value = true;
    try {
      final result = await _activationService.activateKey(normalizedKey);
      final success = result['success'] == true;
      if (success) {
        await Get.find<AuthController>().refreshCurrentUser();
        Get.snackbar(
          'Premium activated',
          'Your premium learning content is unlocked.',
        );
      } else {
        Get.snackbar(
          'Activation failed',
          result['message']?.toString() ?? 'Invalid or used key.',
        );
      }
      return success;
    } catch (_) {
      Get.snackbar('Activation failed', 'Please try again in a moment.');
      return false;
    } finally {
      isRedeeming.value = false;
    }
  }
}
