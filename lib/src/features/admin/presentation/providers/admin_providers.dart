import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/admin_models.dart';
import '../../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioProvider));
});

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardData>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).dashboard();
});

final adminBookingStatusFilterProvider = StateProvider<String?>((ref) => null);
final adminBookingDateFilterProvider = StateProvider<String?>((ref) => null);

final adminBookingsProvider =
    FutureProvider.autoDispose<List<AdminBookingSummary>>((ref) {
      return ref
          .watch(adminRepositoryProvider)
          .listBookings(
            status: ref.watch(adminBookingStatusFilterProvider),
            date: ref.watch(adminBookingDateFilterProvider),
          );
    });

final adminPaymentStatusFilterProvider = StateProvider<String?>((ref) => null);
final adminPaymentDateFilterProvider = StateProvider<String?>((ref) => null);
final adminPaymentQueryProvider = StateProvider<String?>((ref) => null);

final adminPaymentsProvider =
    FutureProvider.autoDispose<List<AdminPaymentSummary>>((ref) {
      return ref
          .watch(adminRepositoryProvider)
          .listPayments(
            status: ref.watch(adminPaymentStatusFilterProvider),
            date: ref.watch(adminPaymentDateFilterProvider),
            q: ref.watch(adminPaymentQueryProvider),
          );
    });

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUserRow>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).listUsers();
});

final adminFieldsProvider = FutureProvider.autoDispose<List<AdminFieldRow>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).listFields();
});

final adminFieldSchedulesProvider = FutureProvider.autoDispose
    .family<List<AdminScheduleRow>, String>((ref, fieldId) {
      return ref.watch(adminRepositoryProvider).listSchedules(fieldId);
    });

final adminNotificationsProvider =
    FutureProvider.autoDispose<List<AdminNotification>>((ref) {
      return ref.watch(adminRepositoryProvider).listNotifications();
    });

final adminReportRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final adminRangeReportProvider = FutureProvider.autoDispose<RangeReport>((ref) {
  final range = ref.watch(adminReportRangeProvider);
  String? from;
  String? to;
  if (range != null) {
    from = _ymd(range.start);
    to = _ymd(range.end);
  }
  return ref.watch(adminRepositoryProvider).rangeReport(from: from, to: to);
});

final adminAccountsProvider = FutureProvider.autoDispose<List<AdminAccountRow>>(
  (ref) {
    return ref.watch(adminRepositoryProvider).listAdmins();
  },
);

String _ymd(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
