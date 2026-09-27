import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  /// Intenta restaurar la sesión al abrir la app
  Future<bool> tryAutoLogin() async {
    print('🔵 [tryAutoLogin] INICIO');

    await _apiService.loadToken();
    print('🔵 [tryAutoLogin] token cargado: ${_apiService.token}');

    if (_apiService.token == null) {
      print('🔵 [tryAutoLogin] no hay token → Login');
      return false;
    }

    try {
      print('🔵 [tryAutoLogin] llamando a me()...');
      _user = await _authService.me();
      print('✅ [tryAutoLogin] me() OK → user: ${_user?.username}');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [tryAutoLogin] me() FALLÓ: $e');
      await _apiService.clearToken();
      return false;
    }
  }

  /// Login
  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        username: username,
        password: password,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}