import 'package:get/get.dart';
import '../../data/services/firebase_service.dart';

class PremiumController extends GetxController {
  final FirebaseService _service = FirebaseService();
  final RxBool isRedeeming = false.obs;

  Future<bool> redeemKey(String keyCode) async {
    isRedeeming.value = true;
    try {
      final success = await _service.redeemKey(keyCode);
      if (success) {
        Get.snackbar('Success', 'Premium activated!');
      } else {
        Get.snackbar('Error', 'Invalid or used key');
      }
      return success;
    } finally {
      isRedeeming.value = false;
    }
  }
}
