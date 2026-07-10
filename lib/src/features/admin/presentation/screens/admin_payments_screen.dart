import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class AdminPaymentsScreen extends ConsumerWidget {
  const AdminPaymentsScreen({super.key});

  static const route = '/admin/payments';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(adminPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pembayaran'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminPaymentsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminPaymentsProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              _PaymentFilters(ref: ref),
              const SizedBox(height: 16),
              AdminAsyncList<AdminPaymentSummary>(
                value: payments,
                emptyTitle: 'Belum ada pembayaran',
                emptyMessage: 'Data pembayaran customer akan tampil di sini.',
                onRetry: () => ref.invalidate(adminPaymentsProvider),
                itemBuilder: (payment) => _PaymentCard(
                  payment: payment,
                  onTap: () => _showPaymentDetail(context, ref, payment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentDetail(
    BuildContext context,
    WidgetRef ref,
    AdminPaymentSummary payment,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentDetailSheet(payment: payment),
    );
    ref.invalidate(adminPaymentsProvider);
    ref.invalidate(adminBookingsProvider);
    ref.invalidate(adminDashboardProvider);
  }
}

class _PaymentFilters extends StatefulWidget {
  const _PaymentFilters({required this.ref});

  final WidgetRef ref;

  @override
  State<_PaymentFilters> createState() => _PaymentFiltersState();
}

class _PaymentFiltersState extends State<_PaymentFilters> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;
    final status = ref.watch(adminPaymentStatusFilterProvider);
    final date = ref.watch(adminPaymentDateFilterProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Filter Pembayaran'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status pembayaran'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Semua status')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(
                value: 'awaiting_verification',
                child: Text('Menunggu verifikasi'),
              ),
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (value) =>
                ref.read(adminPaymentStatusFilterProvider.notifier).state =
                    value,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: _queryController,
            label: 'Cari customer/lapangan',
            prefixIcon: Icons.search_rounded,
            textInputAction: TextInputAction.search,
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
                  FocusScope.of(context).unfocus();
                  ref.read(adminPaymentQueryProvider.notifier).state =
                      _queryController.text.trim();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate:
                        DateTime.tryParse(date ?? '') ?? DateTime.now(),
                  );
                  if (picked != null) {
                    ref.read(adminPaymentDateFilterProvider.notifier).state =
                        ymd(picked);
                  }
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Tanggal'),
              ),
              IconButton(
                tooltip: 'Cari',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  ref.read(adminPaymentQueryProvider.notifier).state =
                      _queryController.text.trim();
                },
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                tooltip: 'Reset tanggal',
                onPressed: date == null
                    ? null
                    : () =>
                          ref
                                  .read(adminPaymentDateFilterProvider.notifier)
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.onTap});

  final AdminPaymentSummary payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(icon: Icons.payments_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.fieldName} • ${readableDate(payment.date)}',
                    ),
                    Text(
                      '${readableClock(payment.startTime)}-${readableClock(payment.endTime)}',
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(payment.amount),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AdminStatusLine(
            status: payment.paymentStatus,
            secondary: payment.proofImageUrl.isEmpty
                ? 'Belum ada bukti'
                : 'Bukti pembayaran tersedia',
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailSheet extends ConsumerStatefulWidget {
  const _PaymentDetailSheet({required this.payment});

  final AdminPaymentSummary payment;

  @override
  ConsumerState<_PaymentDetailSheet> createState() =>
      _PaymentDetailSheetState();
}

class _PaymentDetailSheetState extends ConsumerState<_PaymentDetailSheet> {
  bool _saving = false;

  bool get _canVerify {
    final status = widget.payment.paymentStatus.toLowerCase();
    return status == 'pending' || status == 'awaiting_verification';
  }

  Future<void> _action(bool confirm) async {
    if (!_canVerify) return;
    setState(() => _saving = true);
    try {
      if (confirm) {
        await ref
            .read(adminRepositoryProvider)
            .confirmPayment(widget.payment.bookingId);
      } else {
        await ref
            .read(adminRepositoryProvider)
            .rejectPayment(widget.payment.bookingId);
      }
      if (!mounted) return;
      showSnack(
        context,
        confirm ? 'Pembayaran dikonfirmasi' : 'Pembayaran ditolak',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showAdminError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
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
              'Detail Pembayaran',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            AdminInfoRow(label: 'Customer', value: payment.customerName),
            AdminInfoRow(label: 'Email', value: payment.customerEmail),
            AdminInfoRow(label: 'Lapangan', value: payment.fieldName),
            AdminInfoRow(label: 'Tanggal', value: readableDate(payment.date)),
            AdminInfoRow(
              label: 'Jam',
              value:
                  '${readableClock(payment.startTime)}-${readableClock(payment.endTime)}',
            ),
            AdminInfoRow(label: 'Total', value: formatRupiah(payment.amount)),
            AdminInfoRow(
              label: 'Submitted',
              value: readableDateTime(payment.submittedAt),
            ),
            _ProofPaymentRow(imageUrl: payment.proofImageUrl),
            AdminInfoRow(label: 'Catatan', value: payment.proofNote),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(status: payment.paymentStatus),
                StatusChip(status: payment.bookingStatus),
              ],
            ),
            const SizedBox(height: 18),
            if (!_canVerify)
              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pembayaran dengan status ${payment.paymentStatus} sudah final, jadi tidak bisa dikonfirmasi atau ditolak lagi.',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : () => _action(false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Konfirmasi',
                      icon: Icons.check_rounded,
                      isLoading: _saving,
                      onPressed: () => _action(true),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProofPaymentRow extends StatelessWidget {
  const _ProofPaymentRow({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasProof = imageUrl.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 116,
            child: Text(
              'Bukti pembayaran',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: hasProof
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _showProofDialog(context),
                      icon: const Icon(Icons.image_rounded),
                      label: const Text('Lihat bukti'),
                    ),
                  )
                : const Text(
                    '-',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProofDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    Text(
                      'Bukti Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 260,
                        child: Center(
                          child: Text('Gagal memuat gambar bukti pembayaran'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
