class UserModel {
  final String session;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String? zoneId;
  final String? hospitalId;

  UserModel({
    required this.session,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.zoneId,
    this.hospitalId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      session: json['session'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      zoneId: json['zoneId'] as String?,
      hospitalId: json['hospitalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'zoneId': zoneId,
      'hospitalId': hospitalId,
    };
  }
}
