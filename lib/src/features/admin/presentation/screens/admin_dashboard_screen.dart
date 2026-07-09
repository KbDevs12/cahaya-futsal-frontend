import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';
import 'admin_bookings_screen.dart';
import 'admin_notifications_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const route = '/admin';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);
    final session = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${session?.role == 'superadmin' ? 'Superadmin' : 'Admin'}'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Notifikasi Admin',
            onPressed: () => context.push(AdminNotificationsScreen.route),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(LoginScreen.route);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminDashboardProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              _AdminHero(name: session?.name ?? 'Admin'),
              const SizedBox(height: 18),
              dashboard.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => ErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(adminDashboardProvider),
                ),
                data: (data) => _DashboardContent(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
              ),
              const Spacer(),
              const Text('Admin Mobile', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Halo, $name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola booking, pembayaran, lapangan, user, laporan, dan admin dari aplikasi mobile.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Booking Hari Ini',
                value: '${data.totalBookings}',
                icon: Icons.event_available_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                label: 'Pending Bayar',
                value: '${data.pendingPayment}',
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Revenue Hari Ini',
                value: formatRupiah(data.revenueToday),
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatCard(
                label: 'Total User',
                value: '${data.totalUsers}',
                icon: Icons.people_alt_rounded,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionHeader(
          title: 'Revenue 7 Hari',
          subtitle: 'Ringkasan pemasukan dari pembayaran yang sudah paid/confirmed.',
        ),
        const SizedBox(height: 12),
        AppCard(child: _RevenueList(points: data.revenueChart)),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'Booking Pending',
          subtitle: '5 booking terbaru yang perlu dipantau.',
          trailing: TextButton(
            onPressed: () => context.go(AdminBookingsScreen.route),
            child: const Text('Lihat semua'),
          ),
        ),
        const SizedBox(height: 12),
        if (data.recentPending.isEmpty)
          const AppCard(
            child: Text('Tidak ada booking pending saat ini.'),
          )
        else
          ...data.recentPending.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PendingBookingCard(item: item),
              )),
      ],
    );
  }
}

class _RevenueList extends StatelessWidget {
  const _RevenueList({required this.points});

  final List<RevenueChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Text('Belum ada data revenue.');
    final maxRevenue = points.map((e) => e.revenue).fold<int>(0, (a, b) => a > b ? a : b);
    return Column(
      children: points.map((point) {
        final ratio = maxRevenue == 0 ? 0.0 : point.revenue / maxRevenue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(width: 64, child: Text(point.date.substring(5))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: ratio, minHeight: 10),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: Text(
                  formatRupiah(point.revenue),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PendingBookingCard extends StatelessWidget {
  const _PendingBookingCard({required this.item});

  final RecentPendingBooking item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(AdminBookingsScreen.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.customerName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('${item.fieldName} • ${readableDate(item.date)} • ${readableClock(item.startTime)}-${readableClock(item.endTime)}'),
          const SizedBox(height: 10),
          AdminStatusLine(status: 'pending_payment', secondary: formatRupiah(item.amount)),
        ],
      ),
    );
  }
}
