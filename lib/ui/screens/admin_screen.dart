import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/activation_service.dart';
import '../../data/models/activation_key_model.dart';
import '../widgets/activation_key_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ActivationService _activationService = ActivationService();
  final TextEditingController _keyController = TextEditingController();
  List<ActivationKeyModel> availableKeys = [];
  List<ActivationKeyModel> usedKeys = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    setState(() {
      isLoading = true;
    });

    try {
      final available = await _activationService.getAvailableKeys();
      final used = await _activationService.getUsedKeys();
      
      setState(() {
        availableKeys = available;
        usedKeys = used;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load keys: $e');
    }
  }

  Future<void> _createKey() async {
    if (_keyController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a key');
      return;
    }

    try {
      await _activationService.createKey(_keyController.text.trim());
      _keyController.clear();
      _loadKeys();
      Get.snackbar('Success', 'Key created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create key: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C4852),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create Key Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        const Text(
                          'Create Activation Key',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3C4852),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _keyController,
                          decoration: InputDecoration(
                            hintText: 'Enter key code (e.g., ABC-123)',
                            hintStyle: TextStyle(
                              color: const Color(0xFF3C4852).withOpacity(0.6),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C2FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C2FF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C2FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Create Key',
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
                  const SizedBox(height: 24),
                  
                  // Available Keys Section
                  _buildKeysSection('Available Keys', availableKeys, false),
                  const SizedBox(height: 24),
                  
                  // Used Keys Section
                  _buildKeysSection('Used Keys', usedKeys, true),
                ],
              ),
            ),
    );
  }

  Widget _buildKeysSection(String title, List<ActivationKeyModel> keys, bool isUsedSection) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C4852),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isUsedSection ? Colors.red.withOpacity(0.1) : const Color(0xFF00C2FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${keys.length}',
                  style: TextStyle(
                    color: isUsedSection ? Colors.red : const Color(0xFF00C2FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (keys.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No ${isUsedSection ? 'used' : 'available'} keys',
                  style: TextStyle(
                    color: const Color(0xFF3C4852).withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                return ActivationKeyCard(
                  activationKey: key,
                  isUsed: isUsedSection,
                  onRefresh: _loadKeys,
                );
              },
            ),
        ],
      ),
    );
  }
}
