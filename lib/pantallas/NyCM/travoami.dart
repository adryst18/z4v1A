import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:sabia/services/voice_service.dart';
import 'package:sabia/services/log_service.dart';
import 'package:sabia/models/log_entry.dart';
import 'package:sabia/pantallas/NyCM/hlilbro1.dart'; 
import 'travoami.dart';
import 'travoe.dart';

/// Clase que representa una abeja animada que aparece cuando el usuario traza
class AbejaAnimada {
  final Offset posicion;
  final double rotacion;
  final double escalaObjetivo;
  double escalaActual = 0.0;

  AbejaAnimada({
    required this.posicion,
    required this.rotacion,
    required this.escalaObjetivo,
  });
}

/// Pantalla principal para trazar la letra a minúscula
class TrazoAMinusculaScreen extends StatefulWidget {
  const TrazoAMinusculaScreen({super.key});

  @override
  State<TrazoAMinusculaScreen> createState() => _TrazoAMinusculaScreenState();
}

class _TrazoAMinusculaScreenState extends State<TrazoAMinusculaScreen> with TickerProviderStateMixin {
  // ========================================
  // SERVICIOS Y REPRODUCTORES DE AUDIO
  // ========================================
  final VoiceService _voiceService = VoiceService();
  final LogService _logService = LogService();
  final AudioPlayer _audioPlayerAbejas = AudioPlayer();
  final AudioPlayer _audioPlayerLapiz = AudioPlayer();
  
  // ========================================
  // ESTADO DEL TRAZO
  // ========================================
  List<List<Offset>> _trazos = [];           // Lista de todos los trazos completados
  List<Offset> _trazoActual = [];            // Trazo que se está dibujando actualmente
  List<AbejaAnimada> _abejasHuerto = [];     // Abejas que aparecen al trazar
  
  Offset? _posicionPanal;                    // Posición actual del cursor (panal)
  double _anguloPanal = 0.0;                 // Ángulo de rotación del panal
  bool _estaTocando = false;                 // Si el usuario está tocando la pantalla

  // ========================================
  // MÉTRICAS Y ESTADÍSTICAS
  // ========================================
  final Stopwatch _cronometro = Stopwatch();
  int _intentosFallidos = 0;
  bool _completadoExitosamente = false;
  
  double _porcentajePrecision = 0.0;
  double _sumaPrecisionMuestras = 0.0;
  int _totalMuestrasTomadas = 0;

  // ========================================
  // CONTROLADORES DE ANIMACIÓN
  // ========================================
  late AnimationController _semillasBlinkController;    // Parpadeo de semillas
  late AnimationController _loopAbejasController;       // Animación de abejas
  late AnimationController _confetiController;          // Confeti al ganar
  late AnimationController _demostracionController;     // Animación de demostración
  
  // ========================================
  // FASES DEL TRAZO (2 fases para 'a': Círculo y Tallo)
  // ========================================
  int _faseTrazoActual = 0;                            // 0=Círculo, 1=Tallo
  List<Offset> _puntosReferenciaCirculo = [];
  List<Offset> _puntosReferenciaTallo = [];
  
  List<bool> _cubiertosCirculo = [];                 
  List<bool> _cubiertosTallo = [];
  
  // ========================================
  // ESTADO DE DEMOSTRACIÓN
  // ========================================
  bool _mostrandoDemostracion = false;
  List<Offset> _trazoDemostracion = [];

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _generarPuntosReferenciaPorPartes();
    
