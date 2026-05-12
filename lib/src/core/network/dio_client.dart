import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

class DioClient {
  const DioClient._();

  static Dio create({
    required String baseUrl,
    required Future<String?> Function() tokenReader,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenReader();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final data = error.response?.data;
          final message = data is Map<String, dynamic>
              ? (data['message'] ?? 'Request gagal').toString()
              : error.message ?? 'Request gagal';
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: AppException(
                message,
                statusCode: error.response?.statusCode,
              ),
              type: error.type,
            ),
          );
        },
      ),
    );

    return dio;
  }
}
