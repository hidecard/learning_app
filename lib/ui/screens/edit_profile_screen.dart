import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _name.text = _auth.currentUser.value?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _auth.updateUserProfile(name: _name.text);
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser.value;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: _auth.isLoading.value ? null : _save,
              child: _auth.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              backgroundColor: colors.primaryContainer,
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                    .toUpperCase(),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Keep your learner profile up to date',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 26),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => v == null || v.trim().length < 2
                          ? 'Enter at least 2 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user?.email ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                        helperText: 'Email cannot be changed here',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                user?.isPremium == true
                    ? Icons.verified_rounded
                    : Icons.lock_outline_rounded,
                color: user?.isPremium == true
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              title: Text(
                user?.isPremium == true ? 'Premium learner' : 'Free learner',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                user?.isPremium == true
                    ? 'All available lessons are unlocked.'
                    : 'Unlock the full catalog with Premium.',
              ),
              trailing: user?.isPremium == true
                  ? null
                  : TextButton(
                      onPressed: () => Get.toNamed('/premium'),
                      child: const Text('Upgrade'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
