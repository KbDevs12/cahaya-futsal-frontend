class AdminJson {
  const AdminJson._();

  static String string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  static int integer(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double decimal(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static bool boolean(dynamic value, [bool fallback = false]) {
    if (value == null) return fallback;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? dateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class RevenueChartPoint {
  const RevenueChartPoint({required this.date, required this.revenue});

  final String date;
  final int revenue;

  factory RevenueChartPoint.fromJson(Map<String, dynamic> json) {
    return RevenueChartPoint(
      date: AdminJson.string(json['date']),
      revenue: AdminJson.integer(json['revenue']),
    );
  }
}

class RecentPendingBooking {
  const RecentPendingBooking({
    required this.bookingId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.customerName,
    required this.fieldName,
    required this.amount,
    required this.bookedAt,
  });

  final String bookingId;
  final String date;
  final String startTime;
  final String endTime;
  final String customerName;
  final String fieldName;
  final int amount;
  final DateTime? bookedAt;

  factory RecentPendingBooking.fromJson(Map<String, dynamic> json) {
    return RecentPendingBooking(
      bookingId: AdminJson.string(json['booking_id']),
      date: AdminJson.string(json['date']),
      startTime: AdminJson.string(json['start_time']),
      endTime: AdminJson.string(json['end_time']),
      customerName: AdminJson.string(json['customer_name']),
      fieldName: AdminJson.string(json['field_name']),
      amount: AdminJson.integer(json['amount']),
      bookedAt: AdminJson.dateTime(json['booked_at']),
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.today,
    required this.totalBookings,
    required this.pendingPayment,
    required this.paidBookings,
    required this.revenueToday,
    required this.totalUsers,
    required this.revenueChart,
    required this.recentPending,
  });

  final String today;
  final int totalBookings;
  final int pendingPayment;
  final int paidBookings;
  final int revenueToday;
  final int totalUsers;
  final List<RevenueChartPoint> revenueChart;
  final List<RecentPendingBooking> recentPending;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      today: AdminJson.string(json['today']),
      totalBookings: AdminJson.integer(json['total_bookings']),
      pendingPayment: AdminJson.integer(json['pending_payment']),
      paidBookings: AdminJson.integer(json['paid_bookings']),
      revenueToday: AdminJson.integer(json['revenue_today']),
      totalUsers: AdminJson.integer(json['total_users']),
      revenueChart: (json['revenue_chart'] as List? ?? [])
          .map(
            (item) => RevenueChartPoint.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      recentPending: (json['recent_pending'] as List? ?? [])
          .map(
            (item) =>
                RecentPendingBooking.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class AdminBookingSummary {
  const AdminBookingSummary({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHrs,
    required this.bookingStatus,
    required this.bookedAt,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.fieldId,
    required this.fieldName,
    required this.fieldType,
    required this.paymentId,
    required this.amount,
    required this.qrCode,
    required this.qrType,
    required this.paymentStatus,
    required this.paidAt,
    required this.confirmedAt,
  });

  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final double durationHrs;
  final String bookingStatus;
  final DateTime? bookedAt;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String fieldId;
  final String fieldName;
  final String fieldType;
  final String paymentId;
  final int amount;
  final String qrCode;
  final String qrType;
  final String paymentStatus;
  final DateTime? paidAt;
  final DateTime? confirmedAt;

  factory AdminBookingSummary.fromJson(Map<String, dynamic> json) {
    return AdminBookingSummary(
      id: AdminJson.string(json['id']),
      date: AdminJson.string(json['date']),
      startTime: AdminJson.string(json['start_time']),
      endTime: AdminJson.string(json['end_time']),
      durationHrs: AdminJson.decimal(json['duration_hrs']),
      bookingStatus: AdminJson.string(json['booking_status']),
      bookedAt: AdminJson.dateTime(json['booked_at']),
      userId: AdminJson.string(json['user_id']),
      customerName: AdminJson.string(json['customer_name']),
      customerEmail: AdminJson.string(json['customer_email']),
      customerPhone: AdminJson.string(json['customer_phone']),
      fieldId: AdminJson.string(json['field_id']),
      fieldName: AdminJson.string(json['field_name']),
      fieldType: AdminJson.string(json['field_type']),
      paymentId: AdminJson.string(json['payment_id']),
      amount: AdminJson.integer(json['amount']),
      qrCode: AdminJson.string(json['qr_code']),
      qrType: AdminJson.string(json['qr_type'], 'dynamic'),
      paymentStatus: AdminJson.string(json['payment_status'], 'pending'),
      paidAt: AdminJson.dateTime(json['paid_at']),
      confirmedAt: AdminJson.dateTime(json['confirmed_at']),
    );
  }
}

class AdminPaymentSummary {
  const AdminPaymentSummary({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.qrCode,
    required this.qrType,
    required this.paymentStatus,
    required this.paidAt,
    required this.confirmedAt,
    required this.confirmedBy,
    required this.proofImageUrl,
    required this.proofObjectKey,
    required this.proofNote,
    required this.submittedAt,
    required this.bookingStatus,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.customerName,
    required this.customerEmail,
    required this.fieldName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookingId;
  final int amount;
  final String qrCode;
  final String qrType;
  final String paymentStatus;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final String confirmedBy;
  final String proofImageUrl;
  final String proofObjectKey;
  final String proofNote;
  final DateTime? submittedAt;
  final String bookingStatus;
  final String date;
  final String startTime;
  final String endTime;
  final String customerName;
  final String customerEmail;
  final String fieldName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AdminPaymentSummary.fromJson(Map<String, dynamic> json) {
    return AdminPaymentSummary(
      id: AdminJson.string(json['id']),
      bookingId: AdminJson.string(json['booking_id']),
      amount: AdminJson.integer(json['amount']),
      qrCode: AdminJson.string(json['qr_code']),
      qrType: AdminJson.string(json['qr_type'], 'dynamic'),
      paymentStatus: AdminJson.string(json['payment_status']),
      paidAt: AdminJson.dateTime(json['paid_at']),
      confirmedAt: AdminJson.dateTime(json['confirmed_at']),
      confirmedBy: AdminJson.string(json['confirmed_by']),
      proofImageUrl: AdminJson.string(json['proof_image_url']),
      proofObjectKey: AdminJson.string(json['proof_object_key']),
      proofNote: AdminJson.string(json['proof_note']),
      submittedAt: AdminJson.dateTime(json['submitted_at']),
      bookingStatus: AdminJson.string(json['booking_status']),
      date: AdminJson.string(json['date']),
      startTime: AdminJson.string(json['start_time']),
      endTime: AdminJson.string(json['end_time']),
      customerName: AdminJson.string(json['customer_name']),
      customerEmail: AdminJson.string(json['customer_email']),
      fieldName: AdminJson.string(json['field_name']),
      createdAt: AdminJson.dateTime(json['created_at']),
      updatedAt: AdminJson.dateTime(json['updated_at']),
    );
  }
}

class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.lastLoginAt,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  factory AdminUserRow.fromJson(Map<String, dynamic> json) {
    return AdminUserRow(
      id: AdminJson.string(json['id']),
      name: AdminJson.string(json['name']),
      email: AdminJson.string(json['email']),
      phone: AdminJson.string(json['phone']),
      emailVerified: AdminJson.boolean(json['email_verified']),
      lastLoginAt: AdminJson.dateTime(json['last_login_at']),
      createdAt: AdminJson.dateTime(json['created_at']),
    );
  }
}

class AdminUserDetail extends AdminUserRow {
  const AdminUserDetail({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.emailVerified,
    required super.lastLoginAt,
    required super.createdAt,
    required this.firebaseUid,
    required this.lastActivityAt,
    required this.totalBookings,
    required this.totalSpent,
  });

  final String firebaseUid;
  final DateTime? lastActivityAt;
  final int totalBookings;
  final int totalSpent;

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    return AdminUserDetail(
      id: AdminJson.string(json['id']),
      name: AdminJson.string(json['name']),
      email: AdminJson.string(json['email']),
      phone: AdminJson.string(json['phone']),
      emailVerified: AdminJson.boolean(json['email_verified']),
      lastLoginAt: AdminJson.dateTime(json['last_login_at']),
      createdAt: AdminJson.dateTime(json['created_at']),
      firebaseUid: AdminJson.string(json['firebase_uid']),
      lastActivityAt: AdminJson.dateTime(json['last_activity_at']),
      totalBookings: AdminJson.integer(json['total_bookings']),
      totalSpent: AdminJson.integer(json['total_spent']),
    );
  }
}

class AdminFieldRow {
  const AdminFieldRow({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.pricePerHour,
    required this.isAvailable,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final int pricePerHour;
  final bool isAvailable;
  final DateTime? createdAt;

  factory AdminFieldRow.fromJson(Map<String, dynamic> json) {
    return AdminFieldRow(
      id: AdminJson.string(json['id']),
      name: AdminJson.string(json['name']),
      type: AdminJson.string(json['type'], 'futsal'),
      description: AdminJson.string(json['description']),
      pricePerHour: AdminJson.integer(json['price_per_hour']),
      isAvailable: AdminJson.boolean(json['is_available'], true),
      createdAt: AdminJson.dateTime(json['created_at']),
    );
  }
}

class AdminScheduleRow {
  const AdminScheduleRow({
    required this.id,
    required this.fieldId,
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
    required this.createdAt,
  });

  final String id;
  final String fieldId;
  final String date;
  final String openTime;
  final String closeTime;
  final bool isClosed;
  final DateTime? createdAt;

  factory AdminScheduleRow.fromJson(Map<String, dynamic> json) {
    return AdminScheduleRow(
      id: AdminJson.string(json['id']),
      fieldId: AdminJson.string(json['field_id']),
      date: AdminJson.string(json['date']),
      openTime: AdminJson.string(json['open_time']),
      closeTime: AdminJson.string(json['close_time']),
      isClosed: AdminJson.boolean(json['is_closed']),
      createdAt: AdminJson.dateTime(json['created_at']),
    );
  }
}

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.bookingId,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String customerName;
  final String bookingId;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: AdminJson.string(json['id']),
      userId: AdminJson.string(json['user_id']),
      customerName: AdminJson.string(json['customer_name']),
      bookingId: AdminJson.string(json['booking_id']),
      message: AdminJson.string(json['message']),
      type: AdminJson.string(json['type']),
      isRead: AdminJson.boolean(json['is_read']),
      createdAt: AdminJson.dateTime(json['created_at']),
    );
  }
}

class AdminAccountRow {
  const AdminAccountRow({
    required this.id,
    required this.firebaseUid,
    required this.username,
    required this.email,
    required this.role,
    required this.lastLoginAt,
    required this.createdAt,
  });

  final String id;
  final String firebaseUid;
  final String username;
  final String email;
  final String role;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  factory AdminAccountRow.fromJson(Map<String, dynamic> json) {
    return AdminAccountRow(
      id: AdminJson.string(json['id']),
      firebaseUid: AdminJson.string(json['firebase_uid']),
      username: AdminJson.string(json['username']),
      email: AdminJson.string(json['email']),
      role: AdminJson.string(json['role'], 'admin'),
      lastLoginAt: AdminJson.dateTime(json['last_login_at']),
      createdAt: AdminJson.dateTime(json['created_at']),
    );
  }
}

class DailyReport {
  const DailyReport({
    required this.date,
    required this.totalBookings,
    required this.totalRevenue,
    required this.paidBookings,
  });

  final String date;
  final int totalBookings;
  final int totalRevenue;
  final int paidBookings;

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: AdminJson.string(json['date']),
      totalBookings: AdminJson.integer(json['total_bookings']),
      totalRevenue: AdminJson.integer(json['total_revenue']),
      paidBookings: AdminJson.integer(json['paid_bookings']),
    );
  }
}

class RangeReport {
  const RangeReport({
    required this.periodStart,
    required this.periodEnd,
    required this.totalBookings,
    required this.pendingBookings,
    required this.paidBookings,
    required this.cancelledBookings,
    required this.completedBookings,
    required this.totalRevenue,
    required this.revenueChart,
  });

  final String periodStart;
  final String periodEnd;
  final int totalBookings;
  final int pendingBookings;
  final int paidBookings;
  final int cancelledBookings;
  final int completedBookings;
  final int totalRevenue;
  final List<RevenueChartPoint> revenueChart;

  factory RangeReport.fromJson(Map<String, dynamic> json) {
    return RangeReport(
      periodStart: AdminJson.string(json['period_start']),
      periodEnd: AdminJson.string(json['period_end']),
      totalBookings: AdminJson.integer(json['total_bookings']),
      pendingBookings: AdminJson.integer(json['pending_bookings']),
      paidBookings: AdminJson.integer(json['paid_bookings']),
      cancelledBookings: AdminJson.integer(json['cancelled_bookings']),
      completedBookings: AdminJson.integer(json['completed_bookings']),
      totalRevenue: AdminJson.integer(json['total_revenue']),
      revenueChart: (json['revenue_chart'] as List? ?? [])
          .map(
            (item) => RevenueChartPoint.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
