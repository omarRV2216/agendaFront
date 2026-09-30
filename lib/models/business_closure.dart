class BusinessClosure {
  final int id;
  final String date;       // "2026-12-25"
  final String type;       // 'closed' | 'custom'
  final String? openTime;  // solo si type=custom
  final String? closeTime; // solo si type=custom
  final String? reason;

  BusinessClosure({
    required this.id,
    required this.date,
    required this.type,
    this.openTime,
    this.closeTime,
    this.reason,
  });

  factory BusinessClosure.fromJson(Map<String, dynamic> json) => BusinessClosure(
    id:         json['id'] as int,
    date:       json['date'] as String,
    type:       json['type'] as String,
    openTime:   json['open_time'] as String?,
    closeTime:  json['close_time'] as String?,
    reason:     json['reason'] as String?,
  );

  bool get esCerrado => type == 'closed';
  bool get esHorarioEspecial => type == 'custom';

  String get openTimeShort  => (openTime ?? '').length >= 5 ? openTime!.substring(0, 5) : '';
  String get closeTimeShort => (closeTime ?? '').length >= 5 ? closeTime!.substring(0, 5) : '';
}