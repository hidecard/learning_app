import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseService _service = FirebaseService();
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChange);
    _checkUser();
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      currentUser.value = null;
      isInitialized.value = true;
      return;
    }
    await _checkUser();
  }

  Future<void> _checkUser() async {
    try {
      currentUser.value = await _service.getCurrentUser();
    } catch (_) {
      currentUser.value = null;
    } finally {
      isInitialized.value = true;
    }
  }

  Future<void> waitUntilReady() async {
    if (isInitialized.value) return;
    await isInitialized.stream.firstWhere((ready) => ready);
  }

  Future<void> refreshCurrentUser() => _checkUser();

  Future<void> signUp(String email, String password) async {
    await _runAuthAction(() async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _service.createUserProfile();
      await _checkUser();
      Get.offAllNamed('/main');
    });
  }

  Future<void> signIn(String email, String password) async {
    await _runAuthAction(() async {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _checkUser();
      Get.offAllNamed('/main');
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    isLoading.value = true;
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      Get.snackbar('Sign-in failed', _authErrorMessage(error));
    } catch (_) {
      Get.snackbar('Something went wrong', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return error.message ?? 'Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      currentUser.value = null;
      Get.offAllNamed('/auth');
    } catch (_) {
      Get.snackbar('Sign-out failed', 'Please try again.');
    }
  }

  Future<void> updateUserProfile({String? name}) async {
    final existingUser = currentUser.value;
    if (existingUser == null) return;

    isLoading.value = true;
    try {
      final updatedUser = existingUser.copyWith(name: name?.trim());
      await _service.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;
      Get.snackbar(
        'Profile updated',
        'Your profile has been saved.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar('Update failed', 'We could not save your profile.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    final existingUser = currentUser.value;
    if (existingUser == null) return;

    try {
      final updatedUser = existingUser.copyWith(isPremium: isPremium);
      await _service.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;
    } catch (_) {
      Get.snackbar('Update failed', 'We could not update your premium status.');
    }
  }

  Future<void> addActivationKey(String activationKey) async {
    final existingUser = currentUser.value;
    if (existingUser == null) return;

    isLoading.value = true;
    try {
      final updatedUser = existingUser.copyWith(
        isPremium: true,
        activationKey: activationKey,
      );
      await _service.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;
    } catch (_) {
      Get.snackbar(
        'Activation failed',
        'We could not save the activation key.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeActivationKey() async {
    final existingUser = currentUser.value;
    if (existingUser == null) return;

    isLoading.value = true;
    try {
      final updatedUser = existingUser.copyWith(
        isPremium: false,
        clearActivationKey: true,
      );
      await _service.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;
    } catch (_) {
      Get.snackbar('Removal failed', 'We could not remove the activation key.');
    } finally {
      isLoading.value = false;
    }
  }
}
