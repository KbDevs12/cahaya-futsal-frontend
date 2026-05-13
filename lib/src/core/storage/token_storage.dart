import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entities/auth_session.dart';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'auth_session';

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSession?> readSession() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null || value.isEmpty) return null;
    return AuthSession.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<String?> readToken() async {
    final session = await readSession();
    return session?.accessToken;
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
