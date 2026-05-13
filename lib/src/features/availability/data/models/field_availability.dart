import 'time_slot.dart';

class FieldAvailability {
  const FieldAvailability({
    required this.fieldId,
    required this.fieldName,
    required this.fieldType,
    required this.pricePerHour,
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.isAvailable,
    required this.isClosed,
    required this.bookedSlots,
  });

  final String fieldId;
  final String fieldName;
  final String fieldType;
  final int pricePerHour;
  final String date;
  final String openTime;
  final String closeTime;
  final bool isAvailable;
  final bool isClosed;
  final List<TimeSlot> bookedSlots;

  factory FieldAvailability.fromJson(Map<String, dynamic> json) => FieldAvailability(
        fieldId: json['field_id'] as String,
        fieldName: json['field_name'] as String,
        fieldType: json['field_type'] as String,
        pricePerHour: (json['price_per_hour'] as num).toInt(),
        date: json['date'] as String,
        openTime: json['open_time'] as String,
        closeTime: json['close_time'] as String,
        isAvailable: json['is_available'] == true,
        isClosed: json['is_closed'] == true,
        bookedSlots: ((json['booked_slots'] ?? []) as List)
            .map((item) => TimeSlot.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
