class BusinessHour {
  final int id;
  final int dayOfWeek;   // 1=Lunes ... 7=Domingo
  final bool isOpen;
  final String openTime;   // "09:00:00"
  final String closeTime;  // "20:00:00"

  BusinessHour({
    required this.id,
    required this.dayOfWeek,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  factory BusinessHour.fromJson(Map<String, dynamic> json) => BusinessHour(
    id:         json['id'] as int,
    dayOfWeek:  json['day_of_week'] as int,
    isOpen:     json['is_open'] == 1 || json['is_open'] == true,
    openTime:   json['open_time'] as String? ?? '09:00:00',
    closeTime:  json['close_time'] as String? ?? '20:00:00',
  );

  BusinessHour copyWith({
    int? id,
    int? dayOfWeek,
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return BusinessHour(
      id:        id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isOpen:    isOpen ?? this.isOpen,
      openTime:  openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  /// "Lunes", "Martes"...
  String get nombreDia => switch (dayOfWeek) {
    1 => 'Lunes',
    2 => 'Martes',
    3 => 'Miércoles',
    4 => 'Jueves',
    5 => 'Viernes',
    6 => 'Sábado',
    7 => 'Domingo',
    _ => 'Desconocido',
  };

  /// "09:00" (sin segundos)
  String get openTimeShort => openTime.substring(0, 5);
  String get closeTimeShort => closeTime.substring(0, 5);
}