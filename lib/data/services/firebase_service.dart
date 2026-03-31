import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('profiles').doc(user.uid).get();
    
    if (!doc.exists) {
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.email?.split('@')[0] ?? 'User',
        isPremium: false,
      );
    }

    return UserModel.fromJson(doc.data()!);
  }

  Future<void> createUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('profiles').doc(user.uid).set({
      'id': user.uid,
      'email': user.email,
      'name': user.email?.split('@')[0] ?? 'User',
      'is_premium': false,
    });
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    await _firestore.collection('profiles').doc(userModel.id).update(userModel.toJson());
  }

  Future<Map<String, dynamic>> validateActivationKey(String keyCode) async {
    try {
      // Check if key exists and not used
      final query = await _firestore
          .collection('activation_keys')
          .where('key_code', isEqualTo: keyCode)
          .where('is_used', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {'success': false, 'message': 'Invalid or already used activation key'};
      }

      final keyDoc = query.docs.first;
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Mark key as used
      await keyDoc.reference.update({
        'is_used': true,
        'used_by': userId,
        'used_at': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Activation key validated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error validating activation key: $e'};
    }
  }

  Future<void> removeUserActivationKey(String userId) async {
    await _firestore.collection('profiles').doc(userId).update({
      'is_premium': false,
      'activation_key': FieldValue.delete(),
    });
  }
}
