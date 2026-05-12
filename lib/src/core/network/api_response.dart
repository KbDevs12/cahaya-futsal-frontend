import '../errors/app_exception.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final T data;

  static T parseData<T>(
    dynamic raw, {
    required T Function(dynamic json) mapper,
    int? statusCode,
  }) {
    if (raw is! Map<String, dynamic>) {
      throw AppException("Format response tidak valid", statusCode: statusCode);
    }

    final success = raw["success"] == true;
    final message = (raw["message"] ?? "terjadi kesalahan").toString();

    if (!success) {
      throw AppException(message, statusCode: statusCode);
    }

    return mapper(raw["data"]);
  }
}
