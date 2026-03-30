import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController authController = Get.find();
  final RxBool isLogin = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            Obx(() => authController.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    if (isLogin.value) {
                      await authController.signIn(emailController.text, passwordController.text);
                    } else {
                      await authController.signUp(emailController.text, passwordController.text);
                    }
                  },
                  child: Text(isLogin.value ? 'Login' : 'Sign Up'),
                )),
            TextButton(
              onPressed: () => isLogin.value = !isLogin.value,
              child: Text(isLogin.value ? 'Need account? Sign Up' : 'Have account? Login'),
            ),
          ],
        ),
      )),
    );
  }
}
