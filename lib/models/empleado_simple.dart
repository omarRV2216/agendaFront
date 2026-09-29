class EmpleadoSimple {
  final int id;
  final String name;

  EmpleadoSimple({
    required this.id,
    required this.name,
  });

  factory EmpleadoSimple.fromJson(Map<String, dynamic> json) => EmpleadoSimple(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );

  /// Iniciales para el avatar (ej: "Ana Pérez" → "AP")
  String get initials {
    final partes = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}