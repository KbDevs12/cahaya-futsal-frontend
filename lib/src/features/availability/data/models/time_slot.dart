class TimeSlot {
  const TimeSlot({required this.startTime, required this.endTime});

  final String startTime;
  final String endTime;

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        startTime: (json['start_time'] ?? '') as String,
        endTime: (json['end_time'] ?? '') as String,
      );
}
