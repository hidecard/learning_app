import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controllers/premium_controller.dart';
import '../../logic/controllers/auth_controller.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premiumController = Get.find<PremiumController>();
    final authController = Get.find<AuthController>();
    final keyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Activate Premium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter activation key:', style: TextStyle(fontSize: 18)),
            TextField(controller: keyController, decoration: const InputDecoration(labelText: 'Key')),
            const SizedBox(height: 20),
            Obx(() => premiumController.isRedeeming.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    final success = await premiumController.redeemKey(keyController.text);
                    if (success) {
                      authController.currentUser.refresh(); // Refresh user
                      Get.back();
                    }
                  },
                  child: const Text('Activate'),
                )),
            if (authController.currentUser.value?.isPremium ?? false)
              const Text('Already Premium!', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
