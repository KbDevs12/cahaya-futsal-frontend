import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminBookingDetailScreen extends ConsumerStatefulWidget {
  const AdminBookingDetailScreen({required this.bookingId, super.key});

  static const route = '/admin/booking-detail';

  final String bookingId;

  @override
  ConsumerState<AdminBookingDetailScreen> createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends ConsumerState<AdminBookingDetailScreen> {
  late Future<AdminBookingSummary> _future;
  String? _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminBookingSummary> _load() async {
    final booking = await ref.read(adminRepositoryProvider).bookingDetail(widget.bookingId);
    _status = booking.bookingStatus;
    return booking;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _save(AdminBookingSummary booking) async {
    final nextStatus = _status ?? booking.bookingStatus;
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateBookingStatus(booking.id, nextStatus);
      if (!mounted) return;
      showSnack(context, 'Status booking berhasil diperbarui');
      ref.invalidate(adminBookingsProvider);
      ref.invalidate(adminPaymentsProvider);
      ref.invalidate(adminDashboardProvider);
      await _refresh();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<AdminBookingSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: _refresh);
          }

          final booking = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: PagePadding(
              child: ListView(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Informasi Booking'),
                        const SizedBox(height: 12),
                        AdminInfoRow(label: 'Customer', value: booking.customerName),
                        AdminInfoRow(label: 'Email', value: booking.customerEmail),
                        AdminInfoRow(label: 'No. HP', value: booking.customerPhone),
                        AdminInfoRow(label: 'Lapangan', value: booking.fieldName),
                        AdminInfoRow(label: 'Tanggal', value: readableDate(booking.date)),
                        AdminInfoRow(
                          label: 'Jam',
                          value: '${readableClock(booking.startTime)}-${readableClock(booking.endTime)}',
                        ),
                        AdminInfoRow(label: 'Durasi', value: '${booking.durationHrs.toStringAsFixed(booking.durationHrs.truncateToDouble() == booking.durationHrs ? 0 : 1)} jam'),
                        AdminInfoRow(label: 'Total', value: formatRupiah(booking.amount)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusChip(status: booking.bookingStatus),
                            StatusChip(status: booking.paymentStatus),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Update Status'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _status ?? booking.bookingStatus,
                          decoration: const InputDecoration(labelText: 'Status booking'),
                          items: const [
                            DropdownMenuItem(value: 'pending_payment', child: Text('Pending payment')),
                            DropdownMenuItem(value: 'paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                            DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Simpan Status',
                          icon: Icons.save_rounded,
                          isLoading: _saving,
                          onPressed: () => _save(booking),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
