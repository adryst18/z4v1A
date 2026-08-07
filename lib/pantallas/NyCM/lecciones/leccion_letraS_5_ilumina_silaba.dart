import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 5
/// "Ilumina cada sílaba con el color que le corresponde."
///
/// Arriba hay una leyenda de 5 colores (uno por cada sílaba:
/// sa, se, si, so, su). El niño toca primero un color de la
/// leyenda para "armar el crayón" y luego toca los círculos de
/// abajo: si el círculo tiene esa sílaba, se pinta; si es otra
/// sílaba (distractor, como "pu", "nu", "pa"...) no debe
/// pintarse — si lo intenta, se le avisa que no corresponde.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_5_ilumina_silaba.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS5IluminaSilaba extends StatefulWidget {
  const LeccionS5IluminaSilaba({super.key});

  @override
  State<LeccionS5IluminaSilaba> createState() =>
      _LeccionS5IluminaSilabaState();
}

class _LeccionS5IluminaSilabaState extends State<LeccionS5IluminaSilaba> {
  late final FlutterTts _tts;

  // Leyenda: sílaba -> color, en el orden del cuadernillo.
  final Map<String, Color> _leyenda = const {
    'sa': Color(0xFFF5D71F),
    'se': Color(0xFFE8A93D),
    'si': Color(0xFFF3AFA0),
    'so': Color(0xFF58B8E8),
    'su': Color(0xFF7FBF7F),
  };

  // Cuadrícula tal como aparece en el cuadernillo (4 filas x 5).
  final List<List<String>> _grid = const [
    ['pu', 'si', 'nu', 'se', 'pi'],
    ['su', 'pa', 'so', 'no', 'so'],
    ['ne', 'sa', 'pe', 'su', 'po'],
    ['si', 'na', 'sa', 'ni', 'se'],
  ];

  // Color asignado a cada celda (null = sin pintar).
  late List<List<Color?>> _pintado;

  // Celda marcada momentáneamente en rojo por error.
  int? _errorFila;
  int? _errorCol;

  String? _colorArmado; // sílaba de la leyenda actualmente seleccionada
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

    _pintado = List.generate(
      _grid.length,
      (_) => List<Color?>.filled(_grid[0].length, null),
    );
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

  void _elegirColor(String silaba) {
    setState(() => _colorArmado = silaba);
    _hablar(silaba);
  }

  void _tocarCelda(int fila, int col) {
    if (_colorArmado == null) return;
    final silaba = _grid[fila][col];

    if (silaba == _colorArmado) {
      setState(() => _pintado[fila][col] = _leyenda[_colorArmado]);
    } else {
      setState(() {
        _errorFila = fila;
        _errorCol = col;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _errorFila = null;
            _errorCol = null;
          });
        }
      });
    }
  }

  void _reiniciar() {
    setState(() {
      _pintado = List.generate(
        _grid.length,
        (_) => List<Color?>.filled(_grid[0].length, null),
      );
      _colorArmado = null;
    });
  }

  int get _totalObjetivo {
    int total = 0;
    for (final fila in _grid) {
      for (final s in fila) {
        if (_leyenda.containsKey(s)) total++;
      }
    }
    return total;
  }

  int get _totalPintado {
    int total = 0;
    for (final fila in _pintado) {
      for (final c in fila) {
        if (c != null) total++;
      }
    }
    return total;
  }

  bool get _completo => _totalPintado == _totalObjetivo;

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
            const SizedBox(height: 20),
            _buildLeyenda(),
            const SizedBox(height: 24),
            for (int f = 0; f < _grid.length; f++) _buildFila(f),
            const SizedBox(height: 20),
            if (_completo) _buildMensajeExito() else _buildBotonReiniciar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto = '5. Ilumina cada sílaba con el color que le corresponde.';
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
                  fontSize: 17,
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

  /// Leyenda de colores: tocar uno "arma" el crayón de esa sílaba.
  Widget _buildLeyenda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Toca un color y luego toca los círculos que digan esa sílaba:',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _leyenda.entries.map((entry) {
            final seleccionado = _colorArmado == entry.key;
            return GestureDetector(
              onTap: () => _elegirColor(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: seleccionado
                        ? const Color(0xFF2D2A26)
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: seleccionado ? 6 : 2,
                    ),
                  ],
                ),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2A26),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFila(int fila) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int c = 0; c < _grid[fila].length; c++) _buildCelda(fila, c),
        ],
      ),
    );
  }

  Widget _buildCelda(int fila, int col) {
    final color = _pintado[fila][col];
    final error = _errorFila == fila && _errorCol == col;

    return GestureDetector(
      onTap: () => _tocarCelda(fila, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: error ? Colors.red : Colors.black87,
            width: error ? 3 : 1.5,
          ),
        ),
        child: Text(
          _grid[fila][col],
          style: const TextStyle(
            fontSize: 15,
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
              '¡Muy bien! Iluminaste todas las sílabas correctas.',
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