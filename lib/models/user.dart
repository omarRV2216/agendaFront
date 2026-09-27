class User {
  final int id;
  final String name;
  final String username;
  final String role;
  final String roleDisplay;
  final String? phone;
  final String? gender;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.roleDisplay,
    this.phone,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      roleDisplay: json['role_display'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      'role_display': roleDisplay,
      'phone': phone,
      'gender': gender,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'empleado';
}