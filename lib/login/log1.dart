import 'package:flutter/material.dart';
import 'log2.dart'; // Registro
import 'log4.dart'; // Inicia sesión normal
import 'package:sabia/services/log_service.dart';
import 'package:sabia/models/log_entry.dart';
import 'package:sabia/services/biometric_service.dart';
import 'package:sabia/services/auth_service.dart';
import 'package:sabia/pantallas/home_screen.dart';
import 'package:sabia/pantallas/admin/ad1.dart';
/*CAMBIO DE PRUEBAAAAA PARA COMMIT 1*/
class Log1 extends StatefulWidget {
  const Log1({super.key});

  @override
  State<Log1> createState() => _Log1State();
}

class _Log1State extends State<Log1> {
  final BiometricService _biometricService = BiometricService();
  final AuthService _authService = AuthService();
  bool _autenticando = false;
  bool _mostrarBotonBiometrico = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferenciaBiometrica();
  }

  Future<void> _cargarPreferenciaBiometrica() async {
    final habilitado = await _authService.accesoBiometricoHabilitado();
    if (mounted) {
      setState(() => _mostrarBotonBiometrico = habilitado);
    }
  }

  Future<void> _entrarConReconocimientoFacial() async {
    setState(() => _autenticando = true);

    final resultado = await _biometricService.autenticar();

    if (!mounted) return;
    setState(() => _autenticando = false);

    switch (resultado) {
      case BiometricResultado.exito:
        await _continuarConSesionGuardada();
        break;
      case BiometricResultado.cancelado:
        // El usuario cerró el diálogo, no hacemos nada más.
        break;
      case BiometricResultado.noDisponible:
        _mostrarMensaje('Este dispositivo no tiene soporte biométrico.');
        break;
      case BiometricResultado.noConfigurado:
        _mostrarMensaje(
          'Configura Face ID o tu huella en los ajustes de tu teléfono para usar esta opción.',
        );
        break;
      case BiometricResultado.bloqueado:
        _mostrarMensaje('Biometría bloqueada temporalmente. Intenta más tarde.');
        break;
      case BiometricResultado.error:
        _mostrarMensaje('No se pudo completar la autenticación. Intenta de nuevo.');
        break;
    }
  }

  /// Después de un Face ID exitoso, revisa si hay una sesión guardada
  /// (de un login normal anterior) y navega directo según el rol.
  /// Si no hay sesión guardada, pide iniciar sesión normal una vez.
  Future<void> _continuarConSesionGuardada() async {
    final sesion = await _authService.obtenerSesionGuardada();
    final logService = LogService();

    if (sesion == null) {
      await logService.addLog(
        type: LogType.navegacion,
        message: 'Face ID exitoso pero sin sesión guardada',
        details: {'origen': 'Log1'},
      );
      if (!mounted) return;
      _mostrarMensaje('Primero inicia sesión con tu usuario y contraseña.');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Log4()),
      );
      return;
    }

    await logService.addLog(
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

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: const Color(0xFF134074)),
    );
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
              Color(0xFF134074), // Azul principal
              Color(0xFF1A4D7A),
              Color(0xFF2A5F8E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circular con borde
                Container(
                  height: 120,
                  width: 120,
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
                      color: const Color(0xFF38b000), // Verde
                      width: 3,
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
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SABIA',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistema de Alfabetización\nBasado en Inteligencia Artificial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9252e3).withOpacity(0.2), // Morado
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '¡Aprende a leer y escribir con apoyo inteligente!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final logService = LogService();
                      await logService.addLog(
                        type: LogType.navegacion,
                        message: 'Navegación a pantalla de inicio de sesión',
                        details: {'origen': 'Log1'},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Log4()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38b000), // Verde
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () async {
                      final logService = LogService();
                      await logService.addLog(
                        type: LogType.navegacion,
                        message: 'Navegación a pantalla de registro',
                        details: {'origen': 'Log1'},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Log2()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF38b000), width: 2), // Verde
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Registrarme ahora',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ── ¿Olvidaste tu contraseña? ──────────────────────────
                // Solo diseño por ahora: TODO conectar a la pantalla de
                // recuperación de contraseña cuando esté lista.
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: Navigator.push a la pantalla de recuperar contraseña.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recuperar contraseña: próximamente'),
                        backgroundColor: Color(0xFF134074),
                      ),
                    );
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),

                // ── Separador "o" + Reconocimiento facial ──────────────
                // Solo se muestran si el usuario activó esta opción
                // durante el registro (ver log2.dart).
                if (_mostrarBotonBiometrico) ...[
                  const SizedBox(height: 8),
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
                      onPressed: _autenticando ? null : _entrarConReconocimientoFacial,
                      icon: _autenticando
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
                        _autenticando ? 'Verificando...' : 'Entrar con reconocimiento facial',
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
    );
  }
}
