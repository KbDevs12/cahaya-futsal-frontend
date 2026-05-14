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
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenReader();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final message =
              _extractBackendMessage(error.response?.data) ??
              friendlyErrorMessage(error);

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

  static String? _extractBackendMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    return null;
  }
}
