import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/presentation/screens/admin_booking_detail_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const route = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).bootstrap();
      final session = ref.read(authControllerProvider).value;
      final initialBookingId = ref
          .read(fcmServiceProvider)
          .takeInitialBookingId();
      if (!mounted) return;
      if (session == null) {
        context.go(LoginScreen.route);
      } else if (session.isAdmin && initialBookingId != null) {
        context.go('${AdminBookingDetailScreen.route}/$initialBookingId');
      } else if (session.isAdmin) {
        context.go(AdminDashboardScreen.route);
      } else if (initialBookingId != null) {
        context.go('/booking-detail/$initialBookingId');
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.sports_soccer_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Cahaya Futsal',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
