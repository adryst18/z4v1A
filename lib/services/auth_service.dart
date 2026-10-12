import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Resultado de login/registro para usar en la UI.
class AuthResult {
  final bool success;
  final String message;
  final int? idUsuario;
  final String? nombre;
  final String? rol; // 'alumno' o 'tutor'

  AuthResult({required this.success, required this.message, this.idUsuario, this.nombre, this.rol});
}

/// Datos de la sesión guardada localmente (sin contraseña).
/// Se usa para el acceso rápido con reconocimiento facial: el Face ID
/// no vuelve a llamar al login, solo desbloquea esta sesión ya guardada.
class UsuarioSesion {
  final int idUsuario;
  final String nombre;
  final String rol;

  UsuarioSesion({required this.idUsuario, required this.nombre, required this.rol});
}

/// Habla con el backend (Node.js) que a su vez guarda todo en PostgreSQL.
class AuthService {
  static const _kIdUsuario = 'id_usuario';
  static const _kNombre = 'nombre_usuario_actual';
  static const _kRol = 'rol_usuario_actual';
  static const _kBiometriaHabilitada = 'biometria_habilitada';

  Future<AuthResult> register({
    required String usuario,
    required String password,
    String? correo,
  }) async {
    final data = await ApiService.register(usuario: usuario, password: password, correo: correo);
    if (data['success'] == true) {
      await _guardarSesion(data['id_usuario'], data['nombre'], data['rol']);
      return AuthResult(
        success: true,
        message: 'Registro exitoso',
        idUsuario: data['id_usuario'],
        nombre: data['nombre'],
        rol: data['rol'],
      );
    }
    return AuthResult(success: false, message: data['message'] ?? 'No se pudo registrar');
  }

  Future<AuthResult> login({
    required String usuario,
    required String password,
  }) async {
    final data = await ApiService.login(usuario: usuario, password: password);
    if (data['success'] == true) {
      await _guardarSesion(data['id_usuario'], data['nombre'], data['rol']);
      return AuthResult(
        success: true,
        message: 'Bienvenido',
        idUsuario: data['id_usuario'],
        nombre: data['nombre'],
        rol: data['rol'],
      );
    }
    return AuthResult(success: false, message: data['message'] ?? 'Usuario o contraseña incorrectos');
  }

  Future<void> _guardarSesion(int? idUsuario, String? nombre, String? rol) async {
    if (idUsuario == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kIdUsuario, idUsuario);
    await prefs.setString(_kNombre, nombre ?? '');
    await prefs.setString(_kRol, rol ?? '');
  }

  /// Devuelve el id del usuario que inició sesión, o null si no hay sesión guardada.
  Future<int?> obtenerIdUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kIdUsuario);
  }

  /// Devuelve la sesión guardada completa (id, nombre y rol), o null si
  /// no hay ninguna sesión guardada todavía (ej. primera vez que se usa
  /// la app, o después de cerrar sesión).
  ///
  /// Se usa para el acceso rápido con reconocimiento facial: en vez de
  /// volver a pedir usuario/contraseña, se usa esta sesión ya guardada
  /// para decidir a dónde navegar (HomeScreen o AdminPanelScreen).
  Future<UsuarioSesion?> obtenerSesionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_kIdUsuario);
    if (id == null) return null;

    final nombre = prefs.getString(_kNombre) ?? '';
    final rol = prefs.getString(_kRol) ?? '';
    return UsuarioSesion(idUsuario: id, nombre: nombre, rol: rol);
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIdUsuario);
    await prefs.remove(_kNombre);
    await prefs.remove(_kRol);
    // La preferencia de biometría NO se borra al cerrar sesión: es una
    // preferencia del dispositivo, no de la sesión activa. Si se quiere
    // desactivar del todo, usar deshabilitarAccesoBiometrico().
  }

  /// Marca que este usuario/dispositivo aceptó usar reconocimiento
  /// facial/huella para entrar más rápido (se activa normalmente desde
  /// la pantalla de registro o desde ajustes).
  Future<void> habilitarAccesoBiometrico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometriaHabilitada, true);
  }

  Future<void> deshabilitarAccesoBiometrico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometriaHabilitada, false);
  }

  /// True si el usuario activó el acceso rápido con reconocimiento
  /// facial/huella en este dispositivo.
  Future<bool> accesoBiometricoHabilitado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometriaHabilitada) ?? false;
  }
}