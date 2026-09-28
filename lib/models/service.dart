import '../config/api_config.dart';

class Service {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? photoPath;
  final bool active;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.photoPath,
    required this.active,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 60,
      photoPath: json['photo_path'],
      active: json['active'] == 1 || json['active'] == true,
    );
  }

  /// URL completa de la foto (para mostrar en Image.network)
  String? get photoUrl {
    if (photoPath == null || photoPath!.isEmpty) return null;
    return '${ApiConfig.imageUrl}/$photoPath';
  }

  /// Duración en formato "1h 30min"
  String get durationFormatted {
    if (durationMinutes < 60) return '${durationMinutes}min';
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}min';
  }

  /// Precio formateado "$250.00"
  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
}