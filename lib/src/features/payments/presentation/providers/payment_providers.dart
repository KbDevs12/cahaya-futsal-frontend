import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/models/payment_qr.dart';
import '../../data/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(dioProvider));
});

final paymentQrProvider = FutureProvider.autoDispose.family<PaymentQr, String>((ref, bookingId) {
  return ref.watch(paymentRepositoryProvider).getQr(bookingId);
});
