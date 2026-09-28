import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/service.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService _api = ApiService();

  /// Listar servicios con filtros opcionales.
  Future<List<Service>> listar({
    int? id,
    String? name,
    bool? active,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (id != null)     queryParams['id']     = id;
      if (name != null)   queryParams['name']   = name;
      if (active != null) queryParams['active'] = active ? 1 : 0;
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _api.dio.get(
        '/servicios',
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar servicios');
      }

      return (data['data'] as List)
          .map((e) => Service.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Crear servicio con imagen (opcional). Recibe bytes en vez de ruta.
  Future<int> crear({
    required String name,
    String? description,
    required double price,
    required int durationMinutes,
    bool active = true,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    try {
      final map = <String, dynamic>{
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'price': price.toString(),
        'duration_minutes': durationMinutes.toString(),
        'active': active ? '1' : '0',
      };

      // 👇 MultipartFile desde bytes (funciona en Web y móvil)
      if (photoBytes != null && photoFileName != null) {
        map['photo'] = MultipartFile.fromBytes(
          photoBytes,
          filename: photoFileName,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _api.dio.post(
        '/servicios/create',   // ⚠️ ajusta según tu ruta
        data: formData,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al crear servicio');
      }

      final id = data['data']['id'];
      return id is int ? id : int.tryParse(id.toString()) ?? 0;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Actualizar servicio.
  Future<void> actualizar({
    required int id,
    required String name,
    String? description,
    required double price,
    required int durationMinutes,
    bool active = true,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    try {
      final map = <String, dynamic>{
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'price': price.toString(),
        'duration_minutes': durationMinutes.toString(),
        'active': active ? '1' : '0',
      };

      if (photoBytes != null && photoFileName != null) {
        map['photo'] = MultipartFile.fromBytes(
          photoBytes,
          filename: photoFileName,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _api.dio.post(
        '/servicios/$id',
        data: formData,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al actualizar servicio');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Desactivar servicio.
  Future<void> desactivar(int id) async {
    try {
      final response = await _api.dio.patch('/servicios/$id/desactivar');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al desactivar');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar';
      throw Exception(msg);
    }
  }

  /// Eliminar servicio.
  Future<void> eliminar(int id) async {
    try {
      final response = await _api.dio.delete('/servicios/$id');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al eliminar');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar';
      throw Exception(msg);
    }
  }
}