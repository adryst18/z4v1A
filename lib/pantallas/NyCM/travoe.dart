import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sabia/services/voice_service.dart';
import 'package:sabia/services/log_service.dart';
import 'package:sabia/models/log_entry.dart';
import 'package:sabia/pantallas/NyCM/hlilbro1.dart';

import 'package:sabia/pantallas/NyCM/travoami.dart';

class EloteAnimado {
  final Offset posicion;
  final double rotacion;
  final double escalaObjetivo;
  double escalaActual = 0.0;

  EloteAnimado({
    required this.posicion,
    required this.rotacion,
    required this.escalaObjetivo,
  });
}

class TrazoEScreen extends StatefulWidget {
  const TrazoEScreen({super.key});

  @override
  State<TrazoEScreen> createState() => _TrazoEScreenState();
}

class _TrazoEScreenState extends State<TrazoEScreen> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  final LogService _logService = LogService();
  final AudioPlayer _audioPlayerTractor = AudioPlayer();
  final AudioPlayer _audioPlayerLapiz = AudioPlayer();
  
  List<List<Offset>> _trazos = [];
  List<Offset> _trazoActual = [];
  List<EloteAnimado> _huertoElotes = [];
  
  Offset? _posicionTractor;
  double _anguloTractor = 0.0;
  bool _estaTocandoTractor = false;

  final Stopwatch _cronometro = Stopwatch();
  int _intentosFallidos = 0;
  bool _completadoExitosamente = false;
  
  double _porcentajePrecision = 0.0;
  double _sumaPrecisionMuestras = 0.0;
  int _totalMuestrasTomadas = 0;

  late AnimationController _semillasBlinkController;
  late AnimationController _loopElotesController;
  late AnimationController _demostracionController;
  
  int _faseTrazoActual = 0;
  
  List<Offset> _puntosReferenciaVertical = [];
  List<Offset> _puntosReferenciaSuperior = [];
  List<Offset> _puntosReferenciaMedio = [];
  List<Offset> _puntosReferenciaInferior = [];
  
  List<bool> _cubiertosVertical = [];
  List<bool> _cubiertosSuperior = [];
  List<bool> _cubiertosMedio = [];
  List<bool> _cubiertosInferior = [];

  bool _mostrandoDemostracion = false;
  List<Offset> _trazoDemostracion = [];

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _generarPuntosReferenciaPorPartes();
    
    _semillasBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _loopElotesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          for (var elote in _huertoElotes) {
            if (elote.escalaActual < elote.escalaObjetivo) {
              elote.escalaActual += 0.08;
              if (elote.escalaActual > elote.escalaObjetivo) {
                elote.escalaActual = elote.escalaObjetivo;
              }
            }
          }
        });
      });
    _loopElotesController.repeat();

    _demostracionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _voiceService.hablar('Toca la letra E y luego sigue el camino del tractor');
  }

  @override
  void dispose() {
    _semillasBlinkController.dispose();
    _loopElotesController.dispose();
    _demostracionController.dispose();
    _audioPlayerTractor.dispose();
    _audioPlayerLapiz.dispose();
    _cronometro.stop();
    super.dispose();
  }

  void _generarPuntosReferenciaPorPartes() {
    final startX = 95.0;
    final endX = 235.0;
    final topY = 80.0;
    final midY = 210.0;
    final bottomY = 340.0;
    
    _puntosReferenciaVertical.clear();
    _puntosReferenciaSuperior.clear();
    _puntosReferenciaMedio.clear();
    _puntosReferenciaInferior.clear();

    for (double t = 0; t <= 1; t += 0.06) {
      _puntosReferenciaVertical.add(Offset(startX, topY + (t * (bottomY - topY))));
    }
    for (double t = 0.1; t <= 1; t += 0.1) {
      _puntosReferenciaSuperior.add(Offset(startX + (t * (endX - startX)), topY));
    }
    for (double t = 0.1; t <= 0.85; t += 0.1) {
      _puntosReferenciaMedio.add(Offset(startX + (t * (endX - startX)), midY));
    }
    for (double t = 0.1; t <= 1; t += 0.1) {
      _puntosReferenciaInferior.add(Offset(startX + (t * (endX - startX)), bottomY));
    }

    _cubiertosVertical = List.filled(_puntosReferenciaVertical.length, false);
    _cubiertosSuperior = List.filled(_puntosReferenciaSuperior.length, false);
    _cubiertosMedio = List.filled(_puntosReferenciaMedio.length, false);
    _cubiertosInferior = List.filled(_puntosReferenciaInferior.length, false);
    
    _faseTrazoActual = 0; 
    _posicionTractor = Offset(startX, topY);
    
    _porcentajePrecision = 0.0;
    _sumaPrecisionMuestras = 0.0;
    _totalMuestrasTomadas = 0;
  }

  Future<void> _encenderMotorTractor() async {
    try {
      await _audioPlayerTractor.setReleaseMode(ReleaseMode.loop);
      await _audioPlayerTractor.play(AssetSource('sounds/tractor.mp3'));
    } catch (e) {
      debugPrint('Error cargando audio del tractor: $e');
    }
  }

  Future<void> _apagarMotorTractor() async {
    await _audioPlayerTractor.stop();
  }

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

  void _pronunciarLetraE() {
    _voiceService.hablar('E');
  }

  Future<void> _iniciarDemostracion() async {
    setState(() {
      _mostrandoDemostracion = true;
      _trazoDemostracion.clear();
    });
    
    await _reproducirSonidoLapiz();
    
    await _demostrarTrazo(_puntosReferenciaVertical, 0);
    await Future.delayed(const Duration(milliseconds: 300));
    
    await _demostrarTrazo(_puntosReferenciaSuperior, 1);
    await Future.delayed(const Duration(milliseconds: 300));
    
    await _demostrarTrazo(_puntosReferenciaMedio, 2);
    await Future.delayed(const Duration(milliseconds: 300));
    
    await _demostrarTrazo(_puntosReferenciaInferior, 3);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _detenerSonidoLapiz();
    
    setState(() {
      _mostrandoDemostracion = false;
      _trazoDemostracion.clear();
    });
    
    _voiceService.hablar('Ahora te toca a ti');
  }

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

  void _iniciarNuevoTrazo(Offset puntoInicial) {
    if (_completadoExitosamente || _mostrandoDemostracion) return;
    _encenderMotorTractor();

    if (!_cronometro.isRunning) {
      _cronometro.start();
    }

    setState(() {
      _estaTocandoTractor = true;
      _trazoActual = [puntoInicial];
      _posicionTractor = puntoInicial;
    });
  }

  void _actualizarTrazo(Offset puntoActual) {
    if (!_estaTocandoTractor || _trazoActual.isEmpty) return;
    
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
        _huertoElotes.add(
          EloteAnimado(
            posicion: puntoActual,
            rotacion: (math.Random().nextDouble() * 0.4) - 0.2,
            escalaObjetivo: 1.1,
          ),
        );
      }

      setState(() {
        _posicionTractor = puntoActual;
        _anguloTractor = nuevoAngulo;
      });
    }
  }

  void _evaluarPrecisionMuestraContinua(Offset posicionTractor) {
    const double maxCanalSombreado = 32.0; 
    double menorDistanciaALineaCentro = double.infinity;

    if (_faseTrazoActual == 0) {
      for (var p in _puntosReferenciaVertical) {
        double d = (posicionTractor - p).distance;
        if (d < menorDistanciaALineaCentro) menorDistanciaALineaCentro = d;
      }
    } else if (_faseTrazoActual == 1) {
      for (var p in _puntosReferenciaSuperior) {
        double d = (posicionTractor - p).distance;
        if (d < menorDistanciaALineaCentro) menorDistanciaALineaCentro = d;
      }
    } else if (_faseTrazoActual == 2) {
      for (var p in _puntosReferenciaMedio) {
        double d = (posicionTractor - p).distance;
        if (d < menorDistanciaALineaCentro) menorDistanciaALineaCentro = d;
      }
    } else if (_faseTrazoActual == 3) {
      for (var p in _puntosReferenciaInferior) {
        double d = (posicionTractor - p).distance;
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
      for (int i = 0; i < _puntosReferenciaVertical.length; i++) {
        if ((posicionTractor - _puntosReferenciaVertical[i]).distance < maxCanalSombreado) {
          _cubiertosVertical[i] = true;
        }
      }
      if (!_cubiertosVertical.contains(false)) {
        setState(() => _faseTrazoActual = 1); 
        _voiceService.hablar('¡Bien! Ahora la línea de arriba.');
      }
    } else if (_faseTrazoActual == 1) {
      for (int i = 0; i < _puntosReferenciaSuperior.length; i++) {
        if ((posicionTractor - _puntosReferenciaSuperior[i]).distance < maxCanalSombreado) {
          _cubiertosSuperior[i] = true;
        }
      }
      if (!_cubiertosSuperior.contains(false)) {
        setState(() => _faseTrazoActual = 2); 
        _voiceService.hablar('Excelente, ahora la línea del medio.');
      }
    } else if (_faseTrazoActual == 2) {
      for (int i = 0; i < _puntosReferenciaMedio.length; i++) {
        if ((posicionTractor - _puntosReferenciaMedio[i]).distance < maxCanalSombreado) {
          _cubiertosMedio[i] = true;
        }
      }
      if (!_cubiertosMedio.contains(false)) {
        setState(() => _faseTrazoActual = 3); 
        _voiceService.hablar('¡Último paso! Haz la línea de abajo.');
      }
    } else if (_faseTrazoActual == 3) {
      for (int i = 0; i < _puntosReferenciaInferior.length; i++) {
        if ((posicionTractor - _puntosReferenciaInferior[i]).distance < maxCanalSombreado) {
          _cubiertosInferior[i] = true;
        }
      }
    }

    setState(() {
      _porcentajePrecision = _totalMuestrasTomadas > 0 
          ? (_sumaPrecisionMuestras / _totalMuestrasTomadas) 
          : 0.0;
    });
  }

  void _finalizarTrazoActual() {
    _apagarMotorTractor();
    if (_trazoActual.isNotEmpty) {
      setState(() {
        _trazos.add(List.from(_trazoActual));
        _trazoActual.clear();
        _estaTocandoTractor = false;
      });
      if (!_completadoExitosamente && _porcentajePrecision < 15
      
      
      ) {
        _intentosFallidos++;
      }
    }
  }

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

    _voiceService.hablar('E, que se pronuncia "eee"');

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
                    MaterialPageRoute(builder: (context) => const TrazoAMinusculaScreen()),
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

  void _reiniciarTodo() {
    setState(() {
      _trazos.clear();
      _trazoActual.clear();
      _huertoElotes.clear();
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
        title: const Text('SABIA - Letra E', style: TextStyle(color: Colors.white)),
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
                onTap: _pronunciarLetraE,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF99d98c),
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
                      'E',
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
                      color: const Color(0xFF99d98c),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFd8f3dc), width: 6),
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
                                    huerto: _huertoElotes,
                                    refVertical: _puntosReferenciaVertical,
                                    refSuperior: _puntosReferenciaSuperior,
                                    refMedio: _puntosReferenciaMedio,
                                    refInferior: _puntosReferenciaInferior,
                                    cubiertosVertical: _cubiertosVertical,
                                    cubiertosSuperior: _cubiertosSuperior,
                                    cubiertosMedio: _cubiertosMedio,
                                    cubiertosInferior: _cubiertosInferior,
                                    faseActual: _faseTrazoActual,
                                    factorParpadeo: _semillasBlinkController.value,
                                    trazosDemostracion: _trazoDemostracion,
                                    mostrandoDemostracion: _mostrandoDemostracion,
                                  ),
                                  size: Size.infinite,
                                );
                              },
                            ),

                            if (_posicionTractor != null && !_mostrandoDemostracion)
                              Positioned(
                                left: _posicionTractor!.dx - 24,
                                top: _posicionTractor!.dy - 24,
                                child: Transform.rotate(
                                  angle: _anguloTractor,
                                  child: AnimatedScale(
                                    scale: _estaTocandoTractor ? 1.3 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E88E5),
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)], 
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.agriculture, size: 36, color: Colors.white),
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
        ],
      ),
    );
  }

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

