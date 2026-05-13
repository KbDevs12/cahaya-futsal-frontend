class UserProfile {
  const UserProfile({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.createdAt,
  });

  final String id;
  final String firebaseUid;
  final String name;
  final String email;
  final String phone;
  final bool emailVerified;
  final DateTime createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        firebaseUid: json['firebase_uid'] as String,
        name: (json['name'] ?? '') as String,
        email: json['email'] as String,
        phone: (json['phone'] ?? '') as String,
        emailVerified: json['email_verified'] == true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
