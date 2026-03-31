import 'package:cloud_firestore/cloud_firestore.dart';

class ActivationKeyModel {
  final String? id;
  final String? keyCode;
  final bool? isUsed;
  final String? usedBy;
  final Timestamp? usedAt;
  final Timestamp? createdAt;

  ActivationKeyModel({
    this.id,
    this.keyCode,
    this.isUsed,
    this.usedBy,
    this.usedAt,
    this.createdAt,
  });

  factory ActivationKeyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivationKeyModel(
      id: doc.id,
      keyCode: data['key_code']?.toString(),
      isUsed: data['is_used'] as bool?,
      usedBy: data['used_by']?.toString(),
      usedAt: data['used_at'] as Timestamp?,
      createdAt: data['created_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key_code': keyCode,
      'is_used': isUsed,
      'used_by': usedBy,
      'used_at': usedAt,
      'created_at': createdAt,
    };
  }
}
