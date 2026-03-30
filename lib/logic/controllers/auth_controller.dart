import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // Navigate to home screen after successful signup
      Get.offAllNamed('/home');
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
      // Navigate to home screen after successful login
      Get.offAllNamed('/home');
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
}
