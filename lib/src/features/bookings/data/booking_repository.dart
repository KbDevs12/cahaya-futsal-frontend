import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'models/booking.dart';

class BookingRepository {
  BookingRepository(this._dio);

  final Dio _dio;

  Future<Booking> create(CreateBookingRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/bookings',
      data: request.toJson(),
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<Booking>> listMine() async {
    final response = await _dio.get<Map<String, dynamic>>('/bookings');

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Booking> detail(String bookingId) async {
    final response = await _dio.get<Map<String, dynamic>>('/bookings/$bookingId');

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> cancel(String bookingId) async {
    final response = await _dio.patch<Map<String, dynamic>>('/bookings/$bookingId/cancel');
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }
}
