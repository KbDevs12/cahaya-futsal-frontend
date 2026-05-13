import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../notifications/fcm_service.dart';
import '../storage/token_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    baseUrl: AppConfig.apiBaseUrl,
    tokenReader: () => ref.read(tokenStorageProvider).readToken(),
  );
});


final fcmServiceProvider = Provider<FcmService>((ref) {
  final service = FcmService(
    dio: ref.watch(dioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final fcmBookingTapProvider = StreamProvider<String>((ref) {
  return ref.watch(fcmServiceProvider).bookingTapStream;
});
