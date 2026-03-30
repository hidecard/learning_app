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
      'is_premium': false,
    });
  }

  Future<bool> redeemKey(String keyCode) async {
    // Check if key exists and not used
    final query = await _firestore
        .collection('activation_keys')
        .where('key_code', isEqualTo: keyCode)
        .where('is_used', isEqualTo: false)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final keyDoc = query.docs.first;
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    // Mark key as used
    await keyDoc.reference.update({'is_used': true});

    // Update user to premium
    await _firestore.collection('profiles').doc(userId).update({'is_premium': true});

    return true;
  }
}
