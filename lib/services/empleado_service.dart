import 'package:dio/dio.dart';
import '../models/role.dart';
import 'api_service.dart';

class EmpleadoService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> listar({
    int? id,
    int? roleId,
    String? roleName,
    String? name,
    String? username,
    String? phone,
    String? gender,
    bool? active,
    String? search,
  }) async
  {
    try {
      final queryParams = <String, dynamic>{};

      if (id != null)       queryParams['id']        = id;
      if (roleId != null)   queryParams['role_id']   = roleId;
      if (roleName != null) queryParams['role_name'] = roleName;
      if (name != null)     queryParams['name']      = name;
      if (username != null) queryParams['username']  = username;
      if (phone != null)    queryParams['phone']     = phone;
      if (gender != null)   queryParams['gender']    = gender;
      if (active != null)   queryParams['active']    = active ? 1 : 0;
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // 👇 GET con queryParameters
      final response = await _api.dio.get(
        '/empleados',
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar empleados');
      }

      return List<dynamic>.from(data['data'] ?? []);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Crea un empleado. Lanza excepción con el mensaje si falla.
  Future<void> crear({
    required int roleId,
    required String name,
    required String username,
    required String password,
    required String phone,
    required String gender,
    required bool active,
  }) async
  {
    try {
      final response = await _api.dio.post(
        '/empleados/create',
        data: {
          'role_id': roleId,
          'name': name,
          'username': username,
          'password': password,
          'phone': phone,
          'gender': gender,
          'active': active ? 1 : 0,
        },
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al crear empleado');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }

  /// Actualizar empleado. Password opcional (null = no cambiar).
  Future<void> actualizar({
    required int id,
    required int roleId,
    required String name,
    required String username,
    String? password,
    required String phone,
    required String gender,
    required bool active,
  }) async {
    try {
      final map = <String, dynamic>{
        'role_id': roleId.toString(),
        'name': name,
        'username': username,
        'phone': phone,
        'gender': gender,
        'active': active ? '1' : '0',
      };

      // 👇 Solo manda password si no es null ni vacío
      if (password != null && password.trim().isNotEmpty) {
        map['password'] = password;
      }

      final response = await _api.dio.post(
        '/empleados/$id',   // POST con _method=PUT
        data: FormData.fromMap({
          '_method': 'POST',
          ...map,
        }),
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al actualizar');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar';
      throw Exception(msg);
    }
  }

  /// Desactivar/activar empleado (toggle).
  Future<void> toggleActive(int id) async {
    try {
      final response = await _api.dio.patch('/empleados/$id/toggle');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al cambiar estado');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar';
      throw Exception(msg);
    }
  }

  /// Eliminar empleado.
  Future<void> eliminar(int id) async {
    try {
      final response = await _api.dio.delete('/empleados/$id');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al eliminar');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar';
      throw Exception(msg);
    }
  }

  Future<List<Role>> roles() async {
    try {
      final response = await _api.dio.post(
        '/Group-By-Campo',
        data: {'action': 'roles'},
      );

      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al consultar roles');
      }

      return (data['data'] as List)
          .map((e) => Role.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'No se pudo conectar al servidor';
      throw Exception(msg);
    }
  }
}