import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 9
/// "Palmea las palabras y marca las sílabas que las forman."
///
/// Por cada palabra se muestran 5 sílabas (algunas correctas,
/// otras distractoras). El niño toca las que sí forman la
/// palabra; al acertar, la sílaba se marca en verde y se
/// escucha en voz alta (simulando el aplauso silábico).
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_9_palmea_marca_silaba.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class _PalabraSilabas {
  final String palabra;
  final List<String> opciones;
  final List<String> correctas;

  const _PalabraSilabas({
    required this.palabra,
    required this.opciones,
    required this.correctas,
  });
}

class LeccionS9PalmeaMarca extends StatefulWidget {
  const LeccionS9PalmeaMarca({super.key});

  @override
  State<LeccionS9PalmeaMarca> createState() => _LeccionS9PalmeaMarcaState();
}

class _LeccionS9PalmeaMarcaState extends State<LeccionS9PalmeaMarca> {
  late final FlutterTts _tts;

  final List<_PalabraSilabas> _palabras = const [
    _PalabraSilabas(
      palabra: 'seis',
      opciones: ['es', 'si', 'seis', 'ei', 'ie'],
      correctas: ['seis'],
    ),
    _PalabraSilabas(
      palabra: 'silla',
      opciones: ['lla', 'as', 'si', 'all', 'is'],
      correctas: ['si', 'lla'],
    ),
    _PalabraSilabas(
      palabra: 'sopa',
      opciones: ['os', 'so', 'pa', 'ap', 'sa'],
      correctas: ['so', 'pa'],
    ),
    _PalabraSilabas(
      palabra: 'suéter',
      opciones: ['eu', 'ret', 'sué', 'ue', 'ter'],
      correctas: ['sué', 'ter'],
    ),
    _PalabraSilabas(
      palabra: 'sapo',
      opciones: ['po', 'op', 'sa', 'as', 'pa'],
      correctas: ['sa', 'po'],
    ),
  ];

  // Por palabra: set de sílabas ya marcadas correctamente.
  late List<Set<String>> _marcadas;
  // Por palabra: índice de opción con error momentáneo (o null).
  late List<int?> _errorIndex;

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

    _marcadas = List.generate(_palabras.length, (_) => <String>{});
    _errorIndex = List<int?>.filled(_palabras.length, null);
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

  void _tocarOpcion(int filaIndex, int opcionIndex) {
    final fila = _palabras[filaIndex];
    final opcion = fila.opciones[opcionIndex];

    if (fila.correctas.contains(opcion) &&
        !_marcadas[filaIndex].contains(opcion)) {
      setState(() => _marcadas[filaIndex].add(opcion));
      _hablar(opcion);
    } else if (!fila.correctas.contains(opcion)) {
      setState(() => _errorIndex[filaIndex] = opcionIndex);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _errorIndex[filaIndex] = null);
      });
    }
  }

  bool _filaCompleta(int index) =>
      _marcadas[index].length == _palabras[index].correctas.length;

  bool get _todoCompleto {
    for (int i = 0; i < _palabras.length; i++) {
      if (!_filaCompleta(i)) return false;
    }
    return true;
  }

  void _reiniciar() {
    setState(() {
      _marcadas = List.generate(_palabras.length, (_) => <String>{});
      _errorIndex = List<int?>.filled(_palabras.length, null);
    });
  }

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
            const SizedBox(height: 24),
            for (int i = 0; i < _palabras.length; i++) ...[
              _buildFila(i),
              const SizedBox(height: 18),
            ],
            if (_todoCompleto) _buildMensajeExito() else _buildBotonReiniciar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto =
        '9. Palmea las palabras y marca las sílabas que las forman.';
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2A26),
                ),
              ),
            ),
            Icon(
              _hablando ? Icons.volume_up : Icons.volume_up_outlined,
              color: const Color(0xFF3DBFDA),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFila(int index) {
    final fila = _palabras[index];
    final completa = _filaCompleta(index);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completa ? Colors.green : Colors.black12,
          width: completa ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _hablar(fila.palabra),
            child: Container(
              width: 90,
              height: 44,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3B68A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                fila.palabra,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2A26),
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (int o = 0; o < fila.opciones.length; o++)
                  _buildOpcion(index, o),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcion(int filaIndex, int opcionIndex) {
    final fila = _palabras[filaIndex];
    final opcion = fila.opciones[opcionIndex];
    final marcada = _marcadas[filaIndex].contains(opcion);
    final error = _errorIndex[filaIndex] == opcionIndex;

    Color fondo = const Color(0xFFF6E27A);
    if (marcada) fondo = Colors.green.withOpacity(0.35);
    if (error) fondo = Colors.red.withOpacity(0.35);

    return GestureDetector(
      onTap: marcada ? null : () => _tocarOpcion(filaIndex, opcionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: marcada
                ? Colors.green
                : (error ? Colors.red : Colors.black12),
          ),
        ),
        child: Text(
          opcion,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2A26),
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
              '¡Muy bien! Marcaste todas las sílabas correctas.',
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
        style:
            OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3DBFDA)),
      ),
    );
  }
}