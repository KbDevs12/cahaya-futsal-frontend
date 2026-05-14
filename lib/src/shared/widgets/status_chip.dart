import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'paid' || 'confirmed' || 'completed' => AppColors.success,
      'cancelled' || 'rejected' || 'payment_rejected' => AppColors.danger,
      'awaiting_verification' || 'waiting_confirmation' => AppColors.primary,
      _ => AppColors.warning,
    };

    final label = switch (normalized) {
      'pending' || 'pending_payment' => 'MENUNGGU PEMBAYARAN',
      'awaiting_verification' ||
      'waiting_confirmation' => 'MENUNGGU VERIFIKASI',
      'paid' || 'confirmed' => 'DIKONFIRMASI',
      'completed' => 'SELESAI',
      'cancelled' => 'DIBATALKAN',
      'rejected' || 'payment_rejected' => 'DITOLAK',
      _ => status.replaceAll('_', ' ').toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
