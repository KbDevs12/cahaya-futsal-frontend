import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/availability_repository.dart';
import '../../data/models/field_availability.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.watch(dioProvider));
});

final availabilityProvider =
    FutureProvider.autoDispose<List<FieldAvailability>>((ref) {
      final date = ref.watch(selectedDateProvider);
      return ref
          .watch(availabilityRepositoryProvider)
          .getAvailability(ymd(date));
    });
