import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activation_key_model.dart';
import 'firebase_service.dart';

class ActivationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  Future<Map<String, dynamic>> activateKey(String key) async {
    try {
      return await _firebaseService.activateUserWithKey(key);
    } catch (_) {
      return {
        'success': false,
        'message': 'Could not activate this key. Please try again.',
      };
    }
  }

  Future<List<ActivationKeyModel>> getAvailableKeys() async {
    final snapshot = await _firestore
        .collection('activation_keys')
        .where('is_used', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => ActivationKeyModel.fromFirestore(doc))
        .toList(growable: false);
  }

  Future<List<ActivationKeyModel>> getUsedKeys() async {
    final snapshot = await _firestore
        .collection('activation_keys')
        .where('is_used', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ActivationKeyModel.fromFirestore(doc))
        .toList(growable: false);
  }

  Future<void> createKey(String keyCode) async {
    final normalizedKey = keyCode.trim().toUpperCase();
    if (normalizedKey.isEmpty) throw ArgumentError('Key cannot be empty.');

    final existing = await _firestore
        .collection('activation_keys')
        .where('key_code', isEqualTo: normalizedKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('This activation key already exists.');
    }

    final keyRef = _firestore
        .collection('activation_keys')
        .doc('key_$normalizedKey');
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(keyRef);
      if (snapshot.exists) {
        throw StateError('This activation key already exists.');
      }

      transaction.set(keyRef, {
        'key_code': normalizedKey,
        'is_used': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
