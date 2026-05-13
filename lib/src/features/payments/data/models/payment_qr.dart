class PaymentQr {
  const PaymentQr({
    required this.paymentId,
    required this.bookingId,
    required this.amount,
    required this.qrCode,
    required this.qrType,
    required this.status,
    required this.expiredAt,
  });

  final String paymentId;
  final String bookingId;
  final int amount;
  final String qrCode;
  final String qrType;
  final String status;
  final DateTime expiredAt;

  factory PaymentQr.fromJson(Map<String, dynamic> json) => PaymentQr(
        paymentId: json['payment_id'] as String,
        bookingId: json['booking_id'] as String,
        amount: (json['amount'] as num).toInt(),
        qrCode: json['qr_code'] as String,
        qrType: json['qr_type'] as String,
        status: json['status'] as String,
        expiredAt: DateTime.parse(json['expired_at'] as String),
      );
}
