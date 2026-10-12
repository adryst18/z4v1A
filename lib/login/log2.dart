import 'package:flutter/material.dart';
import 'package:sabia/services/log_service.dart';
import 'package:sabia/services/auth_service.dart';
import 'package:sabia/services/biometric_service.dart';
import 'package:sabia/models/log_entry.dart';
import 'log4.dart';

class Log2 extends StatefulWidget {
  const Log2({super.key});

  @override
  State<Log2> createState() => _Log2State();
}

class _Log2State extends State<Log2> {
  final _usuarioController = TextEditingController();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  bool _quiereReconocimientoFacial = false;

  final LogService _logService = LogService();
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _logService.addLog(
      type: LogType.navegacion,
      message: 'Pantalla de registro cargada',
      details: {'pantalla': 'Log2'},
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
                    'Crear cuenta',
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
                    'Regístrate para comenzar tu aprendizaje',
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

                  // Campo Correo
                  _buildTextField(
                    label: 'Correo electrónico',
                    controller: _correoController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: 16),

                  // Campo Confirmar Contraseña
                  _buildTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirmPassController,
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPass = !_obscureConfirmPass;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Checkbox: activar reconocimiento facial ─────────
                  // Solo guarda la preferencia; la confirmación real con
                  // el sensor del dispositivo ocurre después de que el
                  // registro sea exitoso (ver _handleRegister).
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: CheckboxListTile(
                      value: _quiereReconocimientoFacial,
                      onChanged: (valor) {
                        setState(() {
                          _quiereReconocimientoFacial = valor ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF38b000),
                      checkColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Row(
                        children: [
                          const Icon(Icons.face_retouching_natural,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Usar reconocimiento facial para entrar más rápido',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                              'Registrarme',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de inicio de sesión
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        _logService.addLog(
                          type: LogType.navegacion,
                          message: 'Navegación a inicio de sesión desde registro',
                          details: {'origen': 'Log2'},
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Log4()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF38b000), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Al registrarte aceptas nuestros Términos y Condiciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
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

  Future<void> _handleRegister() async {
    if (_usuarioController.text.isEmpty) {
      _showError('Por favor ingresa un usuario');
      return;
    }

    if (_correoController.text.isEmpty || !_correoController.text.contains('@')) {
      _showError('Por favor ingresa un correo válido');
      return;
    }

    if (_passController.text.isEmpty) {
      _showError('Por favor ingresa una contraseña');
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    if (_passController.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Se registra de verdad contra la API (Node.js) que guarda en PostgreSQL
    final resultado = await _authService.register(
      usuario: _usuarioController.text.trim(),
      password: _passController.text,
      correo: _correoController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!resultado.success) {
      await _logService.addLog(
        type: LogType.error,
        message: 'Error al registrar usuario',
        details: {'usuario': _usuarioController.text, 'error': resultado.message},
      );
      if (mounted) _showError(resultado.message);
      return;
    }

    await _logService.addLog(
      type: LogType.register,
      message: 'Nuevo usuario registrado',
      details: {
        'id_usuario': resultado.idUsuario,
        'usuario': _usuarioController.text,
        'correo': _correoController.text,
      },
    );

    // Si el usuario marcó el checkbox, confirmamos con el sensor del
    // dispositivo (Face ID/huella) antes de activar el acceso rápido.
    // Esto asegura que su dispositivo realmente soporta biometría antes
    // de ofrecerle esa opción la próxima vez que abra la app.
    if (_quiereReconocimientoFacial && mounted) {
      final disponible = await _biometricService.esDisponible();
      if (disponible) {
        final resultadoBiometrico = await _biometricService.autenticar();
        if (resultadoBiometrico == BiometricResultado.exito) {
          await _authService.habilitarAccesoBiometrico();
          await _logService.addLog(
            type: LogType.navegacion,
            message: 'Reconocimiento facial activado durante el registro',
            details: {'usuario': _usuarioController.text},
          );
        } else if (mounted) {
          _showError('No se pudo activar el reconocimiento facial. Podrás activarlo después.');
        }
      } else if (mounted) {
        _showError('Tu dispositivo no tiene soporte biométrico disponible.');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Registro exitoso'),
          backgroundColor: Color(0xFF38b000),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Log4()),
      );
    }
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

  @override
  void dispose() {
    _usuarioController.dispose();
    _correoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}