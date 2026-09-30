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
}