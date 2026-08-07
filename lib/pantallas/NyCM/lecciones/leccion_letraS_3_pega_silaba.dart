import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 3
/// "Pega debajo la sílaba que corresponda."
///
/// El niño arrastra cada sílaba (so, si, se, sa, su) hacia el
/// cuadro que está justo debajo de ella, simulando el recortar
/// y pegar del cuadernillo original.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_3_pega_silaba.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS3PegaSilaba extends StatefulWidget {
  const LeccionS3PegaSilaba({super.key});

  @override
  State<LeccionS3PegaSilaba> createState() => _LeccionS3PegaSilabaState();
}

class _LeccionS3PegaSilabaState extends State<LeccionS3PegaSilaba> {
  late final FlutterTts _tts;

  // Sílabas tal como aparecen en el cuadernillo, en este orden.
  final List<String> _silabas = const ['so', 'si', 'se', 'sa', 'su'];
  static const Color _colorFicha = Color(0xFFF6E27A); // amarillo/tan

  // Índice del cuadro que actualmente tiene la sílaba correcta pegada.
  late List<bool> _colocada;

  // Feedback temporal por cuadro: null = neutro, true = correcto, false = error.
  late List<bool?> _feedback;

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

    _colocada = List<bool>.filled(_silabas.length, false);
    _feedback = List<bool?>.filled(_silabas.length, null);
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

  void _onDropCorrecto(int index) {
    setState(() {
      _colocada[index] = true;
      _feedback[index] = true;
    });
    _hablar(_silabas[index]);
  }

  void _onDropIncorrecto(int index) async {
    setState(() => _feedback[index] = false);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _feedback[index] = null);
  }

  void _reiniciar() {
    setState(() {
      _colocada = List<bool>.filled(_silabas.length, false);
      _feedback = List<bool?>.filled(_silabas.length, null);
    });
  }

  bool get _completo => _colocada.every((v) => v);

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

            // Fila de fichas arrastrables (las que ya se colocaron se atenúan).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < _silabas.length; i++) _buildFicha(i),
              ],
            ),

            const SizedBox(height: 40),

            // Fila de cuadros donde se sueltan las fichas.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < _silabas.length; i++) _buildCuadro(i),
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
    const texto = '3. Pega debajo la sílaba que corresponda.';
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

  Widget _buildFicha(int index) {
    final yaColocada = _colocada[index];
    final silaba = _silabas[index];

    final chip = Opacity(
      opacity: yaColocada ? 0.25 : 1.0,
      child: Container(
        width: 60,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _colorFicha,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          silaba,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2A26),
          ),
        ),
      ),
    );

    if (yaColocada) return chip;

    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 60,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _colorFicha,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            silaba,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      onDragStarted: () => _hablar(silaba),
      child: chip,
    );
  }

  Widget _buildCuadro(int index) {
    final feedback = _feedback[index];
    final colocada = _colocada[index];

    Color borde;
    if (colocada) {
      borde = Colors.green;
    } else if (feedback == false) {
      borde = Colors.red;
    } else {
      borde = Colors.black26;
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => !_colocada[index],
      onAcceptWithDetails: (details) {
        if (details.data == index) {
          _onDropCorrecto(index);
        } else {
          _onDropIncorrecto(index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 60,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colocada
                ? _colorFicha.withOpacity(0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borde, width: 2),
          ),
          child: colocada
              ? Text(
                  _silabas[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2A26),
                  ),
                )
              : null,
        );
      },
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
              '¡Muy bien! Pegaste todas las sílabas correctamente.',
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