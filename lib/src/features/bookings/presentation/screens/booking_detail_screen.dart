import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../payments/presentation/screens/payment_qr_screen.dart';
import '../providers/booking_providers.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({required this.bookingId, super.key});

  static const route = '/booking-detail';

  final String bookingId;

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref.read(bookingRepositoryProvider).cancel(widget.bookingId);
      ref.invalidate(myBookingsProvider);
      ref.invalidate(bookingDetailProvider(widget.bookingId));
      if (mounted) showSnack(context, 'Booking berhasil dibatalkan');
    } catch (error) {
      if (mounted)
        showSnack(context, friendlyErrorMessage(error), isError: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(bookingDetailProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(bookingDetailProvider(widget.bookingId)),
        ),
        data: (booking) {
          final canPay =
              booking.status == 'pending_payment' ||
              booking.status == 'awaiting_verification';
          final canCancel = booking.status == 'pending_payment';

          return PagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconBadge(
                                  icon: Icons.confirmation_number_rounded,
                                  size: 56,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Booking #${booking.id.substring(0, 8)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      StatusChip(status: booking.status),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _InfoRow(label: 'Tanggal', value: booking.date),
                            _InfoRow(
                              label: 'Jam',
                              value:
                                  '${booking.startTime} - ${booking.endTime}',
                            ),
                            _InfoRow(
                              label: 'Durasi',
                              value: formatDurationHours(booking.durationHrs),
                            ),
                            _InfoRow(
                              label: 'Total',
                              value: formatRupiah(booking.totalPrice),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        color: _infoColor(booking.status),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _infoIcon(booking.status),
                              color: _infoIconColor(booking.status),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _statusMessage(booking.status),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canPay) ...[
                  PrimaryButton(
                    label: booking.status == 'awaiting_verification'
                        ? 'Lihat Status Pembayaran'
                        : 'Lanjut Pembayaran',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: () =>
                        context.push('${PaymentQrScreen.route}/${booking.id}'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (canCancel)
                  OutlinedButton.icon(
                    onPressed: _cancelling ? null : _cancel,
                    icon: _cancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: Text(
                      _cancelling ? 'Membatalkan...' : 'Batalkan Booking',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _infoColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'confirmed' ||
        normalized == 'paid' ||
        normalized == 'completed')
      return AppColors.primarySoft;
    if (normalized == 'rejected' ||
        normalized == 'payment_rejected' ||
        normalized == 'cancelled')
      return AppColors.danger.withOpacity(.08);
    return AppColors.warning.withOpacity(.10);
  }

  Color _infoIconColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'confirmed' ||
        normalized == 'paid' ||
        normalized == 'completed')
      return AppColors.success;
    if (normalized == 'rejected' ||
        normalized == 'payment_rejected' ||
        normalized == 'cancelled')
      return AppColors.danger;
    return AppColors.warning;
  }

  IconData _infoIcon(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'awaiting_verification') return Icons.fact_check_rounded;
    if (normalized == 'confirmed' ||
        normalized == 'paid' ||
        normalized == 'completed')
      return Icons.verified_rounded;
    if (normalized == 'rejected' ||
        normalized == 'payment_rejected' ||
        normalized == 'cancelled')
      return Icons.info_outline_rounded;
    return Icons.schedule_rounded;
  }

  String _statusMessage(String status) {
    final normalized = status.toLowerCase();
    return switch (normalized) {
      'pending_payment' =>
        'Booking dibuat. Silakan lakukan pembayaran, lalu upload bukti pembayaran agar admin bisa melakukan verifikasi.',
      'awaiting_verification' =>
        'Bukti pembayaran sudah dikirim dan sedang menunggu verifikasi admin. Kamu akan mendapat notifikasi setelah diproses.',
      'confirmed' ||
      'paid' => 'Pembayaran sudah dikonfirmasi admin. Booking kamu sudah aman.',
      'completed' =>
        'Booking ini sudah selesai. Terima kasih sudah menggunakan aplikasi.',
      'rejected' || 'payment_rejected' =>
        'Pembayaran ditolak admin. Silakan cek notifikasi untuk informasi lebih lanjut.',
      'cancelled' => 'Booking ini sudah dibatalkan.',
      _ =>
        'Status booking sedang diperbarui. Refresh halaman untuk melihat informasi terbaru.',
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
