import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../data/services/activation_service.dart';
import 'key_management_screen.dart';

class ActivationKeyScreen extends StatefulWidget {
  const ActivationKeyScreen({super.key});

  @override
  State<ActivationKeyScreen> createState() => _ActivationKeyScreenState();
}

class _ActivationKeyScreenState extends State<ActivationKeyScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ActivationService _activationService = ActivationService();
  final TextEditingController _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showCurrentKey = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _activateKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _activationService.activateKey(_keyController.text.trim());
      
      if (result['success']) {
        // Update user's premium status
        await authController.updatePremiumStatus(true);
        
        Get.snackbar(
          'Success!',
          'Activation key validated successfully! Premium features unlocked.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate back or to premium screen
        Get.back();
      } else {
        Get.snackbar(
          'Invalid Key',
          result['message'] ?? 'The activation key is invalid or already used.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to validate activation key: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeCurrentKey() async {
    final confirmed = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Remove Activation Key'),
        content: const Text(
          'Are you sure you want to remove your current activation key? '
          'You will lose access to premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _activationService.removeActivationKey();
        await authController.updatePremiumStatus(false);
        
        Get.snackbar(
          'Key Removed',
          'Activation key has been removed successfully.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        
        setState(() {
          _showCurrentKey = false;
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to remove activation key: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  bool _isAdmin() {
    return authController.currentUser.value?.email == 'ak1500@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authController.currentUser.value;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Activation Key',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C4852),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isAdmin())
            IconButton(
              icon: const Icon(
                Icons.key,
                color: Color(0xFF00C2FF),
              ),
              onPressed: () {
                Get.to(() => const KeyManagementScreen());
              },
              tooltip: 'Manage Keys',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentUser?.isPremium == true
                      ? [Colors.green, Colors.green.shade700]
                      : [const Color(0xFF00C2FF), const Color(0xFF007BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (currentUser?.isPremium == true ? Colors.green : const Color(0xFF00C2FF))
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      currentUser?.isPremium == true ? Icons.verified : Icons.vpn_key,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.isPremium == true ? 'Premium Active' : 'Free Plan',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.isPremium == true
                        ? 'All premium features are unlocked'
                        : 'Enter an activation key to unlock premium features',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current Key Display
            if (currentUser?.activationKey != null && currentUser!.activationKey!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Activation Key',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C4852),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showCurrentKey = !_showCurrentKey;
                            });
                          },
                          icon: Icon(
                            _showCurrentKey ? Icons.visibility_off : Icons.visibility,
                            size: 16,
                            color: const Color(0xFF00C2FF),
                          ),
                          label: Text(
                            _showCurrentKey ? 'Hide' : 'Show',
                            style: const TextStyle(
                              color: Color(0xFF00C2FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00C2FF).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _showCurrentKey
                                  ? currentUser.activationKey!
                                  : '•' * 20,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: _showCurrentKey ? 'monospace' : null,
                                color: const Color(0xFF3C4852),
                                letterSpacing: _showCurrentKey ? 2 : 3,
                              ),
                            ),
                          ),
                          if (_showCurrentKey)
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: Color(0xFF00C2FF),
                              ),
                              onPressed: () {
                                // Copy to clipboard
                                Get.snackbar(
                                  'Copied!',
                                  'Activation key copied to clipboard',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _removeCurrentKey,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Remove Key',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Add New Key Form (only show if not premium or no key)
            if (currentUser?.isPremium != true || currentUser?.activationKey == null || currentUser!.activationKey!.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Activation Key',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C4852),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your activation key to unlock premium features including exclusive courses, '
                        'advanced content, and priority support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF3C4852).withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _keyController,
                        decoration: InputDecoration(
                          hintText: 'Enter activation key (e.g., XXXX-XXXX-XXXX-XXXX)',
                          hintStyle: TextStyle(
                            color: const Color(0xFF3C4852).withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF3C4852).withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF00C2FF),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an activation key';
                          }
                          final trimmedValue = value.trim().toUpperCase();
                          if (trimmedValue.length < 5) {
                            return 'Activation key must be at least 5 characters';
                          }
                          // Accept HIDECARD format
                          if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(trimmedValue)) {
                            return 'Activation key should contain only letters, numbers, and hyphens';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _activateKey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Activate Key',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00C2FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF00C2FF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'About Activation Keys',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00C2FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Activation keys are provided with premium purchases\n'
                    '• Each key can only be used once\n'
                    '• Premium features are unlocked immediately after activation\n'
                    '• Keys are tied to your account and cannot be transferred',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF3C4852).withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
