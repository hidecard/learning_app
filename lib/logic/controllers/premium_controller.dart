import 'package:get/get.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/activation_service.dart';

class PremiumController extends GetxController {
  final FirebaseService _service = FirebaseService();
  final ActivationService _activationService = ActivationService();
  final RxBool isRedeeming = false.obs;

  Future<bool> redeemKey(String keyCode) async {
    isRedeeming.value = true;
    try {
      final result = await _activationService.activateKey(keyCode);
      final success = result['success'] as bool;
      if (success) {
        Get.snackbar('Success', 'Premium activated!');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Invalid or used key');
      }
      return success;
    } finally {
      isRedeeming.value = false;
    }
  }
}
