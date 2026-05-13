import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/availability/data/models/field_availability.dart';
import '../features/availability/presentation/screens/create_booking_screen.dart';
import '../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/payments/presentation/screens/payment_qr_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.route,
    routes: [
      GoRoute(
        path: SplashScreen.route,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(path: LoginScreen.route, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: RegisterScreen.route,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.route,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            HomeShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: MyBookingsScreen.route,
            builder: (_, __) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: ProfileScreen.route,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: NotificationsScreen.route,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: CreateBookingScreen.route,
        builder: (_, state) {
          final field = state.extra! as FieldAvailability;
          return CreateBookingScreen(field: field);
        },
      ),
      GoRoute(
        path: '${PaymentQrScreen.route}/:bookingId',
        builder: (_, state) =>
            PaymentQrScreen(bookingId: state.pathParameters['bookingId']!),
      ),
      GoRoute(
        path: '${BookingDetailScreen.route}/:bookingId',
        builder: (_, state) =>
            BookingDetailScreen(bookingId: state.pathParameters['bookingId']!),
      ),
    ],
  );
});
