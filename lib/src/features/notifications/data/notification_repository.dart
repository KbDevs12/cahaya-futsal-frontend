import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'models/notification_item.dart';

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<List<NotificationItem>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/user/notifications');

    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
