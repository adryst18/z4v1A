import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// ============================================================
/// SERVICIO DE AUTENTICACIÓN BIOMÉTRICA
///
/// Usa la biometría nativa del dispositivo (Face ID en iOS,
/// reconocimiento facial o huella en Android) para autenticar
/// al usuario sin pedirle contraseña cada vez.
///
/// Ubicación sugerida: lib/services/biometric_service.dart
/// ============================================================
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Revisa si el dispositivo tiene soporte de biometría
  /// (hardware disponible Y el usuario ya configuró Face ID/huella
  /// en su teléfono).
  Future<bool> esDisponible() async {
    try {
      final soportado = await _auth.isDeviceSupported();
      final puedeChecar = await _auth.canCheckBiometrics;
      return soportado && puedeChecar;
    } catch (_) {
      return false;
    }
  }

  /// Lanza el diálogo nativo de Face ID / huella.
  /// Devuelve true si el usuario se autenticó correctamente.
  Future<BiometricResultado> autenticar() async {
    try {
      final exito = await _auth.authenticate(
        localizedReason: 'Confirma tu identidad para entrar a SABIA',
        options: const AuthenticationOptions(
          biometricOnly: true, // no cae a PIN/patrón del teléfono
          stickyAuth: true, // sigue el diálogo abierto si la app pasa a segundo plano
        ),
      );
      return exito ? BiometricResultado.exito : BiometricResultado.cancelado;
    } on Exception catch (e) {
      final mensaje = e.toString();
      if (mensaje.contains(auth_error.notAvailable)) {
        return BiometricResultado.noDisponible;
      }
      if (mensaje.contains(auth_error.notEnrolled)) {
        return BiometricResultado.noConfigurado;
      }
      if (mensaje.contains(auth_error.lockedOut) ||
          mensaje.contains(auth_error.permanentlyLockedOut)) {
        return BiometricResultado.bloqueado;
      }
      return BiometricResultado.error;
    }
  }
}

enum BiometricResultado {
  exito,
  cancelado,
  noDisponible,
  noConfigurado,
  bloqueado,
  error,
}