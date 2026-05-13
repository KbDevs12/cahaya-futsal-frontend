import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/bookings/presentation/screens/booking_detail_screen.dart';
import 'router.dart';

class FutsalUserApp extends ConsumerWidget {
  const FutsalUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    ref.listen(fcmBookingTapProvider, (_, next) {
      next.whenData((bookingId) {
        router.push('${BookingDetailScreen.route}/$bookingId');
      });
    });

    return MaterialApp.router(
      title: 'Cahaya Futsal Booking App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
