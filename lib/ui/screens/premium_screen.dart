import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controllers/auth_controller.dart';
import '../../logic/controllers/premium_controller.dart';
import '../widgets/glass_surface.dart';

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

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = _auth.currentUser.value?.isPremium == true;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Premium access'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => _close(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: colors.surface,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hero(context),
              const SizedBox(height: 22),
              Text('Compare access', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              GlassSurface(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  children: [
                    _compareRow(context, 'First 10 lessons', true, true),
                    _compareRow(context, 'Advanced lessons', false, true),
                    _compareRow(context, 'Premium content', false, true),
                    _compareRow(context, 'Offline lesson saves', false, true),
                    _compareRow(context, 'Activation key required', true, false),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              active ? _activeCard(context) : _activationCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 82),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6FED),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: .22), blurRadius: 26, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 38),
          const SizedBox(height: 18),
          const Text('Go further with Premium', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Unlock every lesson and make steady progress without limits.', style: TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 18),
          _benefit(Icons.lock_open_rounded, 'All course lessons unlocked'),
          _benefit(Icons.verified_outlined, 'Premium content access'),
          _benefit(Icons.download_done_rounded, 'Save lessons for offline access'),
          _benefit(Icons.bolt_rounded, 'Learn without interruptions'),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(children: [Icon(icon, color: Colors.white, size: 17), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))]),
  );

  Widget _compareRow(BuildContext context, String title, bool free, bool premium) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
      _mark(context, free, 'Free'),
      const SizedBox(width: 10),
      _mark(context, premium, 'Premium'),
    ]),
  );

  Widget _mark(BuildContext context, bool yes, String label) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 70,
      child: Column(children: [
        Icon(yes ? Icons.check_circle_rounded : Icons.remove_circle_outline, size: 18, color: yes ? colors.primary : colors.outline),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _activationCard(BuildContext context) => GlassSurface(
    borderRadius: BorderRadius.circular(22),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activate with your key', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Enter the key provided by CodeNest.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 16),
        TextField(controller: _keyController, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Activation key', prefixIcon: Icon(Icons.key_outlined))),
        const SizedBox(height: 14),
        Obx(() => SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _premium.isRedeeming.value ? null : () => _premium.redeemKey(_keyController.text),
            child: _premium.isRedeeming.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Activate Premium'),
          ),
        )),
      ],
    ),
  );

  Widget _activeCard(BuildContext context) => GlassSurface(
    tint: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .72),
    borderRadius: BorderRadius.circular(22),
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary, size: 34),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Premium is active', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        SizedBox(height: 4),
        Text('You have access to all available learning content.', style: TextStyle(fontSize: 13)),
      ])),
    ]),
  );
}
