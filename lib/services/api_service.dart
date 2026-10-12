import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cliente HTTP centralizado para hablar con el backend de SABIA (Node.js + PostgreSQL).
///
/// El backend ya está desplegado en la nube (Render), así que esta misma URL
/// funciona sin importar dónde corras la app: emulador, Chrome, Windows, o tu
/// celular físico por su propia conexión a internet (no necesita estar en la
/// misma red WiFi que tu PC).
///
/// NOTA: el timeout se dejó en 30s (antes 10s) porque el plan gratuito de
/// Render "duerme" el servidor tras un rato sin tráfico, y la primera
/// petición que lo despierta puede tardar más de 10s en responder.
class ApiService {
  static const String _baseUrl = 'https://sabia-backend-rfjb.onrender.com';

  static Uri _u(String path) => Uri.parse('$_baseUrl$path');

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final resp = await http
          .post(_u(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final resp = await http.get(_u(path)).timeout(const Duration(seconds: 30));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor: $e'};
    }
  }

  static Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    try {
      final resp = await http
          .put(_u(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor: $e'};
    }
  }

  // -------- Auth --------

  static Future<Map<String, dynamic>> register({
    required String usuario,
    required String password,
    String? correo,
    String rol = 'alumno',
  }) {
    return _post('/api/auth/register', {
      'usuario': usuario,
      'password': password,
      'correo': correo,
      'rol': rol,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String usuario,
    required String password,
  }) {
    return _post('/api/auth/login', {
      'usuario': usuario,
      'password': password,
    });
  }

  // -------- Progreso --------

  static Future<Map<String, dynamic>> obtenerProgreso(int idUsuario) {
    return _get('/api/progreso/$idUsuario');
  }

  static Future<Map<String, dynamic>> guardarProgreso({
    required int idUsuario,
    required int idLeccion,
    int? idActividad,
    int parteActual = 1,
    double porcentajeCompletado = 0,
    int estrellasObtenidas = 0,
    int intentosTotales = 0,
    int aciertos = 0,
    int fallos = 0,
    bool completado = false,
    int tiempoInvertido = 0,
  }) {
    return _post('/api/progreso', {
      'id_usuario': idUsuario,
      'id_leccion': idLeccion,
      'id_actividad': idActividad,
      'parte_actual': parteActual,
      'porcentaje_completado': porcentajeCompletado,
      'estrellas_obtenidas': estrellasObtenidas,
      'intentos_totales': intentosTotales,
      'aciertos': aciertos,
      'fallos': fallos,
      'completado': completado,
      'tiempo_invertido': tiempoInvertido,
    });
  }

  // -------- Estadísticas --------

  static Future<Map<String, dynamic>> obtenerEstadisticas(int idUsuario) {
    return _get('/api/estadisticas/$idUsuario');
  }

  /// Suma incrementos a las estadísticas del usuario (no reemplaza, suma).
  static Future<Map<String, dynamic>> sumarEstadisticas({
    required int idUsuario,
    int leccionesCompletadas = 0,
    int puntosTotales = 0,
    int minutosTotales = 0,
    int juegosCompletos = 0,
    int letrasAprendidas = 0,
  }) {
    return _put('/api/estadisticas/$idUsuario', {
      'lecciones_completadas': leccionesCompletadas,
      'puntos_totales': puntosTotales,
      'minutos_totales': minutosTotales,
      'juegos_completos': juegosCompletos,
      'letras_aprendidas': letrasAprendidas,
    });
  }
}