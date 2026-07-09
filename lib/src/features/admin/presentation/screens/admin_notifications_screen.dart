import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/page_padding.dart';
import '../../data/admin_models.dart';
import 'admin_booking_detail_screen.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_common.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  static const route = '/admin/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(adminNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminNotificationsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminNotificationsProvider.future),
        child: PagePadding(
          child: ListView(
            children: [
              AdminAsyncList<AdminNotification>(
                value: notifications,
                emptyTitle: 'Belum ada notifikasi',
                emptyMessage: 'Order/booking baru dari customer akan tampil di sini.',
                onRetry: () => ref.invalidate(adminNotificationsProvider),
                itemBuilder: (notification) => InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: notification.bookingId.isEmpty
                      ? null
                      : () => context.push('${AdminBookingDetailScreen.route}/${notification.bookingId}'),
                  child: AppCard(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon: notification.isRead ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification.customerName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                Text(notification.type),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(notification.message),
                      const SizedBox(height: 8),
                      Text(readableDateTime(notification.createdAt)),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
