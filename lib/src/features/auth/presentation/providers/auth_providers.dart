import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/notifications/fcm_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/auth_remote_data_source.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(
        repository: ref.watch(authRepositoryProvider),
        fcmService: ref.watch(fcmServiceProvider),
      );
    });

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController({
    required AuthRepository repository,
    required FcmService fcmService,
  }) : _repository = repository,
       _fcmService = fcmService,
       super(const AsyncValue.loading());

  final AuthRepository _repository;
  final FcmService _fcmService;

  Future<void> bootstrap() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.readSavedSession();
      if (session != null) {
        await _fcmService.initializeAndRegister();
      }
      return session;
    });
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.login(email: email, password: password);
      await _fcmService.initializeAndRegister();
      return session;
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _repository.register(name: name, email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }

  Future<void> logout() async {
    await _fcmService.unregisterCurrentToken();
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
