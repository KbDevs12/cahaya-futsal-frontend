class NotificationItem {
  const NotificationItem({
    required this.id,
    this.bookingId,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String? bookingId;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  bool get isPaymentConfirmed => type == 'payment_confirmed';
  bool get isPaymentRejected => type == 'payment_rejected';
  bool get isPaymentEvent => isPaymentConfirmed || isPaymentRejected;

  String get title => switch (type) {
        'payment_confirmed' => 'Pembayaran dikonfirmasi',
        'payment_rejected' => 'Pembayaran ditolak',
        _ => 'Notifikasi booking',
      };

  String get statusText => switch (type) {
        'payment_confirmed' => 'Paid',
        'payment_rejected' => 'Rejected',
        _ => type.replaceAll('_', ' '),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String?,
        message: json['message'] as String,
        type: json['type'] as String,
        isRead: json['is_read'] == true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
