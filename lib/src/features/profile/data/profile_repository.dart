import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/user/profile');

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/user/profile',
      data: {'name': name, 'phone': phone},
    );

    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }
}
