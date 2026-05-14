import 'package:dio/dio.dart';

import 'dart:typed_data';
import '../../../core/network/api_response.dart';
import 'models/payment_proof_submission.dart';
import 'models/payment_qr.dart';

class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  Future<PaymentQr> getQr(String bookingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/payments/$bookingId/qr',
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => PaymentQr.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PaymentProofSubmission> submitProof({
    required String bookingId,
    required Uint8List bytes,
    required String fileName,
    String? note,
  }) async {
    final formData = FormData.fromMap({
      'proof_image': MultipartFile.fromBytes(bytes, filename: fileName),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/$bookingId/proof',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) =>
          PaymentProofSubmission.fromJson(json as Map<String, dynamic>),
    );
  }
}
