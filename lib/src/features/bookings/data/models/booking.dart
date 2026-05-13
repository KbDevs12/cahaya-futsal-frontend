class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHrs,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fieldId;
  final String date;
  final String startTime;
  final String endTime;
  final double durationHrs;
  final int totalPrice;
  final String status;
  final DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fieldId: json['field_id'] as String,
        date: json['date'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        durationHrs: (json['duration_hrs'] as num).toDouble(),
        totalPrice: (json['total_price'] as num).toInt(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class CreateBookingRequest {
  const CreateBookingRequest({
    required this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  final String fieldId;
  final String date;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toJson() => {
        'field_id': fieldId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      };
}
