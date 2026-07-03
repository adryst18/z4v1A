import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN 17 — "¿Qué es? pan"
/// Introducción a la letra P / p.
///
/// Página 25 del cuadernillo:
///   1. Traza las letras.
///   2. Encuentra la /p/ y enciérrala en un círculo.
///
/// Ubicación sugerida: lib/pantallas/NyCM/lecciones/leccion_17_que_es_pan.dart
///
/// Requiere en pubspec.yaml (ya agregado en la lección 16):
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class Leccion17QueEsPan extends StatefulWidget {
  const Leccion17QueEsPan({super.key});

  @override
  State<Leccion17QueEsPan> createState() => _Leccion17QueEsPanState();
}

class _Leccion17QueEsPanState extends State<Leccion17QueEsPan> {
  late final FlutterTts _tts;

  // Cuadrícula de letras tal como aparece en el cuadernillo.
  // 'true' marca las posiciones que sí son la letra "p" (respuesta correcta).
  final List<List<_Letra>> _cuadricula = [
    [
      _Letra('n', false),
      _Letra('n', false),
      _Letra('p', true),
      _Letra('s', false),
      _Letra('p', true),
    ],
    [
      _Letra('s', false),
      _Letra('p', true),
      _Letra('l', false),
      _Letra('s', false),
      _Letra('l', false),
    ],
    [
      _Letra('p', true),
      _Letra('l', false),
      _Letra('s', false),
      _Letra('l', false),
      _Letra('n', false),
    ],
    [
      _Letra('n', false),
      _Letra('s', false),
      _Letra('n', false),
      _Letra('p', true),
      _Letra('l', false),
    ],
  ];

  int _intentos = 0;
  int _encontradas = 0;
  late int _totalPes;

  bool _hablando = false;
  bool _mostrarLeccion = false; // controla si se despliegan las actividades

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('es-MX');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _tts.setStartHandler(() => setState(() => _hablando = true));
    _tts.setCompletionHandler(() => setState(() => _hablando = false));
    _tts.setCancelHandler(() => setState(() => _hablando = false));

    _totalPes = _cuadricula
        .expand((fila) => fila)
        .where((l) => l.esCorrecta)
        .length;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _hablar(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }

  void _tocarLetra(_Letra letra) {
    if (letra.encontrada) return; // ya estaba marcada, no cuenta de nuevo

    setState(() {
      _intentos++;
      if (letra.esCorrecta) {
        letra.encontrada = true;
        _encontradas++;
      }
    });

    // Retroalimentación por voz corta.
    if (letra.esCorrecta) {
      _hablar('¡Muy bien! Encontraste la letra p.');
    } else {
      _hablar('Esa no es. Intenta de nuevo.');
    }

    if (_encontradas == _totalPes) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _hablar('¡Felicidades! Encontraste todas las letras p.');
        }
      });
    }
  }

  void _reiniciar() {
    setState(() {
      for (final fila in _cuadricula) {
        for (final letra in fila) {
          letra.encontrada = false;
        }
      }
      _intentos = 0;
      _encontradas = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completado = _encontradas == _totalPes;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Lección 17'),
        backgroundColor: const Color(0xFF3DBFDA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildEncabezado(),
            const SizedBox(height: 24),
            if (_mostrarLeccion) ...[
              _buildTrazoLetras(),
              const SizedBox(height: 28),
              _buildEncuentraLaP(completado),
            ],
          ],
        ),
      ),
    );
  }

  /// Encabezado "¿Qué es? pan" con la imagen tocable.
  /// Al tocar el encabezado se despliegan/ocultan las actividades.
  Widget _buildEncabezado() {
    return GestureDetector(
      onTap: () => setState(() => _mostrarLeccion = !_mostrarLeccion),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3DBFDA),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '¿Qué es?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'pan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _mostrarLeccion
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'P',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Imagen tocable: al tocarla, dice "pan".
                GestureDetector(
                  onTap: () => _hablar('pan'),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.bakery_dining,
                          size: 56,
                          color: Color(0xFFD08A3E),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Icon(
                            _hablando
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            size: 18,
                            color: const Color(0xFF3DBFDA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'p',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _mostrarLeccion
                    ? 'Toca aquí para ocultar la lección'
                    : 'Toca aquí para ver la lección',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sección 1: Traza las letras (guía visual + audio de indicación).
  Widget _buildTrazoLetras() {
    const instruccion = '1. Traza las letras.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  instruccion,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_outlined),
                color: const Color(0xFF3DBFDA),
                onPressed: () => _hablar(instruccion),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Guía de trazo simplificada (representación visual de la letra
          // punteada, con renglones tipo caligrafía).
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3FBFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBEE9F2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final mayuscula = i == 0;
                return GestureDetector(
                  onTap: () => _hablar(mayuscula ? 'P mayúscula' : 'p'),
                  child: Text(
                    mayuscula ? 'P' : 'p',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3DBFDA).withOpacity(0.45),
                      letterSpacing: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sigue las líneas punteadas con el dedo o el lápiz.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// Sección 2: Encuentra la /p/ y enciérrala en un círculo.
  Widget _buildEncuentraLaP(bool completado) {
    const instruccion = '2. Encuentra la /p/ y enciérrala en un círculo.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  instruccion,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_outlined),
                color: const Color(0xFF3DBFDA),
                onPressed: () => _hablar(instruccion),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final fila in _cuadricula)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: fila.map((letra) => _buildLetraCasilla(letra)).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.refresh, size: 18, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    'Intentos: $_intentos',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Text(
                'Encontradas: $_encontradas / $_totalPes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3DBFDA),
                ),
              ),
            ],
          ),
          if (completado) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7BC98C)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF3C9A50)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '¡Felicidades! Encontraste todas las letras "p".',
                      style: TextStyle(
                        color: Color(0xFF2E7A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: _reiniciar,
              icon: const Icon(Icons.replay),
              label: const Text('Reiniciar actividad'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetraCasilla(_Letra letra) {
    return GestureDetector(
      onTap: () => _tocarLetra(letra),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: letra.encontrada
                ? const Color(0xFF3C9A50)
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Text(
          letra.texto,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: letra.encontrada
                ? const Color(0xFF3C9A50)
                : const Color(0xFF2D2A26),
          ),
        ),
      ),
    );
  }
}

/// Representa una letra dentro de la cuadrícula de búsqueda.
class _Letra {
  final String texto;
  final bool esCorrecta;
  bool encontrada;

  _Letra(this.texto, this.esCorrecta, {this.encontrada = false});
}