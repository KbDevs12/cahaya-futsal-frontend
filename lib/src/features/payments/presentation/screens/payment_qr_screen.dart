import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../bookings/presentation/providers/booking_providers.dart';
import '../providers/payment_providers.dart';

class PaymentQrScreen extends ConsumerStatefulWidget {
  const PaymentQrScreen({required this.bookingId, super.key});

  static const route = '/payment';

  final String bookingId;

  @override
  ConsumerState<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends ConsumerState<PaymentQrScreen> {
  final _picker = ImagePicker();
  final _noteController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _selectedBytes;
  bool _submitting = false;
  bool _submitted = false;
  String? _submittedProofUrl;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) {
          showSnack(
            context,
            'Ukuran bukti pembayaran maksimal 5MB',
            isError: true,
          );
        }
        return;
      }

      setState(() {
        _selectedImage = image;
        _selectedBytes = bytes;
      });
    } catch (error) {
      if (mounted) {
        showSnack(context, friendlyErrorMessage(error), isError: true);
      }
    }
  }

  Future<void> _submitProof() async {
    final bytes = _selectedBytes;
    final image = _selectedImage;
    if (bytes == null || image == null) {
      showSnack(context, 'Pilih gambar bukti pembayaran dulu', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(paymentRepositoryProvider)
          .submitProof(
            bookingId: widget.bookingId,
            bytes: bytes,
            fileName: image.name.isNotEmpty ? image.name : 'payment-proof.jpg',
            note: _noteController.text,
          );

      ref.invalidate(myBookingsProvider);
      ref.invalidate(bookingDetailProvider(widget.bookingId));

      setState(() {
        _submitted = true;
        _submittedProofUrl = result.proofImageUrl;
      });

      if (mounted) {
        showSnack(
          context,
          'Bukti pembayaran dikirim. Menunggu verifikasi admin.',
        );
      }
    } catch (error) {
      if (mounted) {
        showSnack(context, friendlyErrorMessage(error), isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = ref.watch(paymentQrProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: qr.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(paymentQrProvider(widget.bookingId)),
        ),
        data: (payment) => PagePadding(
          child: ListView(
            children: [
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const IconBadge(icon: Icons.qr_code_2_rounded, size: 62),
                    const SizedBox(height: 14),
                    Text(
                      formatRupiah(payment.amount),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan QRIS di bawah ini dari aplikasi pembayaran kamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: QrImageView(
                        data: payment.qrCode,
                        size: 250,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Berlaku sampai ${payment.expiredAt.toLocal()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _PaymentProofCard(
                selectedBytes: _selectedBytes,
                submitted: _submitted,
                submittedProofUrl: _submittedProofUrl,
                noteController: _noteController,
                submitting: _submitting,
                onPickImage: _pickProofImage,
                onSubmit: _submitProof,
              ),
              const SizedBox(height: 18),
              const AppCard(
                color: AppColors.primarySoft,
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setelah bukti pembayaran dikirim, admin akan melakukan verifikasi. Status terbaru akan masuk ke halaman Notifikasi.',
                        style: TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentProofCard extends StatelessWidget {
  const _PaymentProofCard({
    required this.selectedBytes,
    required this.submitted,
    required this.submittedProofUrl,
    required this.noteController,
    required this.submitting,
    required this.onPickImage,
    required this.onSubmit,
  });

  final Uint8List? selectedBytes;
  final bool submitted;
  final String? submittedProofUrl;
  final TextEditingController noteController;
  final bool submitting;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.verified_rounded, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bukti pembayaran terkirim',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const StatusChip(status: 'awaiting_verification'),
            const SizedBox(height: 14),
            const Text(
              'Pembayaran kamu sedang menunggu verifikasi admin. Kamu akan mendapat notifikasi setelah pembayaran dikonfirmasi atau ditolak.',
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            if (submittedProofUrl != null && submittedProofUrl!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                submittedProofUrl!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload bukti pembayaran',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Setelah bayar, upload screenshot/bukti pembayaran. Admin akan cek dari admin panel.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: submitting ? null : onPickImage,
            child: Container(
              height: selectedBytes == null ? 142 : 230,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: selectedBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_rounded,
                          color: AppColors.primary,
                          size: 38,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Pilih gambar bukti pembayaran',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'JPG, PNG, atau WEBP maksimal 5MB',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(
                        selectedBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          if (selectedBytes != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: submitting ? null : onPickImage,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Ganti gambar'),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            enabled: !submitting,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Catatan opsional',
              hintText: 'Contoh: Sudah bayar via QRIS jam 13.20',
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Kirim Bukti Pembayaran',
            icon: Icons.send_rounded,
            isLoading: submitting,
            onPressed: selectedBytes == null ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}
