import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controllers/auth_controller.dart';
import '../../logic/controllers/premium_controller.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _keyController = TextEditingController();
  final _premium = Get.find<PremiumController>();
  final _auth = Get.find<AuthController>();
  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = _auth.currentUser.value?.isPremium == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Go further with Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock every lesson and make steady progress without limits.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _benefit(
                    Icons.lock_open_rounded,
                    'All course lessons unlocked',
                  ),
                  _benefit(Icons.verified_outlined, 'Premium content access'),
                  _benefit(Icons.bolt_rounded, 'Learn without interruptions'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Compare access',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _compareRow('First 10 lessons', true, true),
                  _compareRow('Advanced lessons', false, true),
                  _compareRow('Premium content', false, true),
                  _compareRow('Activation key required', true, false),
                ],
              ),
            ),
            const SizedBox(height: 22),
            active ? _activeCard(context) : _activationCard(context),
          ],
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 17),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    ),
  );
  Widget _compareRow(String title, bool free, bool premium) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        _mark(free, 'Free'),
        const SizedBox(width: 10),
        _mark(premium, 'Premium'),
      ],
    ),
  );
  Widget _mark(bool yes, String label) {
    final colors = Theme.of(Get.context!).colorScheme;
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Icon(
            yes ? Icons.check_circle_rounded : Icons.remove_circle_outline,
            size: 18,
            color: yes ? colors.primary : colors.outline,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _activationCard(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activate with your key',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the key provided by Nexus Tech.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Activation key',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _premium.isRedeeming.value
                    ? null
                    : () => _premium.redeemKey(_keyController.text),
                child: _premium.isRedeeming.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Activate Premium'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _activeCard(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 34,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium is active',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                SizedBox(height: 4),
                Text(
                  'You have access to all available learning content.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
