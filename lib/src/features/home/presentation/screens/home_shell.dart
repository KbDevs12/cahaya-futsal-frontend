import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../availability/presentation/providers/availability_providers.dart';
import '../../../availability/presentation/widgets/date_strip.dart';
import '../../../availability/presentation/widgets/field_card.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final index = switch (location) {
      MyBookingsScreen.route => 1,
      ProfileScreen.route => 2,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              context.go('/');
            case 1:
              context.go(MyBookingsScreen.route);
            case 2:
              context.go(ProfileScreen.route);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final availability = ref.watch(availabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arena'),
        actions: [
          IconButton(
            onPressed: () => context.push(NotificationsScreen.route),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(availabilityProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking lapangan tanpa ribet.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih tanggal, ambil slot kosong, lalu bayar via QRIS.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DateStrip(
              selectedDate: selectedDate,
              onChanged: (date) => ref.read(selectedDateProvider.notifier).state = date,
            ),
            const SizedBox(height: 18),
            Text(
              'Lapangan tersedia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            availability.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(availabilityProvider),
              ),
              data: (fields) {
                if (fields.isEmpty) {
                  return const EmptyState(
                    title: 'Tidak ada lapangan',
                    message: 'Coba pilih tanggal lain.',
                    icon: Icons.stadium_outlined,
                  );
                }
                return Column(
                  children: fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FieldCard(
                            field: field,
                            onTap: () => context.push('/create-booking', extra: field),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
