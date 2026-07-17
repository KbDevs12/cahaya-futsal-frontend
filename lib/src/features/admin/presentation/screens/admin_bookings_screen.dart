import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  static const route = '/admin/bookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(adminBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Booking'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminBookingsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBooking(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Booking'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminBookingsProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              _BookingFilters(ref: ref),
              const SizedBox(height: 16),
              AdminAsyncList<AdminBookingSummary>(
                value: bookings,
                emptyTitle: 'Belum ada booking',
                emptyMessage: 'Data booking akan tampil di sini.',
                onRetry: () => ref.invalidate(adminBookingsProvider),
                itemBuilder: (booking) => _BookingCard(
                  booking: booking,
                  onTap: () => _showBookingDetail(context, ref, booking),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBookingDetail(
    BuildContext context,
    WidgetRef ref,
    AdminBookingSummary booking,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(booking: booking),
    );
    ref.invalidate(adminBookingsProvider);
    ref.invalidate(adminPaymentsProvider);
    ref.invalidate(adminDashboardProvider);
  }

  Future<void> _showCreateBooking(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateBookingSheet(),
    );
    ref.invalidate(adminBookingsProvider);
    ref.invalidate(adminPaymentsProvider);
    ref.invalidate(adminDashboardProvider);
  }
}

class _BookingFilters extends StatelessWidget {
  const _BookingFilters({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(adminBookingStatusFilterProvider);
    final date = ref.watch(adminBookingDateFilterProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Filter Booking'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Semua status')),
              DropdownMenuItem(
                value: 'pending_payment',
                child: Text('Pending payment'),
              ),
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) =>
                ref.read(adminBookingStatusFilterProvider.notifier).state =
                    value,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  date == null ? 'Semua tanggal' : readableDate(date),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate:
                        DateTime.tryParse(date ?? '') ?? DateTime.now(),
                  );
                  if (picked != null) {
                    ref.read(adminBookingDateFilterProvider.notifier).state =
                        ymd(picked);
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Tanggal'),
              ),
              IconButton(
                tooltip: 'Reset tanggal',
                onPressed: date == null
                    ? null
                    : () =>
                          ref
                                  .read(adminBookingDateFilterProvider.notifier)
                                  .state =
                              null,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});

  final AdminBookingSummary booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(icon: Icons.receipt_long_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.fieldName} • ${readableDate(booking.date)}',
                    ),
                    Text(
                      '${readableClock(booking.startTime)}-${readableClock(booking.endTime)} • ${formatDurationHours(booking.durationHrs)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AdminStatusLine(
            status: booking.bookingStatus,
            secondary:
                '${booking.paymentStatus} • ${formatRupiah(booking.amount)}',
          ),
        ],
      ),
    );
  }
}

class _BookingDetailSheet extends ConsumerStatefulWidget {
  const _BookingDetailSheet({required this.booking});

  final AdminBookingSummary booking;

  @override
  ConsumerState<_BookingDetailSheet> createState() =>
      _BookingDetailSheetState();
}

class _BookingDetailSheetState extends ConsumerState<_BookingDetailSheet> {
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.booking.bookingStatus;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateBookingStatus(widget.booking.id, _status);
      if (!mounted) return;
      showSnack(context, 'Status booking berhasil diperbarui');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detail Booking',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            AdminInfoRow(label: 'Customer', value: booking.customerName),
            AdminInfoRow(label: 'Email', value: booking.customerEmail),
            AdminInfoRow(label: 'No. HP', value: booking.customerPhone),
            AdminInfoRow(label: 'Lapangan', value: booking.fieldName),
            AdminInfoRow(label: 'Tanggal', value: readableDate(booking.date)),
            AdminInfoRow(
              label: 'Jam',
              value:
                  '${readableClock(booking.startTime)}-${readableClock(booking.endTime)}',
            ),
            AdminInfoRow(label: 'Total', value: formatRupiah(booking.amount)),
            const SizedBox(height: 12),
            StatusChip(status: booking.paymentStatus),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status booking'),
              items: const [
                DropdownMenuItem(
                  value: 'pending_payment',
                  child: Text('Pending payment'),
                ),
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Simpan Status',
              icon: Icons.save_rounded,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateBookingSheet extends ConsumerStatefulWidget {
  const _CreateBookingSheet();

  @override
  ConsumerState<_CreateBookingSheet> createState() =>
      _CreateBookingSheetState();
}

class _CreateBookingSheetState extends ConsumerState<_CreateBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(text: ymd(DateTime.now()));
  final _startController = TextEditingController(text: '08:00');
  final _endController = TextEditingController(text: '09:00');
  String? _userId;
  String? _fieldId;
  bool _markPaid = false;
  bool _saving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _userId == null ||
        _fieldId == null) {
      showSnack(context, 'User dan lapangan wajib dipilih', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).createBooking({
        'user_id': _userId,
        'field_id': _fieldId,
        'date': _dateController.text.trim(),
        'start_time': _startController.text.trim(),
        'end_time': _endController.text.trim(),
        'mark_paid': _markPaid,
      });
      if (!mounted) return;
      showSnack(context, 'Booking berhasil dibuat');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider);
    final fields = ref.watch(adminFieldsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Booking Manual',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              users.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) =>
                    Text('Gagal load user: ${friendlyErrorMessage(error)}'),
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _userId,
                  decoration: const InputDecoration(labelText: 'User'),
                  items: items
                      .map(
                        (u) => DropdownMenuItem(
                          value: u.id,
                          child: Text('${u.name} • ${u.email}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _userId = value),
                ),
              ),
              const SizedBox(height: 12),
              fields.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) =>
                    Text('Gagal load lapangan: ${friendlyErrorMessage(error)}'),
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _fieldId,
                  decoration: const InputDecoration(labelText: 'Lapangan'),
                  items: items
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            '${f.name} • ${formatRupiah(f.pricePerHour)}/jam',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _fieldId = value),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _dateController,
                label: 'Tanggal (YYYY-MM-DD)',
                prefixIcon: Icons.calendar_month_rounded,
                validator: (value) =>
                    value == null || DateTime.tryParse(value) == null
                    ? 'Tanggal tidak valid'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _startController,
                      label: 'Mulai',
                      prefixIcon: Icons.access_time_rounded,
                      validator: (value) => value == null || value.length < 5
                          ? 'Wajib diisi'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _endController,
                      label: 'Selesai',
                      prefixIcon: Icons.access_time_filled_rounded,
                      validator: (value) => value == null || value.length < 5
                          ? 'Wajib diisi'
                          : null,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _markPaid,
                onChanged: (value) => setState(() => _markPaid = value),
                title: const Text('Tandai sudah dibayar'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Buat Booking',
                icon: Icons.save_rounded,
                isLoading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
