import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseService _service = FirebaseService();
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _checkUser();
    });
    _checkUser();
  }

  Future<void> _checkUser() async {
    currentUser.value = await _service.getCurrentUser();
  }

  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      await _service.createUserProfile();
      // Navigate to main navigation after successful signup
      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      // Navigate to main navigation after successful login
      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to auth screen after sign out
    Get.offAllNamed('/auth');
  }

  Future<void> updateUserProfile({String? name}) async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updatedUser = currentUser.value?.copyWith(name: name);
        await _service.updateUserProfile(updatedUser!);
        currentUser.value = updatedUser;
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updatedUser = currentUser.value?.copyWith(isPremium: isPremium);
        await _service.updateUserProfile(updatedUser!);
        currentUser.value = updatedUser;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update premium status: $e');
    }
  }

  Future<void> addActivationKey(String activationKey) async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updatedUser = currentUser.value?.copyWith(
          isPremium: true,
          activationKey: activationKey,
        );
        await _service.updateUserProfile(updatedUser!);
        currentUser.value = updatedUser;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add activation key: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeActivationKey() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updatedUser = currentUser.value?.copyWith(
          isPremium: false,
          activationKey: null,
        );
        await _service.updateUserProfile(updatedUser!);
        currentUser.value = updatedUser;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove activation key: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
