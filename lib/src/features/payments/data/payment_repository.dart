import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'models/payment_qr.dart';

class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  Future<PaymentQr> getQr(String bookingId) async {
    final response = await _dio.get<Map<String, dynamic>>('/payments/$bookingId/qr');

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => PaymentQr.fromJson(json as Map<String, dynamic>),
    );
  }
}
