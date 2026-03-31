import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activation_key_model.dart';
import 'firebase_service.dart';

class ActivationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  Future<Map<String, dynamic>> activateKey(String key) async {
    try {
      // Validate the key using Firebase service
      final result = await _firebaseService.validateActivationKey(key);
      
      if (result['success']) {
        // Update user profile with activation key
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _firestore.collection('profiles').doc(userId).update({
            'is_premium': true,
            'activation_key': key,
            'activated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return result;
    } catch (e) {
      print('Error activating key: $e');
      return {'success': false, 'message': 'Error activating key: $e'};
    }
  }

  Future<void> removeActivationKey() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firebaseService.removeUserActivationKey(userId);
      }
    } catch (e) {
      print('Error removing activation key: $e');
    }
  }

  Future<List<ActivationKeyModel>> getAvailableKeys() async {
    try {
      final snapshot = await _firestore
          .collection('activation_keys')
          .where('is_used', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => ActivationKeyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching keys: $e');
      return [];
    }
  }

  Future<List<ActivationKeyModel>> getUsedKeys() async {
    try {
      final snapshot = await _firestore
          .collection('activation_keys')
          .where('is_used', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivationKeyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching used keys: $e');
      return [];
    }
  }

  Future<void> createKey(String keyCode) async {
    try {
      await _firestore.collection('activation_keys').add({
        'key_code': keyCode,
        'is_used': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating key: $e');
    }
  }
}
