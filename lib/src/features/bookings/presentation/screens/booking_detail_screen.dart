import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
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
      if (mounted) showSnack(context, AppException("").errorMessage(error));
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
          final pending = booking.status == 'pending_payment';
          return PagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Booking #${booking.id.substring(0, 8)}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            StatusChip(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _InfoRow(label: 'Tanggal', value: booking.date),
                        _InfoRow(
                          label: 'Jam',
                          value: '${booking.startTime} - ${booking.endTime}',
                        ),
                        _InfoRow(
                          label: 'Durasi',
                          value:
                              '${booking.durationHrs.toStringAsFixed(1)} jam',
                        ),
                        _InfoRow(
                          label: 'Total',
                          value: formatRupiah(booking.totalPrice),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (pending) ...[
                  PrimaryButton(
                    label: 'Lihat QR Pembayaran',
                    onPressed: () =>
                        context.push('${PaymentQrScreen.route}/${booking.id}'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _cancelling ? null : _cancel,
                    child: Text(
                      _cancelling ? 'Membatalkan...' : 'Batalkan Booking',
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
