import "package:dio/dio.dart";
import "package:firebase_auth/firebase_auth.dart";

class AppException implements Exception {
  AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  String errorMessage(Object error) {
    if (error is AppException) return error.message;
    if (error is DioException && error.error != null) {
      return errorMessage(error.error!);
    }
    if (error is FirebaseAuthException) {
      return error.message ?? error.code;
    }

    return error.toString().replaceFirst("Exception: ", "");
  }
}
