import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  static const route = '/admin/reports';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(adminRangeReportProvider);
    final selectedRange = ref.watch(adminReportRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: selectedRange ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
              );
              if (picked != null) {
                ref.read(adminReportRangeProvider.notifier).state = picked;
              }
            },
            icon: const Icon(Icons.date_range_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminRangeReportProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              report.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(adminRangeReportProvider)),
                data: (data) => _ReportContent(report: data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.report});

  final RangeReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Periode Laporan',
          subtitle: '${readableDate(report.periodStart)} - ${readableDate(report.periodEnd)}',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: AdminStatCard(label: 'Total Booking', value: '${report.totalBookings}', icon: Icons.receipt_long_rounded)),
            const SizedBox(width: 12),
            Expanded(child: AdminStatCard(label: 'Revenue', value: formatRupiah(report.totalRevenue), icon: Icons.account_balance_wallet_rounded, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AdminStatCard(label: 'Paid', value: '${report.paidBookings}', icon: Icons.check_circle_rounded, color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: AdminStatCard(label: 'Cancelled', value: '${report.cancelledBookings}', icon: Icons.cancel_rounded, color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 22),
        const SectionHeader(title: 'Revenue per Hari'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: report.revenueChart.map((point) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(readableDate(point.date)),
                  trailing: Text(formatRupiah(point.revenue), style: const TextStyle(fontWeight: FontWeight.w900)),
                )).toList(),
          ),
        ),
      ],
    );
  }
}
