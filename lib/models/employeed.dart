class Empleado {
  final int? id;
  final int roleId;
  final String name;
  final String username;
  final String password;
  final String phone;
  final String gender;
  final bool active;

  Empleado({
    this.id,
    required this.roleId,
    required this.name,
    required this.username,
    required this.password,
    required this.phone,
    required this.gender,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
    'role_id': roleId,
    'name': name,
    'username': username,
    'password': password,
    'phone': phone,
    'gender': gender,
    'active': active ? 1 : 0,
  };
}