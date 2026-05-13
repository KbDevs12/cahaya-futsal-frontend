import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'models/field_availability.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._dio);

  final Dio _dio;

  Future<List<FieldAvailability>> getAvailability(String date) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/fields/availability',
      queryParameters: {'date': date},
    );

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => FieldAvailability.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