    // Controlador para parpadeo de semillas (700ms, reversa)
    _semillasBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    // Controlador para animación fluida de abejas (16fps)
    _loopAbejasController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          for (var abeja in _abejasHuerto) {
            if (abeja.escalaActual < abeja.escalaObjetivo) {
              abeja.escalaActual += 0.08;
              if (abeja.escalaActual > abeja.escalaObjetivo) {
                abeja.escalaActual = abeja.escalaObjetivo;
              }
            }
          }
        });
      });
    _loopAbejasController.repeat();

    // Controlador para confeti (2 segundos)
    _confetiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Controlador para demostración (2 segundos por trazo)
    _demostracionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _voiceService.hablar('Toca la letra a y luego sigue el camino de miel');
  }

  @override
  void dispose() {
    _semillasBlinkController.dispose();
    _loopAbejasController.dispose();
    _confetiController.dispose();
    _demostracionController.dispose();
    _audioPlayerAbejas.dispose();
    _audioPlayerLapiz.dispose();
    _cronometro.stop();
    super.dispose();
  }

  /// Genera los puntos de referencia para la letra a minúscula
  void _generarPuntosReferenciaPorPartes() {
    _puntosReferenciaCirculo.clear();
    _puntosReferenciaTallo.clear();

    // 1. Círculo de la 'a' (empieza arriba, va a la izquierda, abajo, derecha, arriba)
    // Esto asegura que no se parezca a una 'q'
    for (double t = 0; t <= 1; t += 0.02) {
      double angle = -math.pi / 2 - (t * 2 * math.pi);
      double x = 165.0 + 80.0 * math.cos(angle);
      double y = 240.0 + 80.0 * math.sin(angle);
      _puntosReferenciaCirculo.add(Offset(x, y));
    }
    
    // 2. Tallo de la 'a' (baja por el lado derecho) - MÁS CORTO
    for (double t = 0; t <= 1; t += 0.05) {
      _puntosReferenciaTallo.add(Offset(245.0, 180.0 + (t * 140.0)));
    }

    _cubiertosCirculo = List.filled(_puntosReferenciaCirculo.length, false);
    _cubiertosTallo = List.filled(_puntosReferenciaTallo.length, false);
    
    _faseTrazoActual = 0; 
    _posicionPanal = const Offset(165.0, 160.0); // Inicia en la parte superior del círculo
    
    _porcentajePrecision = 0.0;
    _sumaPrecisionMuestras = 0.0;
    _totalMuestrasTomadas = 0;
  }

  /// Reproduce sonido de abejas en loop
  Future<void> _reproducirSonidoAbejas() async {
    try {
      await _audioPlayerAbejas.setReleaseMode(ReleaseMode.loop);
      await _audioPlayerAbejas.play(AssetSource('sounds/abeja.mp3'));
    } catch (e) {
      debugPrint('Error cargando audio de abejas: $e');
    }
  }

  Future<void> _detenerSonidoAbejas() async {
    await _audioPlayerAbejas.stop();
  }

  /// Reproduce sonido de lápiz en loop (para demostración)
  Future<void> _reproducirSonidoLapiz() async {
    try {
      await _audioPlayerLapiz.setReleaseMode(ReleaseMode.loop);
      await _audioPlayerLapiz.play(AssetSource('sounds/lapiz.mp3'));
    } catch (e) {
      debugPrint('Error cargando audio de lápiz: $e');
    }
  }

  Future<void> _detenerSonidoLapiz() async {
    await _audioPlayerLapiz.stop();
  }

  /// Pronuncia la letra a
  void _pronunciarLetraA() {
    _voiceService.hablar('a');
  }

  /// Inicia la demostración automática del trazo
  Future<void> _iniciarDemostracion() async {
    setState(() {
      _mostrandoDemostracion = true;
      _trazoDemostracion.clear();
    });
    
    await _reproducirSonidoLapiz();
    
    await _demostrarTrazo(_puntosReferenciaCirculo, 0);
    await Future.delayed(const Duration(milliseconds: 300));
    
    await _demostrarTrazo(_puntosReferenciaTallo, 1);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _detenerSonidoLapiz();
    
    setState(() {
      _mostrandoDemostracion = false;
      _trazoDemostracion.clear();
    });
    
    _voiceService.hablar('Ahora te toca a ti');
  }

  /// Demuestra el trazo de una fase específica
  Future<void> _demostrarTrazo(List<Offset> puntos, int fase) async {
    _demostracionController.reset();
    _demostracionController.addListener(() {
      if (mounted) {
        setState(() {
          int indiceActual = (puntos.length * _demostracionController.value).floor();
          _trazoDemostracion = puntos.sublist(0, indiceActual.clamp(0, puntos.length));
        });
      }
    });
    
    await _demostracionController.forward();
    _demostracionController.removeListener(() {});
  }

  /// Inicia un nuevo trazo cuando el usuario toca la pantalla
  void _iniciarNuevoTrazo(Offset puntoInicial) {
    if (_completadoExitosamente || _mostrandoDemostracion) return;
    _reproducirSonidoAbejas();

    if (!_cronometro.isRunning) {
      _cronometro.start();
    }

    setState(() {
      _estaTocando = true;
      _trazoActual = [puntoInicial];
      _posicionPanal = puntoInicial;
    });
  }

  /// Actualiza el trazo mientras el usuario mueve el dedo
  void _actualizarTrazo(Offset puntoActual) {
    if (!_estaTocando || _trazoActual.isEmpty) return;
    
    Offset puntoAnterior = _trazoActual.last;
    double distancia = (puntoActual - puntoAnterior).distance;

    if (distancia > 6) {
      double nuevoAngulo = math.atan2(
        puntoActual.dy - puntoAnterior.dy,
        puntoActual.dx - puntoAnterior.dx,
      );

      _trazoActual.add(puntoActual);
      _evaluarPrecisionMuestraContinua(puntoActual);

      if (_trazoActual.length % 5 == 0) {
        _abejasHuerto.add(
          AbejaAnimada(
            posicion: puntoActual,
            rotacion: (math.Random().nextDouble() * 0.4) - 0.2,
            escalaObjetivo: 1.1,
          ),
        );
      }

      setState(() {
        _posicionPanal = puntoActual;
        _anguloPanal = nuevoAngulo;
      });
    }
  }

  /// Evalúa la precisión SOLO considerando los puntos de la fase actual
  void _evaluarPrecisionMuestraContinua(Offset posicionPanal) {
    const double maxCanalSombreado = 32.0; 
    double menorDistanciaALineaCentro = double.infinity;

    if (_faseTrazoActual == 0) {
      for (var p in _puntosReferenciaCirculo) {
        double d = (posicionPanal - p).distance;
        if (d < menorDistanciaALineaCentro) menorDistanciaALineaCentro = d;
      }
    } else if (_faseTrazoActual == 1) {
      for (var p in _puntosReferenciaTallo) {
        double d = (posicionPanal - p).distance;
        if (d < menorDistanciaALineaCentro) menorDistanciaALineaCentro = d;
      }
    }

    double precisionMuestra = 0.0;
    if (menorDistanciaALineaCentro <= 14.0) {
      precisionMuestra = 100.0; 
    } else if (menorDistanciaALineaCentro <= maxCanalSombreado) {
      precisionMuestra = 100.0 * (1.0 - ((menorDistanciaALineaCentro - 14.0) / (maxCanalSombreado - 14.0)));
    } else {
      precisionMuestra = 0.0; 
    }

    _sumaPrecisionMuestras += precisionMuestra;
    _totalMuestrasTomadas++;

    if (_faseTrazoActual == 0) {
      for (int i = 0; i < _puntosReferenciaCirculo.length; i++) {
        if ((posicionPanal - _puntosReferenciaCirculo[i]).distance < maxCanalSombreado) {
          _cubiertosCirculo[i] = true;
        }
      }
      if (!_cubiertosCirculo.contains(false)) {
        setState(() => _faseTrazoActual = 1); 
        _voiceService.hablar('¡Bien! Ahora baja la línea.');
      }
    } else if (_faseTrazoActual == 1) {
      for (int i = 0; i < _puntosReferenciaTallo.length; i++) {
        if ((posicionPanal - _puntosReferenciaTallo[i]).distance < maxCanalSombreado) {
          _cubiertosTallo[i] = true;
        }
      }
    }

    setState(() {
      _porcentajePrecision = _totalMuestrasTomadas > 0 
          ? (_sumaPrecisionMuestras / _totalMuestrasTomadas) 
          : 0.0;
    });
  }

  /// Finaliza el trazo actual cuando el usuario levanta el dedo
  void _finalizarTrazoActual() {
    _detenerSonidoAbejas();
    if (_trazoActual.isNotEmpty) {
      setState(() {
        _trazos.add(List.from(_trazoActual));
        _trazoActual.clear();
        _estaTocando = false;
      });
      if (!_completadoExitosamente && _porcentajePrecision < 15) {
        _intentosFallidos++;
      }
    }
  }

  /// Ejecuta la calificación final y muestra ventana de resultados
  void _ejecutarCalificacionYVentana() {
    _cronometro.stop();
    setState(() {
      _completadoExitosamente = true;
    });

    int estrellasGanadas = 1;
    if (_porcentajePrecision >= 90) {
      estrellasGanadas = 5; 
    } else if (_porcentajePrecision >= 75) {
      estrellasGanadas = 4;
    } else if (_porcentajePrecision >= 55) {
      estrellasGanadas = 3;
    } else if (_porcentajePrecision >= 30) {
      estrellasGanadas = 2;
    }

    _confetiController.forward(from: 0.0);
    _voiceService.hablar('a, que se pronuncia "a"');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Text(
          'Resultado del Trazo', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF134074)),
          textAlign: TextAlign.center
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_porcentajePrecision.toStringAsFixed(0)}% de Precisión', 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: _porcentajePrecision >= 75 ? Colors.green : Colors.orange
              )
            ),
            const SizedBox(height: 16),
            SecuencialEstrellasWidget(cantidadEstrellas: estrellasGanadas),
            const SizedBox(height: 16),
            Text('Tiempo empleado: ${_cronometro.elapsed.inSeconds}s', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _reiniciarTodo();
                },
                icon: const Icon(Icons.replay, size: 28),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFb388ff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HLibro1()),
                  );
                },
                icon: const Icon(Icons.home, size: 28),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF4caf50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrazoEScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reinicia todo el estado para empezar de nuevo
  void _reiniciarTodo() {
    setState(() {
      _trazos.clear();
      _trazoActual.clear();
      _abejasHuerto.clear();
      _completadoExitosamente = false;
      _intentosFallidos = 0;
      _cronometro.reset();
      _generarPuntosReferenciaPorPartes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF134074),
        title: const Text('SABIA - Letra a', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLiveStatWidget(Icons.ads_click, 'Precisión Real', '${_porcentajePrecision.toStringAsFixed(0)}%', Colors.purple),
                    _buildLiveStatWidget(Icons.refresh, 'Intentos', '$_intentosFallidos', Colors.orange),
                  ],
                ),
              ),
              
              GestureDetector(
                onTap: _pronunciarLetraA,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF59D),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'a',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF134074),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: Container(
                    width: 330,
                    height: 440,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFFFF59D), width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: GestureDetector(
                        onPanStart: (details) => _iniciarNuevoTrazo(details.localPosition),
                        onPanUpdate: (details) => _actualizarTrazo(details.localPosition),
                        onPanEnd: (_) => _finalizarTrazoActual(),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _semillasBlinkController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: MontessoriPainter(
                                    trazos: _trazos,
                                    trazoActual: _trazoActual,
                                    abejasHuerto: _abejasHuerto,
                                    refCirculo: _puntosReferenciaCirculo,
                                    refTallo: _puntosReferenciaTallo,
                                    cubiertosCirculo: _cubiertosCirculo,
                                    cubiertosTallo: _cubiertosTallo,
                                    faseActual: _faseTrazoActual,
                                    factorParpadeo: _semillasBlinkController.value,
                                    trazosDemostracion: _trazoDemostracion,
                                    mostrandoDemostracion: _mostrandoDemostracion,
                                  ),
                                  size: Size.infinite,
                                );
                              },
                            ),

                            if (_posicionPanal != null && !_mostrandoDemostracion)
                              Positioned(
                                left: _posicionPanal!.dx - 24,
                                top: _posicionPanal!.dy - 24,
                                child: Transform.rotate(
                                  angle: _anguloPanal,
                                  child: AnimatedScale(
                                    scale: _estaTocando ? 1.3 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFA000),
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)], 
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.hexagon, size: 36, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        foregroundColor: const Color(0xFF134074),
                        padding: const EdgeInsets.all(14),
                        fixedSize: const Size(56, 56),
                      ),
                      onPressed: _mostrandoDemostracion ? null : _iniciarDemostracion,
                      icon: Icon(
                        _mostrandoDemostracion ? Icons.hourglass_empty : Icons.play_arrow,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[400], 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.all(14),
                        fixedSize: const Size(56, 56),
                      ),
                      onPressed: _reiniciarTodo,
                      icon: const Icon(Icons.delete_sweep, size: 28),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[600], 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.all(14),
                        fixedSize: const Size(56, 56),
                      ),
                      onPressed: _ejecutarCalificacionYVentana,
                      icon: const Icon(Icons.fact_check, size: 28),
                    ),
                  ],
                ),
              ),
            ],
          ),

          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetiController,
              builder: (context, child) {
                if (!_confetiController.isAnimating) return const SizedBox.shrink();
                return CustomPaint(
                  painter: ConfetiPainter(progreso: _confetiController.value),
                  size: Size.infinite,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// Widget para mostrar estadísticas en vivo
  Widget _buildLiveStatWidget(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

/// Widget para mostrar estrellas de calificación secuencialmente
class SecuencialEstrellasWidget extends StatefulWidget {
  final int cantidadEstrellas;
  const SecuencialEstrellasWidget({super.key, required this.cantidadEstrellas});

  @override
  State<SecuencialEstrellasWidget> createState() => _SecuencialEstrellasWidgetState();
}

class _SecuencialEstrellasWidgetState extends State<SecuencialEstrellasWidget> {
  final List<double> _escalasEstrellas = [0.0, 0.0, 0.0, 0.0, 0.0];
  final AudioPlayer _audioPlayerEfecto = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _reproducirEstrellasConRetraso();
  }

  @override
  void dispose() {
    _audioPlayerEfecto.dispose();
    super.dispose();
  }

  void _reproducirEstrellasConRetraso() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      
      setState(() {
        _escalasEstrellas[i] = 1.0;
      });

      if (i < widget.cantidadEstrellas) {
        try {
          await _audioPlayerEfecto.play(AssetSource('sounds/bien.mp3'), mode: PlayerMode.lowLatency);
        } catch (e) {
          debugPrint('Error reproduciendo sonido bien.mp3: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool esGanada = index < widget.cantidadEstrellas;
        return AnimatedScale(
          scale: _escalasEstrellas[index],
          duration: const Duration(milliseconds: 600),
          curve: Curves.bounceOut, 
          child: Icon(
            Icons.star,
            color: esGanada ? Colors.amber : Colors.grey[300],
            size: 44,
          ),
        );
      }),
    );
  }
}

/// Painter personalizado para dibujar la letra a y todos los elementos visuales
class MontessoriPainter extends CustomPainter {
  final List<List<Offset>> trazos;
  final List<Offset> trazoActual;
  final List<AbejaAnimada> abejasHuerto;
  
  final List<Offset> refCirculo;
  final List<Offset> refTallo;
  
  final List<bool> cubiertosCirculo;
  final List<bool> cubiertosTallo;
  
  final int faseActual;
  final double factorParpadeo;
  final List<Offset> trazosDemostracion;
  final bool mostrandoDemostracion;

  MontessoriPainter({
    required this.trazos,
    required this.trazoActual,
    required this.abejasHuerto,
    required this.refCirculo,
    required this.refTallo,
    required this.cubiertosCirculo,
    required this.cubiertosTallo,
    required this.faseActual,
    required this.factorParpadeo,
    required this.trazosDemostracion,
    required this.mostrandoDemostracion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Letra a amarilla de fondo (guía)
    final letterPaint = Paint()
      ..color = const Color(0xFFFFF59D)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 40.0;

    // Dibujar guía del círculo
    final pathCirculo = Path();
    if (refCirculo.isNotEmpty) {
      pathCirculo.moveTo(refCirculo.first.dx, refCirculo.first.dy);
      for (int i = 1; i < refCirculo.length; i++) {
        pathCirculo.lineTo(refCirculo[i].dx, refCirculo[i].dy);
      }
    }
    
    // Dibujar guía del tallo
    final pathTallo = Path();
    if (refTallo.isNotEmpty) {
      pathTallo.moveTo(refTallo.first.dx, refTallo.first.dy);
      for (int i = 1; i < refTallo.length; i++) {
        pathTallo.lineTo(refTallo[i].dx, refTallo[i].dy);
      }
    }

    canvas.drawPath(pathCirculo, letterPaint);
    canvas.drawPath(pathTallo, letterPaint);

    // Durante la demostración, ocultar trazos del usuario, semillas y abejas
    if (!mostrandoDemostracion) {
      // Trazos del usuario (Miel base con efecto fluido)
      final paintMielBase = Paint()
        ..color = const Color(0xFFD48C22)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 38.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0); 

      final paintMielBrillo = Paint()
        ..color = const Color(0xFFFFE082)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 14.0;

      final paintMielBorde = Paint()
        ..color = const Color(0xFF9E5E00)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 42.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      void _dibujarCamino(List<Offset> puntos) {
        if (puntos.length > 1) {
          final path = Path()..moveTo(puntos.first.dx, puntos.first.dy);
          
          for (int i = 1; i < puntos.length - 1; i++) {
            final xc = (puntos[i].dx + puntos[i + 1].dx) / 2;
            final yc = (puntos[i].dy + puntos[i + 1].dy) / 2;
            path.quadraticBezierTo(puntos[i].dx, puntos[i].dy, xc, yc);
          }
          path.lineTo(puntos.last.dx, puntos.last.dy);

          canvas.drawPath(path, paintMielBorde);
          canvas.drawPath(path, paintMielBase);
          canvas.drawPath(path, paintMielBrillo);
        }
      }

      for (var trazo in trazos) {
        _dibujarCamino(trazo);
      }

      _dibujarCamino(trazoActual);

      // Semillas amarillas parpadeantes
      final paintSemilla = Paint()
        ..color = const Color.fromARGB(255, 202, 142, 12).withOpacity(0.4 + (factorParpadeo * 0.6))
        ..style = PaintingStyle.fill;

      if (faseActual == 0) {
        for (int i = 0; i < refCirculo.length; i++) {
          if (!cubiertosCirculo[i]) {
            canvas.drawCircle(refCirculo[i], 5.0 + (factorParpadeo * 3), paintSemilla);
          }
        }
      } else if (faseActual == 1) {
        for (int i = 0; i < refTallo.length; i++) {
          if (!cubiertosTallo[i]) {
            canvas.drawCircle(refTallo[i], 5.0 + (factorParpadeo * 3), paintSemilla);
          }
        }
      }
    }

    // Trazo de demostración (miel brillante)
    if (mostrandoDemostracion && trazosDemostracion.length > 1) {
      final paintDemostracion = Paint()
        ..color = const Color(0xFFE6B800).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 36.0;

      final pathDemostracion = Path()
        ..moveTo(trazosDemostracion.first.dx, trazosDemostracion.first.dy);
      for (int i = 1; i < trazosDemostracion.length; i++) {
        pathDemostracion.lineTo(trazosDemostracion[i].dx, trazosDemostracion[i].dy);
      }
      canvas.drawPath(pathDemostracion, paintDemostracion);
    }

    // Abejas del huerto (solo visibles si NO está en demostración)
    if (!mostrandoDemostracion) {
      for (var abeja in abejasHuerto) {
        if (abeja.escalaActual > 0.05) {
          canvas.save();
          canvas.translate(abeja.posicion.dx, abeja.posicion.dy);
          canvas.rotate(abeja.rotacion);
          canvas.scale(abeja.escalaActual);

          final textPainter = TextPainter(
            text: const TextSpan(text: '🐝', style: TextStyle(fontSize: 32)),
            textDirection: TextDirection.ltr,
          )..layout();

          textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MontessoriPainter oldDelegate) => true;
}

/// Painter para el efecto de confeti
class ConfetiPainter extends CustomPainter {
  final double progreso;
  ConfetiPainter({required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);
    final paintStar = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      double startX = size.width / 2;
      double startY = size.height / 2;
      
      double angulo = random.nextDouble() * 2 * math.pi;
      double velocidad = 80.0 + random.nextDouble() * 150.0;
      
      double currentX = startX + math.cos(angulo) * velocidad * progreso;
      double currentY = startY + math.sin(angulo) * velocidad * progreso + (progreso * progreso * 60.0); 

      paintStar.color = Colors.primaries[random.nextInt(Colors.primaries.length)].withOpacity(1.0 - progreso);
      canvas.drawCircle(Offset(currentX, currentY), 6.0 * (1.0 - progreso), paintStar);
    }
  }

  @override
  bool shouldRepaint(covariant ConfetiPainter oldDelegate) => true;
}