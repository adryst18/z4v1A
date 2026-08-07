import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 4
/// "Une con una línea las sílabas que correspondan."
///
/// El niño toca una sílaba en mayúscula (izquierda) y luego su
/// pareja en minúscula (derecha). Si coinciden, ambas se pintan
/// del mismo color como confirmación del emparejamiento.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_4_une_silabas.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS4UneSilabas extends StatefulWidget {
  const LeccionS4UneSilabas({super.key});

  @override
  State<LeccionS4UneSilabas> createState() => _LeccionS4UneSilabasState();
}

class _LeccionS4UneSilabasState extends State<LeccionS4UneSilabas> {
  late final FlutterTts _tts;

  // Orden tal como aparece en el cuadernillo.
  final List<String> _izquierda = const ['SO', 'SU', 'SA', 'SE', 'SI'];
  final List<String> _derecha = const ['si', 'se', 'sa', 'so', 'su'];

  // Colores para marcar cada pareja encontrada (se van asignando en orden).
  final List<Color> _paleta = const [
    Color(0xFFA9D3E5), // azul
    Color(0xFFC3D9A0), // verde
    Color(0xFFF3B8C7), // rosa
    Color(0xFFF3B68A), // durazno
    Color(0xFFF6E27A), // amarillo
  ];

  int? _seleccionIzquierda;
  int? _shakeIndex; // índice (lado derecho) que se marcó como error momentáneo
  bool _shakeEsIzquierda = false;

  // -1 = sin pareja encontrada; si tiene valor, es el índice en _paleta.
  late List<int> _colorPorIzquierda;
  late List<int> _colorPorDerecha;

  bool _hablando = false;

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

    _colorPorIzquierda = List<int>.filled(_izquierda.length, -1);
    _colorPorDerecha = List<int>.filled(_derecha.length, -1);
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

  void _tocarIzquierda(int index) {
    if (_colorPorIzquierda[index] != -1) return; // ya emparejada
    setState(() => _seleccionIzquierda = index);
    _hablar(_izquierda[index]);
  }

  void _tocarDerecha(int indexDerecha) {
    if (_colorPorDerecha[indexDerecha] != -1) return; // ya emparejada
    if (_seleccionIzquierda == null) return;

    final indexIzq = _seleccionIzquierda!;
    final correcto =
        _izquierda[indexIzq].toLowerCase() == _derecha[indexDerecha];

    _hablar(_derecha[indexDerecha]);

    if (correcto) {
      final colorIndex = _colorPorIzquierda.where((c) => c != -1).length;
      setState(() {
        _colorPorIzquierda[indexIzq] = colorIndex;
        _colorPorDerecha[indexDerecha] = colorIndex;
        _seleccionIzquierda = null;
      });
    } else {
      setState(() {
        _shakeIndex = indexDerecha;
        _shakeEsIzquierda = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shakeIndex = null;
            _seleccionIzquierda = null;
          });
        }
      });
    }
  }

  void _reiniciar() {
    setState(() {
      _colorPorIzquierda = List<int>.filled(_izquierda.length, -1);
      _colorPorDerecha = List<int>.filled(_derecha.length, -1);
      _seleccionIzquierda = null;
    });
  }

  bool get _completo => _colorPorIzquierda.every((c) => c != -1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Aprendiendo la letra S'),
        backgroundColor: const Color(0xFF3DBFDA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildIndicacion(),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _izquierda.length; i++)
                      _buildBoton(
                        texto: _izquierda[i],
                        seleccionado: _seleccionIzquierda == i,
                        colorIndex: _colorPorIzquierda[i],
                        error: _shakeEsIzquierda && _shakeIndex == i,
                        onTap: () => _tocarIzquierda(i),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < _derecha.length; i++)
                      _buildBoton(
                        texto: _derecha[i],
                        seleccionado: false,
                        colorIndex: _colorPorDerecha[i],
                        error: !_shakeEsIzquierda && _shakeIndex == i,
                        onTap: () => _tocarDerecha(i),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_completo) _buildMensajeExito() else _buildBotonReiniciar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto = '4. Une con una línea las sílabas que correspondan.';
    return GestureDetector(
      onTap: () => _hablar(texto),
      child: Container(
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
        child: Row(
          children: [
            const Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2A26),
                ),
              ),
            ),
            Icon(
              _hablando ? Icons.volume_up : Icons.volume_up_outlined,
              color: const Color(0xFF3DBFDA),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoton({
    required String texto,
    required bool seleccionado,
    required int colorIndex,
    required bool error,
    required VoidCallback onTap,
  }) {
    Color fondo = Colors.white;
    Color borde = Colors.black26;

    if (colorIndex != -1) {
      fondo = _paleta[colorIndex % _paleta.length];
      borde = fondo;
    } else if (error) {
      fondo = Colors.red.withOpacity(0.15);
      borde = Colors.red;
    } else if (seleccionado) {
      fondo = const Color(0xFF3DBFDA).withOpacity(0.15);
      borde = const Color(0xFF3DBFDA);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borde, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2A26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMensajeExito() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '¡Muy bien! Uniste todas las sílabas correctamente.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonReiniciar() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: _reiniciar,
        icon: const Icon(Icons.refresh),
        label: const Text('Reiniciar'),
        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3DBFDA)),
      ),
    );
  }
}