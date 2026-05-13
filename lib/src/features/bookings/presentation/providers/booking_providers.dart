import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/booking_repository.dart';
import '../../data/models/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});

final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).listMine();
});

final bookingDetailProvider = FutureProvider.autoDispose.family<Booking, String>((ref, id) {
  return ref.watch(bookingRepositoryProvider).detail(id);
});
