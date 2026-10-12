import 'package:flutter/material.dart';
import 'package:sabia/pantallas/home_screen.dart';
import 'log2.dart';
import 'package:sabia/services/log_service.dart';
import 'package:sabia/services/auth_service.dart';
import 'package:sabia/services/biometric_service.dart';
import 'package:sabia/models/log_entry.dart';
import 'package:sabia/pantallas/privado.dart';
import 'package:sabia/pantallas/admin/ad1.dart';

class Log4 extends StatefulWidget {
  const Log4({super.key});

  @override
  State<Log4> createState() => _Log4State();
}

class _Log4State extends State<Log4> {
  final _usuarioController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  final LogService _logService = LogService();
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  bool _autenticandoBiometria = false;
  bool _mostrarBotonBiometrico = false;

  @override
  void initState() {
    super.initState();
    _logService.addLog(
      type: LogType.navegacion,
      message: 'Pantalla de inicio de sesión cargada',
      details: {'pantalla': 'Log4'},
    );
    _cargarPreferenciaBiometrica();
  }

  Future<void> _cargarPreferenciaBiometrica() async {
    final habilitado = await _authService.accesoBiometricoHabilitado();
    if (mounted) {
      setState(() => _mostrarBotonBiometrico = habilitado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF134074),
              Color(0xFF1A4D7A),
              Color(0xFF2A5F8E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF38b000),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/imagenes/logo.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF134074),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar aprendiendo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo Usuario
                  _buildTextField(
                    label: 'Usuario',
                    controller: _usuarioController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña
                  _buildTextField(
                    label: 'Contraseña',
                    controller: _passController,
                    icon: Icons.lock_outline,
                    obscureText: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePass = !_obscurePass;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón de inicio de sesión
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38b000), // Verde
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        _logService.addLog(
                          type: LogType.navegacion,
                          message: 'Navegación a registro desde inicio de sesión',
                          details: {'origen': 'Log4'},
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Log2()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF38b000), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '¿No tienes cuenta? Regístrate',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // ── Separador "o" + Reconocimiento facial ──────────────
                  // Solo se muestran si el usuario activó esta opción
                  // durante el registro (ver log2.dart).
                  if (_mostrarBotonBiometrico) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o',
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _autenticandoBiometria
                            ? null
                            : _entrarConReconocimientoFacial,
                        icon: _autenticandoBiometria
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.face_retouching_natural, color: Colors.white),
                        label: Text(
                          _autenticandoBiometria
                              ? 'Verificando...'
                              : 'Entrar con reconocimiento facial',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.6), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.white, size: 22),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF38b000), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9b9b9b),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passController.text.trim();

    if (usuario.isEmpty) {
      _showError('Por favor ingresa tu usuario');
      return;
    }

    if (password.isEmpty) {
      _showError('Por favor ingresa tu contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Login real contra la API (Node.js), que valida contra PostgreSQL
    final resultado = await _authService.login(usuario: usuario, password: password);

    setState(() {
      _isLoading = false;
    });

    if (!resultado.success) {
      await _logService.addLog(
        type: LogType.error,
        message: 'Intento de inicio de sesión fallido',
        details: {'usuario': usuario, 'error': resultado.message},
      );
      if (mounted) _showError(resultado.message);
      return;
    }

    await _logService.addLog(
      type: LogType.login,
      message: 'Inicio de sesión exitoso',
      details: {
        'id_usuario': resultado.idUsuario,
        'usuario': usuario,
        'nombre': resultado.nombre,
        'rol': resultado.rol,
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ¡Bienvenido ${resultado.nombre}!'),
          backgroundColor: const Color(0xFF38b000),
          duration: const Duration(seconds: 2),
        ),
      );

      // El rol viene de la base de datos (tabla Usuario: 'tutor' o 'alumno')
      if (resultado.rol == 'tutor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  // ── Reconocimiento facial ────────────────────────────────────────────
  // Mismo patrón que en log1.dart: el Face ID/huella no vuelve a llamar
  // al login (no hay contraseña guardada), solo desbloquea la sesión que
  // ya se guardó la última vez que el usuario inició sesión normal.

  Future<void> _entrarConReconocimientoFacial() async {
    setState(() => _autenticandoBiometria = true);

    final resultado = await _biometricService.autenticar();

    if (!mounted) return;
    setState(() => _autenticandoBiometria = false);

    switch (resultado) {
      case BiometricResultado.exito:
        await _continuarConSesionGuardada();
        break;
      case BiometricResultado.cancelado:
        // El usuario cerró el diálogo, no hacemos nada más.
        break;
      case BiometricResultado.noDisponible:
        _showError('Este dispositivo no tiene soporte biométrico.');
        break;
      case BiometricResultado.noConfigurado:
        _showError(
          'Configura Face ID o tu huella en los ajustes de tu teléfono para usar esta opción.',
        );
        break;
      case BiometricResultado.bloqueado:
        _showError('Biometría bloqueada temporalmente. Intenta más tarde.');
        break;
      case BiometricResultado.error:
        _showError('No se pudo completar la autenticación. Intenta de nuevo.');
        break;
    }
  }

  Future<void> _continuarConSesionGuardada() async {
    final sesion = await _authService.obtenerSesionGuardada();

    if (sesion == null) {
      await _logService.addLog(
        type: LogType.navegacion,
        message: 'Face ID exitoso pero sin sesión guardada',
        details: {'origen': 'Log4'},
      );
      if (!mounted) return;
      _showError('Primero inicia sesión con tu usuario y contraseña.');
      return;
    }

    await _logService.addLog(
      type: LogType.login,
      message: 'Acceso con reconocimiento facial exitoso',
      details: {
        'id_usuario': sesion.idUsuario,
        'nombre': sesion.nombre,
        'rol': sesion.rol,
      },
    );

    if (!mounted) return;

    if (sesion.rol == 'tutor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passController.dispose();
    super.dispose();
  }
}