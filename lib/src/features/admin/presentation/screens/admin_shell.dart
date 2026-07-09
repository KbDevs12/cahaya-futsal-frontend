import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_bookings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_fields_screen.dart';
import 'admin_more_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_users_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final index = switch (location) {
      AdminBookingsScreen.route => 1,
      AdminPaymentsScreen.route => 2,
      AdminFieldsScreen.route => 3,
      AdminUsersScreen.route => 4,
      AdminMoreScreen.route => 5,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              context.go(AdminDashboardScreen.route);
            case 1:
              context.go(AdminBookingsScreen.route);
            case 2:
              context.go(AdminPaymentsScreen.route);
            case 3:
              context.go(AdminFieldsScreen.route);
            case 4:
              context.go(AdminUsersScreen.route);
            case 5:
              context.go(AdminMoreScreen.route);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_rounded),
            label: 'Bayar',
          ),
          NavigationDestination(
            icon: Icon(Icons.stadium_rounded),
            label: 'Lapangan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_rounded),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}
