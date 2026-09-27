class ApiConfig {
  // ⚠️ CAMBIA ESTA URL SEGÚN TU ENTORNO:
  //
  // - Emulador Android:    http://10.0.2.2:8000/api
  // - Emulador iOS:        http://localhost:8000/api
  // - Dispositivo físico:  http://TU_IP_LOCAL:8000/api  (ej: 192.168.1.50)
  // - Flutter Web:         http://localhost:8000/api
  //
  static const String baseUrl = 'http://192.168.100.15:8000/api';

  // Endpoints
  static const String login  = '/Login';
  static const String logout = '/logout';
  static const String me     = '/me';
}