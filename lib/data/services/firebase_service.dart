import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        name: user.email?.split('@').first ?? 'User',
        isPremium: false,
      );
    }

    final data = doc.data();
    return data == null ? null : UserModel.fromJson(data);
  }

  Future<void> createUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('profiles').doc(user.uid).set({
      'id': user.uid,
      'email': user.email ?? '',
      'name': user.email?.split('@').first ?? 'User',
      'is_premium': false,
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    await _firestore
        .collection('profiles')
        .doc(userModel.id)
        .set(userModel.toJson(), SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> validateActivationKey(String keyCode) async {
    final normalizedKey = keyCode.trim();
    if (normalizedKey.isEmpty) {
      return {'success': false, 'message': 'Enter an activation key.'};
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return {'success': false, 'message': 'Sign in before activating a key.'};
    }

    try {
      final query = await _firestore
          .collection('activation_keys')
          .where('key_code', isEqualTo: normalizedKey)
          .where('is_used', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid or already used activation key.',
        };
      }

      final keyRef = query.docs.first.reference;
      final claimed = await _firestore.runTransaction<bool>((
        transaction,
      ) async {
        final keySnapshot = await transaction.get(keyRef);
        final data = keySnapshot.data();
        if (!keySnapshot.exists || data?['is_used'] == true) return false;

        transaction.update(keyRef, {
          'is_used': true,
          'used_by': userId,
          'used_at': FieldValue.serverTimestamp(),
        });
        return true;
      });

      return claimed
          ? {
              'success': true,
              'message': 'Activation key validated successfully',
            }
          : {
              'success': false,
              'message': 'That key was just used. Try another key.',
            };
    } catch (_) {
      return {
        'success': false,
        'message': 'Could not validate the key. Please try again.',
      };
    }
  }

  Future<void> removeUserActivationKey(String userId) async {
    await _firestore.collection('profiles').doc(userId).set({
      'is_premium': false,
      'activation_key': FieldValue.delete(),
    }, SetOptions(merge: true));
  }
}