class MontessoriPainter extends CustomPainter {
  final List<List<Offset>> trazos;
  final List<Offset> trazoActual;
  final List<EloteAnimado> huerto;
  
  final List<Offset> refVertical;
  final List<Offset> refSuperior;
  final List<Offset> refMedio;
  final List<Offset> refInferior;
  
  final List<bool> cubiertosVertical;
  final List<bool> cubiertosSuperior;
  final List<bool> cubiertosMedio;
  final List<bool> cubiertosInferior;
  
  final int faseActual;
  final double factorParpadeo;
  final List<Offset> trazosDemostracion;
  final bool mostrandoDemostracion;

  MontessoriPainter({
    required this.trazos,
    required this.trazoActual,
    required this.huerto,
    required this.refVertical,
    required this.refSuperior,
    required this.refMedio,
    required this.refInferior,
    required this.cubiertosVertical,
    required this.cubiertosSuperior,
    required this.cubiertosMedio,
    required this.cubiertosInferior,
    required this.faseActual,
    required this.factorParpadeo,
    required this.trazosDemostracion,
    required this.mostrandoDemostracion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = const Color(0xFF55a644)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 64.0;

    final letterPaint = Paint()
      ..color = const Color(0xFFb7e4c7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 50.0;

    final startX = 95.0;
    final endX = 235.0;
    final topY = 80.0;
    final midY = 210.0;
    final bottomY = 340.0;

    final pathE = Path()
      ..moveTo(startX, topY)
      ..lineTo(startX, bottomY) 
      ..moveTo(startX, topY)
      ..lineTo(endX, topY)      
      ..moveTo(startX, midY)
      ..lineTo(startX + (endX - startX) * 0.85, midY) 
      ..moveTo(startX, bottomY)
      ..lineTo(endX, bottomY);    

    canvas.drawPath(pathE, shadowPaint);
    canvas.drawPath(pathE, letterPaint);

    if (!mostrandoDemostracion) {
      final paintTierra = Paint()
        ..color = const Color(0xFF4a3319)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 44.0;

      for (var trazo in trazos) {
        if (trazo.length > 1) {
          final path = Path()..moveTo(trazo.first.dx, trazo.first.dy);
          for (int i = 1; i < trazo.length; i++) {
            path.lineTo(trazo[i].dx, trazo[i].dy);
          }
          canvas.drawPath(path, paintTierra);
        }
      }

      if (trazoActual.length > 1) {
        final pathActual = Path()..moveTo(trazoActual.first.dx, trazoActual.first.dy);
        for (int i = 1; i < trazoActual.length; i++) {
          pathActual.lineTo(trazoActual[i].dx, trazoActual[i].dy);
        }
        canvas.drawPath(pathActual, paintTierra);
      }

      final paintSemilla = Paint()
        ..color = const Color(0xFFFFEE58).withOpacity(0.4 + (factorParpadeo * 0.6))
        ..style = PaintingStyle.fill;

      if (faseActual == 0) {
        for (int i = 0; i < refVertical.length; i++) {
          if (!cubiertosVertical[i]) canvas.drawCircle(refVertical[i], 5.0 + (factorParpadeo * 3), paintSemilla);
        }
      } else if (faseActual == 1) {
        for (int i = 0; i < refSuperior.length; i++) {
          if (!cubiertosSuperior[i]) canvas.drawCircle(refSuperior[i], 5.0 + (factorParpadeo * 3), paintSemilla);
        }
      } else if (faseActual == 2) {
        for (int i = 0; i < refMedio.length; i++) {
          if (!cubiertosMedio[i]) canvas.drawCircle(refMedio[i], 5.0 + (factorParpadeo * 3), paintSemilla);
        }
      } else if (faseActual == 3) {
        for (int i = 0; i < refInferior.length; i++) {
          if (!cubiertosInferior[i]) canvas.drawCircle(refInferior[i], 5.0 + (factorParpadeo * 3), paintSemilla);
        }
      }
    }

    if (mostrandoDemostracion && trazosDemostracion.length > 1) {
      final paintDemostracion = Paint()
        ..color = const Color(0xFF55a644).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 40.0;

      final pathDemostracion = Path()
        ..moveTo(trazosDemostracion.first.dx, trazosDemostracion.first.dy);
      for (int i = 1; i < trazosDemostracion.length; i++) {
        pathDemostracion.lineTo(trazosDemostracion[i].dx, trazosDemostracion[i].dy);
      }
      canvas.drawPath(pathDemostracion, paintDemostracion);
    }

    if (!mostrandoDemostracion) {
      for (var elote in huerto) {
        if (elote.escalaActual > 0.05) {
          canvas.save();
          canvas.translate(elote.posicion.dx, elote.posicion.dy);
          canvas.rotate(elote.rotacion);
          canvas.scale(elote.escalaActual);

          final textPainter = TextPainter(
            text: const TextSpan(text: '🌽', style: TextStyle(fontSize: 32)),
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