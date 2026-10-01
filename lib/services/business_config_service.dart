import 'package:dio/dio.dart';

import '../models/business_hour.dart';
import '../models/business_closure.dart';
import 'api_service.dart';

class BusinessConfigService {
  final ApiService _api = ApiService();

  /// Devuelve la lista de horarios y cierres.
  Future<Map<String, dynamic>> obtenerConfig() async {
    try {
      final response = await _api.dio.get('/business-config');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar configuración');
      }

      return Map<String, dynamic>.from(data['data'] ?? {});
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Convierte la respuesta en listas tipadas.
  Future<({List<BusinessHour> hours, List<BusinessClosure> closures})> obtenerTipado() async {
    final raw = await obtenerConfig();

    final hours = (raw['hours'] as List? ?? [])
        .map((e) => BusinessHour.fromJson(e as Map<String, dynamic>))
        .toList();

    final closures = (raw['closures'] as List? ?? [])
        .map((e) => BusinessClosure.fromJson(e as Map<String, dynamic>))
        .toList();

    return (hours: hours, closures: closures);
  }

  /// Guarda los 7 días del horario semanal.
  Future<void> actualizarHorarios(List<BusinessHour> hours) async {
    try {
      final response = await _api.dio.post(
        '/business-config/hours',
        data: {
          'hours': hours.map((h) => {
            'day_of_week': h.dayOfWeek,
            'is_open':     h.isOpen,
            'open_time':   h.openTime,
            'close_time':  h.closeTime,
          }).toList(),
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al guardar horarios');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Agrega una excepción (día cerrado o con horario especial).
  Future<void> agregarCierre({
    required String date,       // YYYY-MM-DD
    required String type,       // 'closed' | 'custom'
    String? openTime,           // HH:MM:SS (solo si custom)
    String? closeTime,          // HH:MM:SS (solo si custom)
    String? reason,
  }) async {
    try {
      final response = await _api.dio.post(
        '/business-config/closures',
        data: {
          'date':       date,
          'type':       type,
          'open_time':  openTime,
          'close_time': closeTime,
          'reason':     reason,
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al agregar excepción');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Elimina una excepción por ID.
  Future<void> eliminarCierre(int id) async {
    try {
      final response = await _api.dio.delete('/business-config/closures/$id');

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al eliminar excepción');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }
}