import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import '../domain/entities/auth_session.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> loginWithFirebaseToken(String token) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'firebase_id_token': token},
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthSession> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/admin-login',
      data: {'email': email.trim(), 'password': password},
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }
}
