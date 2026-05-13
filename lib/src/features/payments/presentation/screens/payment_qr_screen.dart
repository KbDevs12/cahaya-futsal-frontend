import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../providers/payment_providers.dart';

class PaymentQrScreen extends ConsumerWidget {
  const PaymentQrScreen({required this.bookingId, super.key});

  static const route = '/payment';

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qr = ref.watch(paymentQrProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: qr.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(paymentQrProvider(bookingId)),
        ),
        data: (payment) => PagePadding(
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 42, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        formatRupiah(payment.amount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan QRIS di bawah ini dari aplikasi pembayaran kamu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: QrImageView(
                          data: payment.qrCode,
                          size: 250,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Berlaku sampai ${payment.expiredAt.toLocal()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Setelah pembayaran, admin akan confirm atau reject dari admin panel. Status terbaru akan masuk ke halaman Notifikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
