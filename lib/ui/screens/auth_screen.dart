import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();
  bool _login = true;
  bool _showPassword = false;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_login) { await _auth.signIn(_email.text, _password.text); } else { await _auth.signUp(_email.text, _password.text); }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 58, height: 58, decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(18)), child: Icon(Icons.auto_awesome_rounded, color: colors.primary, size: 30)),
      const SizedBox(height: 28),
      Text(_login ? 'Welcome back' : 'Start learning today', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(_login ? 'Sign in to continue your learning journey.' : 'Create an account and learn at your own pace.', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15)),
      const SizedBox(height: 30),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: [
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded)), validator: (value) => value == null || !GetUtils.isEmail(value.trim()) ? 'Enter a valid email address' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _password, obscureText: !_showPassword, textInputAction: TextInputAction.done, onFieldSubmitted: (_) => _submit(), decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))), validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null),
        const SizedBox(height: 24),
        Obx(() => SizedBox(width: double.infinity, child: FilledButton(onPressed: _auth.isLoading.value ? null : _submit, child: _auth.isLoading.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_login ? 'Sign in' : 'Create account')))),
      ])))),
      const SizedBox(height: 22),
      Center(child: Wrap(alignment: WrapAlignment.center, children: [Text(_login ? 'New to Nexus Tech? ' : 'Already have an account? ', style: TextStyle(color: colors.onSurfaceVariant)), GestureDetector(onTap: () => setState(() => _login = !_login), child: Text(_login ? 'Create account' : 'Sign in', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)))])),
      const SizedBox(height: 28),
      Center(child: Text('Learn practical skills. Ship better work.', style: TextStyle(color: colors.outline, fontSize: 12))),
    ]))))));
  }
}
