import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/activation_service.dart';
import '../../logic/controllers/auth_controller.dart';
import 'key_management_screen.dart';

class ActivationKeyScreen extends StatefulWidget {
  const ActivationKeyScreen({super.key});
  @override
  State<ActivationKeyScreen> createState() => _ActivationKeyScreenState();
}

class _ActivationKeyScreenState extends State<ActivationKeyScreen> {
  final _auth = Get.find<AuthController>();
  final _service = ActivationService();
  final _key = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _showKey = false;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final result = await _service.activateKey(_key.text.trim());
      if (result['success'] == true) {
        await _auth.refreshCurrentUser();
        Get.snackbar(
          'Premium activated',
          'Your premium learning content is unlocked.',
        );
        if (mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offNamed('/main');
          }
        }
      } else {
        Get.snackbar(
          'Invalid key',
          result['message']?.toString() ??
              'This key is invalid or already used.',
        );
      }
    } catch (_) {
      Get.snackbar('Activation failed', 'Please try again in a moment.');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove activation key?'),
        content: const Text('You will lose access to premium features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _auth.removeActivationKey();
      if (mounted) setState(() => _showKey = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser.value;
    final colors = Theme.of(context).colorScheme;
    final premium = user?.isPremium == true;
    final hasKey = user?.activationKey?.isNotEmpty == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activation key'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offNamed('/main');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          if (user?.email == 'ak1500@gmail.com')
            IconButton(
              onPressed: () => Get.to(() => const KeyManagementScreen()),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  premium ? Icons.verified_rounded : Icons.key_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 14),
                Text(
                  premium ? 'Premium active' : 'Free plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  premium
                      ? 'All available lessons are unlocked.'
                      : 'Use an activation key to unlock more lessons.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (hasKey)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Current key',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _showKey = !_showKey),
                          icon: Icon(
                            _showKey
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          label: Text(_showKey ? 'Hide' : 'Show'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Text(
                        _showKey ? user!.activationKey! : '•' * 20,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: colors.onSurface,
                          letterSpacing: _showKey ? 1.5 : 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _remove(context),
                        icon: Icon(Icons.delete_outline, color: colors.error),
                        label: Text(
                          'Remove key',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!hasKey) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your key',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your key will be checked securely before Premium is enabled.',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _key,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Activation key',
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your activation key'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _activate,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Activate Premium'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
