import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../bookings/presentation/screens/booking_detail_screen.dart';
import '../../data/models/notification_item.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const route = '/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    title: 'Belum ada notifikasi',
                    message: 'Update booking dan pembayaran dari admin akan muncul di sini.',
                    icon: Icons.notifications_none_rounded,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: items.length + 1,
              separatorBuilder: (_, index) => index == 0 ? const SizedBox(height: 16) : const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) return const _NotificationInfoCard();

                final item = items[index - 1];
                return _NotificationCard(
                  item: item,
                  onOpenBooking: item.bookingId == null
                      ? null
                      : () => context.push('${BookingDetailScreen.route}/${item.bookingId}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationInfoCard extends StatelessWidget {
  const _NotificationInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status pembayaran dari admin',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Saat admin confirm atau reject pembayaran, backend akan mengirim push notification ke HP kamu dan menyimpannya di halaman ini.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, this.onOpenBooking});

  final NotificationItem item;
  final VoidCallback? onOpenBooking;

  @override
  Widget build(BuildContext context) {
    final color = item.isPaymentConfirmed
        ? AppColors.success
        : item.isPaymentRejected
            ? AppColors.danger
            : AppColors.primary;
    final icon = item.isPaymentConfirmed
        ? Icons.verified_rounded
        : item.isPaymentRejected
            ? Icons.cancel_rounded
            : Icons.notifications_rounded;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpenBooking,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            _StatusPill(label: item.statusText, color: color),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: const TextStyle(color: AppColors.ink, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo(item.createdAt),
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const Spacer(),
                  if (onOpenBooking != null)
                    const Row(
                      children: [
                        Text(
                          'Buka booking',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
