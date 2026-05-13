import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../bookings/presentation/widgets/booking_card.dart';
import '../providers/booking_providers.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  static const route = '/bookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Saya')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myBookingsProvider.future),
        child: bookings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(myBookingsProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'Belum ada booking',
                message: 'Booking lapangan pertama kamu dari halaman Home.',
                icon: Icons.calendar_month_rounded,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (_, index) => BookingCard(
                booking: items[index],
                onTap: () => context.push('${BookingDetailScreen.route}/${items[index].id}'),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}
