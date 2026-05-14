import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../availability/presentation/providers/availability_providers.dart';
import '../../../availability/presentation/widgets/date_strip.dart';
import '../../../availability/presentation/widgets/field_card.dart';
import '../../../bookings/presentation/screens/my_bookings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

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
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
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
          IconButton.filledTonal(
            tooltip: 'Notifikasi',
            onPressed: () => context.push(NotificationsScreen.route),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(availabilityProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _HomeHero(selectedDateText: _readableDate(selectedDate)),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Pilih tanggal',
              subtitle: 'Cek slot lapangan yang tersedia.',
              trailing: IconButton(
                tooltip: 'Refresh',
                onPressed: () => ref.invalidate(availabilityProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DateStrip(
              selectedDate: selectedDate,
              onChanged: (date) =>
                  ref.read(selectedDateProvider.notifier).state = date,
            ),
            const SizedBox(height: 22),
            const SectionHeader(
              title: 'Lapangan tersedia',
              subtitle: 'Tap lapangan untuk lanjut pilih jam booking.',
            ),
            const SizedBox(height: 12),
            availability.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 70),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(availabilityProvider),
              ),
              data: (fields) {
                if (fields.isEmpty) {
                  return const EmptyState(
                    title: 'Belum ada lapangan',
                    message:
                        'Coba pilih tanggal lain atau refresh data jadwal.',
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
                            onTap: () =>
                                context.push('/create-booking', extra: field),
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

  String _readableDate(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.selectedDateText});

  final String selectedDateText;

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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
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
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  selectedDateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Booking lapangan tanpa ribet.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pilih jadwal kosong, bayar via QRIS, upload bukti, dan tunggu verifikasi admin.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
