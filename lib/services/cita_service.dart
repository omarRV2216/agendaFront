import 'package:dio/dio.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _api = ApiService();



  /// Listar citas con filtros.
  /// Todos los parámetros son opcionales.
  Future<List<dynamic>> listar({
    int? id,
    int? serviceId,
    int? employeeId,
    String? clientName,
    String? clientPhone,
    String? status,
    String? date,        // YYYY-MM-DD
    String? from,        // YYYY-MM-DD (inicio de rango)
    String? to,          // YYYY-MM-DD (fin de rango)
    String? search,
  }) async
  {
    try {
      final queryParams = <String, dynamic>{};

      if (id != null)          queryParams['id']          = id;
      if (serviceId != null)   queryParams['service_id']  = serviceId;
      if (employeeId != null)  queryParams['employee_id'] = employeeId;
      if (clientName != null)  queryParams['client_name'] = clientName;
      if (clientPhone != null) queryParams['client_phone']= clientPhone;
      if (status != null)      queryParams['status']      = status;
      if (date != null)        queryParams['date']        = date;
      if (from != null)        queryParams['from']        = from;
      if (to != null)          queryParams['to']          = to;
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // 👇 GET con queryParameters
      final response = await _api.dio.get(
        '/appointments',
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar citas');
      }

      return List<dynamic>.from(data['data'] ?? []);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Próximas citas (para dashboard).
  Future<List<dynamic>> proximas({
    int? employeeId,
    int? limit,
  }) async
  {
    try {
      final queryParams = <String, dynamic>{};

      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (limit != null)      queryParams['limit']       = limit;

      final response = await _api.dio.get(
        '/appointments/upcoming',
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar próximas citas');
      }

      return List<dynamic>.from(data['data'] ?? []);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Disponibilidad (slots libres) para un servicio + empleado + fecha.
  Future<Map<String, dynamic>> disponibilidad({
    required int serviceId,
    required int employeeId,
    required String date, // YYYY-MM-DD
  }) async
  {
    try {
      final response = await _api.dio.get(
        '/appointments/availability',
        queryParameters: {
          'service_id':  serviceId,
          'employee_id': employeeId,
          'date':        date,
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar disponibilidad');
      }

      return Map<String, dynamic>.from(data['data'] ?? {});
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Crear cita.
  /// Crear cita.
  Future<void> crear({
    required int serviceId,
    required int employeeId,
    required String clientName,
    String? clientPhone,
    String? clientEmail,
    required String appointmentDate, // YYYY-MM-DD
    required String startTime,       // HH:mm
    String? notes,
  }) async
  {
    try {
      final response = await _api.dio.post(
        '/appointments/create',
        data: {
          'service_id':       serviceId,
          'employee_id':      employeeId,
          'client_name':      clientName,
          'client_phone':     clientPhone,
          'client_email':     clientEmail,
          'appointment_date': appointmentDate,
          'start_time':       startTime,
          'notes':            notes,
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al crear cita');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Cambiar solo el estado de una cita.
  Future<void> cambiarEstado(int id, String status) async {
    try {
      final response = await _api.dio.patch(
        '/appointments/$id/status',
        data: {'status': status},
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al cambiar estado');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Eliminar cita.
  Future<void> eliminar(int id) async {
    try {
      final response = await _api.dio.delete('/appointments/$id');

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al eliminar cita');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Actualizar cita (reagendar).
  Future<void> actualizar({
    required int id,
    required int serviceId,
    required int employeeId,
    required String clientName,
    String? clientPhone,
    String? clientEmail,
    required String appointmentDate,
    required String startTime,
    String? notes,
    required String status,
  }) async {
    try {
      final response = await _api.dio.post(
        '/appointments/$id',
        data: {
          'service_id':       serviceId,
          'employee_id':      employeeId,
          'client_name':      clientName,
          'client_phone':     clientPhone,
          'client_email':     clientEmail,
          'appointment_date': appointmentDate,
          'start_time':       startTime,
          'notes':            notes,
          'status':           status,
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al actualizar cita');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

}