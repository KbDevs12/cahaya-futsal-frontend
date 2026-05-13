import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> readSavedSession();
  Future<AuthSession> login({required String email, required String password});
  Future<void> register({required String name, required String email, required String password});
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
}
