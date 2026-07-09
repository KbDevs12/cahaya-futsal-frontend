import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
  }) : _firebaseAuth = firebaseAuth,
       _remote = remote,
       _tokenStorage = tokenStorage;

  final FirebaseAuth _firebaseAuth;
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession?> readSavedSession() => _tokenStorage.readSession();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    await user?.reload();
    final freshUser = _firebaseAuth.currentUser;

    if (freshUser == null) {
      throw AppException('Login Firebase gagal');
    }

    if (!freshUser.emailVerified) {
      await freshUser.sendEmailVerification();
      throw AppException(
        'Email belum diverifikasi. Link verifikasi sudah dikirim ulang.',
      );
    }

    final idToken = await freshUser.getIdToken(true);
    final session = await _remote.loginWithFirebaseToken(idToken!);
    await _tokenStorage.saveSession(session);
    return session;
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<AuthSession> adminLogin({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signOut();
    final session = await _remote.adminLogin(email: email, password: password);
    await _tokenStorage.saveSession(session);
    return session;
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      throw AppException('Email wajib diisi');
    }

    await _firebaseAuth.setLanguageCode('id');
    await _firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _tokenStorage.clear();
  }
}
