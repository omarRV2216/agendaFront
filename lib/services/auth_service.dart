import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  /// Hace login y devuelve el User si es exitoso.
  /// Lanza excepción con el mensaje de error si falla.
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data;

      // Tu backend responde:
      // { "success": true, "message": "...", "data": { "token": "...", "user": {...} } }
      if (data['success'] == true && data['data'] != null) {
        final token = data['data']['token'];
        final userJson = data['data']['user'];

        print('=== TOKEN RECIBIDO: $token ===');   // 👈 agrega esto

        await _api.setToken(token);

        final prefs = await SharedPreferences.getInstance();
        print('=== TOKEN EN PREFS: ${prefs.getString('token')} ===');   // 👈 y esto

        return User.fromJson(userJson);
      } else {
        throw Exception(data['message'] ?? 'Error desconocido');
      }
    } on DioException catch (e) {
      // Manejar errores del backend
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Error del servidor';
        throw Exception(message);
      } else {
        throw Exception('No se pudo conectar al servidor');
      }
    }
  }

  /// Cierra la sesión
  Future<void> logout() async {
    try {
      await _api.dio.post(ApiConfig.logout);
    } catch (_) {
      // Ignorar errores al cerrar sesión
    } finally {
      await _api.clearToken();
    }
  }

  /// Obtiene el usuario actual (útil para verificar si el token sigue válido)
  Future<User> me() async {
    try {
      final response = await _api.dio.post(ApiConfig.me);
      final data = response.data;

      // Ajusta según tu respuesta real
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      throw Exception('Error al obtener usuario');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de conexión');
    }
  }
}