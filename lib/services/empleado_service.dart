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