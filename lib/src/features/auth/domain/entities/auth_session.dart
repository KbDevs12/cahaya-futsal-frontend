class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.inactivityLogoutDays,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final int inactivityLogoutDays;
  final String userId;
  final String email;
  final String name;
  final String role;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access_token'] as String,
        tokenType: (json['token_type'] ?? 'Bearer') as String,
        expiresIn: (json['expires_in'] ?? 0) as int,
        inactivityLogoutDays: (json['inactivity_logout_days'] ?? 7) as int,
        userId: json['user_id'] as String,
        email: json['email'] as String,
        name: (json['name'] ?? '') as String,
        role: (json['role'] ?? 'customer') as String,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'inactivity_logout_days': inactivityLogoutDays,
        'user_id': userId,
        'email': email,
        'name': name,
        'role': role,
      };
}
