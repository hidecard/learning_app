import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/activation_key_model.dart';

class ActivationKeyCard extends StatelessWidget {
  final ActivationKeyModel activationKey;
  final bool isUsed;
  final VoidCallback onRefresh;

  const ActivationKeyCard({
    super.key,
    required this.activationKey,
    required this.isUsed,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUsed ? Colors.red.withOpacity(0.2) : const Color(0xFF00C2FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.red.withOpacity(0.1) : const Color(0xFF00C2FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUsed ? Icons.lock : Icons.vpn_key,
                  color: isUsed ? Colors.red : const Color(0xFF00C2FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activationKey.keyCode ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C4852),
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.red.withOpacity(0.1) : const Color(0xFF00C2FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUsed ? 'Used' : 'Available',
                  style: TextStyle(
                    color: isUsed ? Colors.red : const Color(0xFF00C2FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (activationKey.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(activationKey.createdAt!)}',
              style: TextStyle(
                color: const Color(0xFF3C4852).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
          if (isUsed && activationKey.usedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Used: ${_formatDate(activationKey.usedAt!)}',
              style: TextStyle(
                color: const Color(0xFF3C4852).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (activationKey.usedBy != null) ...[
              const SizedBox(height: 4),
              Text(
                'User ID: ${activationKey.usedBy}',
                style: TextStyle(
                  color: const Color(0xFF3C4852).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
