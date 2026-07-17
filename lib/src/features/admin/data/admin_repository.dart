import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'admin_models.dart';

class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  Future<AdminDashboardData> dashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/dashboard');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) =>
          AdminDashboardData.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<AdminBookingSummary>> listBookings({
    String? status,
    String? date,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/bookings',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map(
            (item) =>
                AdminBookingSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<AdminBookingSummary> bookingDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/bookings/$id',
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) =>
          AdminBookingSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> createBooking(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/bookings',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/bookings/$bookingId/status',
      data: {'status': status},
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<List<AdminPaymentSummary>> listPayments({
    String? status,
    String? date,
    String? q,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/payments',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map(
            (item) =>
                AdminPaymentSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<AdminPaymentSummary> paymentDetail(String bookingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/payments/$bookingId',
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) =>
          AdminPaymentSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> confirmPayment(String bookingId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/payments/$bookingId/confirm',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> rejectPayment(String bookingId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/payments/$bookingId/reject',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<List<AdminUserRow>> listUsers() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/users');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => AdminUserRow.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> createUser(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/users',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<AdminUserDetail> userDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/users/$id');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => AdminUserDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> updateUser(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/users/$id',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> deleteUser(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/admin/users/$id',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<List<AdminFieldRow>> listFields() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/fields');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => AdminFieldRow.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<AdminFieldRow> fieldDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/fields/$id');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => AdminFieldRow.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> createField(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/fields',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> updateField(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/fields/$id',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> deleteField(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/admin/fields/$id',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<List<AdminScheduleRow>> listSchedules(String fieldId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/fields/$fieldId/schedules',
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map(
            (item) => AdminScheduleRow.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<void> upsertSchedule(
    String fieldId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/admin/fields/$fieldId/schedules',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> deleteSchedule(String fieldId, String date) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/admin/fields/$fieldId/schedules/$date',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<List<AdminNotification>> listNotifications() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/notifications',
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map(
            (item) => AdminNotification.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<DailyReport> dailyReport({String? date}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/reports/daily',
      queryParameters: {if (date != null && date.isNotEmpty) 'date': date},
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => DailyReport.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<RangeReport> rangeReport({String? from, String? to}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/reports/range',
      queryParameters: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
    );
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => RangeReport.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<int>> exportRangeReportExcel({String? from, String? to}) async {
    final response = await _dio.get<List<int>>(
      '/admin/reports/range/export',
      queryParameters: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
      options: Options(responseType: ResponseType.bytes),
    );

    if ((response.statusCode ?? 500) < 200 ||
        (response.statusCode ?? 500) >= 300) {
      throw Exception('Gagal membuat file Excel laporan');
    }

    return response.data ?? <int>[];
  }

  Future<List<AdminAccountRow>> listAdmins() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/admins');
    return ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (json) => (json as List)
          .map((item) => AdminAccountRow.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> createAdmin(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/admins',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> updateAdmin(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/admins/$id',
      data: payload,
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }

  Future<void> deleteAdmin(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/admin/admins/$id',
    );
    ApiResponse.parseData(
      response.data,
      statusCode: response.statusCode,
      mapper: (_) => null,
    );
  }
}
