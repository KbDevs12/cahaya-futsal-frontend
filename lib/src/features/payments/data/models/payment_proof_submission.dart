class PaymentProofSubmission {
  const PaymentProofSubmission({
    required this.bookingId,
    required this.paymentId,
    required this.paymentStatus,
    required this.proofImageUrl,
    this.proofObjectKey,
    this.proofNote,
  });

  final String bookingId;
  final String paymentId;
  final String paymentStatus;
  final String proofImageUrl;
  final String? proofObjectKey;
  final String? proofNote;

  factory PaymentProofSubmission.fromJson(Map<String, dynamic> json) {
    return PaymentProofSubmission(
      bookingId: json['booking_id'] as String,
      paymentId: json['payment_id'] as String,
      paymentStatus: json['payment_status'] as String,
      proofImageUrl: json['proof_image_url'] as String,
      proofObjectKey: json['proof_object_key'] as String?,
      proofNote: json['proof_note'] as String?,
    );
  }
}
