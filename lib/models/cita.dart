class Appointment {
  final int? id;
  final int serviceId;
  final int employeeId;
  final int? createdBy;

  // Datos del cliente
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;

  // Fechas y horas
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;

  // Snapshot del servicio
  final String serviceName;
  final double servicePrice;

  // Estado y notas
  final String status;
  final String? notes;
  final String? color;

  // Metadata
  final String? createdAt;
  final String? updatedAt;

  // Datos del JOIN
  final String? employeeName;
  final String? employeeUsername;
  final String? employeePhone;
  final String? servicePhoto;

  Appointment({
    this.id,
    required this.serviceId,
    required this.employeeId,
    this.createdBy,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.serviceName,
    required this.servicePrice,
    required this.status,
    this.notes,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.employeeName,
    this.employeeUsername,
    this.employeePhone,
    this.servicePhoto,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id:               json['id'] as int?,
    serviceId:        json['service_id'] as int,
    employeeId:       json['employee_id'] as int,
    createdBy:        json['created_by'] as int?,
    clientName:       json['client_name'] as String? ?? '',
    clientPhone:      json['client_phone'] as String?,
    clientEmail:      json['client_email'] as String?,
    appointmentDate:  json['appointment_date'] as String? ?? '',
    startTime:        json['start_time'] as String? ?? '',
    endTime:          json['end_time'] as String? ?? '',
    durationMinutes:  json['duration_minutes'] as int? ?? 0,
    serviceName:      json['service_name'] as String? ?? '',
    servicePrice:     double.tryParse(json['service_price']?.toString() ?? '0') ?? 0.0,
    status:           json['status'] as String? ?? 'pending',
    notes:            json['notes'] as String?,
    color:            json['color'] as String?,
    createdAt:        json['created_at'] as String?,
    updatedAt:        json['updated_at'] as String?,
    employeeName:     json['employee_name'] as String?,
    employeeUsername: json['employee_username'] as String?,
    employeePhone:    json['employee_phone'] as String?,
    servicePhoto:     json['service_photo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'service_id':       serviceId,
    'employee_id':      employeeId,
    'client_name':      clientName,
    'client_phone':     clientPhone,
    'client_email':     clientEmail,
    'appointment_date': appointmentDate,
    'start_time':       startTime,
    'status':           status,
    'notes':            notes,
  };

  DateTime? get fechaInicio => DateTime.tryParse(startTime);
  DateTime? get fechaFin    => DateTime.tryParse(endTime);

  bool get isActive =>
      !['cancelled', 'completed', 'no_show'].contains(status);

  // ⬇️ copyWith va AQUÍ, dentro de la clase, al mismo nivel que los demás métodos
  Appointment copyWith({
    int? id,
    int? serviceId,
    int? employeeId,
    int? createdBy,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? appointmentDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    String? serviceName,
    double? servicePrice,
    String? status,
    String? notes,
    String? color,
    String? createdAt,
    String? updatedAt,
    String? employeeName,
    String? employeeUsername,
    String? employeePhone,
    String? servicePhoto,
  }) {
    return Appointment(
      id:               id ?? this.id,
      serviceId:        serviceId ?? this.serviceId,
      employeeId:       employeeId ?? this.employeeId,
      createdBy:        createdBy ?? this.createdBy,
      clientName:       clientName ?? this.clientName,
      clientPhone:      clientPhone ?? this.clientPhone,
      clientEmail:      clientEmail ?? this.clientEmail,
      appointmentDate:  appointmentDate ?? this.appointmentDate,
      startTime:        startTime ?? this.startTime,
      endTime:          endTime ?? this.endTime,
      durationMinutes:  durationMinutes ?? this.durationMinutes,
      serviceName:      serviceName ?? this.serviceName,
      servicePrice:     servicePrice ?? this.servicePrice,
      status:           status ?? this.status,
      notes:            notes ?? this.notes,
      color:            color ?? this.color,
      createdAt:        createdAt ?? this.createdAt,
      updatedAt:        updatedAt ?? this.updatedAt,
      employeeName:     employeeName ?? this.employeeName,
      employeeUsername: employeeUsername ?? this.employeeUsername,
      employeePhone:    employeePhone ?? this.employeePhone,
      servicePhoto:     servicePhoto ?? this.servicePhoto,
    );
  }
}   // ← ÚNICA llave que cierra la clase, al final de todo