import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  String errorMessage(Object error) => friendlyErrorMessage(error);
}

String friendlyErrorMessage(Object error) {
  if (error is AppException) {
    return _fromBackendMessage(error.message, statusCode: error.statusCode);
  }

  if (error is FirebaseAuthException) {
    return _fromFirebaseAuth(error);
  }

  if (error is DioException) {
    final inner = error.error;
    if (inner is AppException) return friendlyErrorMessage(inner);

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return _fromBackendMessage(
          message,
          statusCode: error.response?.statusCode,
        );
      }
    }

    return _fromDio(error);
  }

  if (error is FormatException) {
    return 'Data dari server belum sesuai. Coba lagi sebentar lagi.';
  }

  final raw = error.toString().toLowerCase();
  if (raw.contains('firebase') ||
      raw.contains('dioexception') ||
      raw.contains('socketexception')) {
    return 'Terjadi kendala koneksi. Periksa internet kamu lalu coba lagi.';
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}

String _fromFirebaseAuth(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Format email belum benar.';
    case 'user-disabled':
      return 'Akun ini sedang dinonaktifkan. Hubungi admin.';
    case 'user-not-found':
      return 'Email belum terdaftar. Silakan daftar terlebih dahulu.';
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'Email atau password salah.';
    case 'email-already-in-use':
      return 'Email ini sudah terdaftar. Silakan login atau reset password.';
    case 'weak-password':
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi.';
    case 'network-request-failed':
      return 'Koneksi internet bermasalah. Periksa jaringan kamu.';
    case 'operation-not-allowed':
      return 'Login email/password belum aktif.';
    case 'requires-recent-login':
      return 'Sesi kamu perlu diperbarui. Silakan login ulang.';
    case 'missing-password':
      return 'Password wajib diisi.';
    default:
      return 'Autentikasi gagal. Periksa data akun kamu lalu coba lagi.';
  }
}

String _fromDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi ke server terlalu lama. Coba lagi sebentar lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak bisa terhubung ke server. Periksa internet kamu.';
    case DioExceptionType.badCertificate:
      return 'Koneksi ke server tidak aman. Hubungi admin.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badResponse:
      return _fromStatus(error.response?.statusCode);
    case DioExceptionType.unknown:
      return 'Terjadi kendala koneksi. Coba lagi sebentar lagi.';
  }
}

String _fromStatus(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Data yang dikirim belum valid. Periksa kembali input kamu.';
    case 401:
      return 'Sesi kamu sudah berakhir. Silakan login ulang.';
    case 403:
      return 'Kamu tidak punya akses untuk aksi ini.';
    case 404:
      return 'Data yang kamu cari tidak ditemukan.';
    case 409:
      return 'Data sudah berubah. Refresh halaman lalu coba lagi.';
    case 413:
      return 'File terlalu besar. Gunakan gambar maksimal 5MB.';
    case 422:
      return 'Ada data yang belum sesuai. Periksa kembali form kamu.';
    case 500:
    case 502:
    case 503:
    case 504:
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    default:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

String _fromBackendMessage(String message, {int? statusCode}) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty) return _fromStatus(statusCode);

  if (normalized.contains('email') &&
      (normalized.contains('belum') || normalized.contains('not')) &&
      (normalized.contains('verifikasi') || normalized.contains('verified'))) {
    return 'Email kamu belum diverifikasi. Cek inbox/spam, lalu klik link verifikasi sebelum login.';
  }

  if (normalized.contains('verification') && normalized.contains('sent')) {
    return 'Link verifikasi sudah dikirim ulang ke email kamu.';
  }

  if (normalized.contains('invalid') && normalized.contains('credential')) {
    return 'Email atau password salah.';
  }

  if (normalized.contains('token') ||
      normalized.contains('unauthorized') ||
      normalized.contains('jwt')) {
    return 'Sesi kamu sudah berakhir. Silakan login ulang.';
  }

  if (normalized.contains('already booked') ||
      normalized.contains('slot') ||
      normalized.contains('bentrok')) {
    return 'Slot jadwal ini sudah tidak tersedia. Pilih jam lain.';
  }

  if (normalized.contains('payment') && normalized.contains('not found')) {
    return 'Data pembayaran tidak ditemukan.';
  }

  if (normalized.contains('booking') && normalized.contains('not found')) {
    return 'Data booking tidak ditemukan.';
  }

  if (normalized.contains('file') && normalized.contains('too large')) {
    return 'File terlalu besar. Gunakan gambar maksimal 5MB.';
  }

  if (normalized.contains('unsupported') || normalized.contains('format')) {
    return 'Format file belum didukung. Gunakan JPG, PNG, atau WEBP.';
  }

  if (normalized.contains('network') || normalized.contains('connection')) {
    return 'Koneksi bermasalah. Periksa internet kamu lalu coba lagi.';
  }

  if (_looksTechnical(normalized)) {
    return _fromStatus(statusCode);
  }

  return message.trim();
}

bool _looksTechnical(String value) {
  return value.contains('panic') ||
      value.contains('stack') ||
      value.contains('sql') ||
      value.contains('pq:') ||
      value.contains('constraint') ||
      value.contains('dioexception') ||
      value.contains('firebaseauth') ||
      value.contains('exception:') ||
      value.contains('null check operator');
}
