import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 8
/// "Pega debajo la palabra que corresponda."
///
/// El niño arrastra cada palabra (en su pastilla azul) hacia el
/// cuadro que está justo debajo de ella, simulando el recortar
/// y pegar del cuadernillo original. Se muestran en dos filas
/// (3 arriba, 2 abajo) igual que en la página.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_8_pega_palabra.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS8PegaPalabra extends StatefulWidget {
  const LeccionS8PegaPalabra({super.key});

  @override
  State<LeccionS8PegaPalabra> createState() => _LeccionS8PegaPalabraState();
}

class _LeccionS8PegaPalabraState extends State<LeccionS8PegaPalabra> {
  late final FlutterTts _tts;

  // Dos filas tal como aparecen en el cuadernillo.
  final List<String> _fila1 = const ['sapo', 'seis', 'sopa'];
  final List<String> _fila2 = const ['silla', 'suéter'];
  static const Color _colorPastilla = Color(0xFFA9D3E5); // azul clarito

  late List<bool> _colocada1;
  late List<bool> _colocada2;
  late List<bool?> _feedback1;
  late List<bool?> _feedback2;

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

    _colocada1 = List<bool>.filled(_fila1.length, false);
    _colocada2 = List<bool>.filled(_fila2.length, false);
    _feedback1 = List<bool?>.filled(_fila1.length, null);
    _feedback2 = List<bool?>.filled(_fila2.length, null);
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

  void _onDropCorrecto(bool esFila1, int index) {
    setState(() {
      if (esFila1) {
        _colocada1[index] = true;
        _feedback1[index] = true;
      } else {
        _colocada2[index] = true;
        _feedback2[index] = true;
      }
    });
    _hablar(esFila1 ? _fila1[index] : _fila2[index]);
  }

  void _onDropIncorrecto(bool esFila1, int index) async {
    setState(() {
      if (esFila1) {
        _feedback1[index] = false;
      } else {
        _feedback2[index] = false;
      }
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        if (esFila1) {
          _feedback1[index] = null;
        } else {
          _feedback2[index] = null;
        }
      });
    }
  }

  void _reiniciar() {
    setState(() {
      _colocada1 = List<bool>.filled(_fila1.length, false);
      _colocada2 = List<bool>.filled(_fila2.length, false);
      _feedback1 = List<bool?>.filled(_fila1.length, null);
      _feedback2 = List<bool?>.filled(_fila2.length, null);
    });
  }

  bool get _completo =>
      _colocada1.every((v) => v) && _colocada2.every((v) => v);

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
            _buildBloque(_fila1, _colocada1, _feedback1, esFila1: true),
            const SizedBox(height: 30),
            _buildBloque(_fila2, _colocada2, _feedback2, esFila1: false),
            const SizedBox(height: 28),
            if (_completo) _buildMensajeExito() else _buildBotonReiniciar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto = '8. Pega debajo la palabra que corresponda.';
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

  Widget _buildBloque(
    List<String> palabras,
    List<bool> colocada,
    List<bool?> feedback, {
    required bool esFila1,
  }) {
    return Column(
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < palabras.length; i++)
              _buildPastilla(palabras[i], colocada[i], i, esFila1),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < palabras.length; i++)
              _buildCuadro(palabras[i], colocada[i], feedback[i], i, esFila1),
          ],
        ),
      ],
    );
  }

  Widget _buildPastilla(String palabra, bool yaColocada, int index, bool esFila1) {
    final pastilla = Opacity(
      opacity: yaColocada ? 0.25 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _colorPastilla,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          palabra,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2A26),
          ),
        ),
      ),
    );

    if (yaColocada) return pastilla;

    return Draggable<String>(
      data: '$esFila1-$index',
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _colorPastilla,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6),
            ],
          ),
          child: Text(
            palabra,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: pastilla),
      onDragStarted: () => _hablar(palabra),
      child: pastilla,
    );
  }

  Widget _buildCuadro(
    String palabraEsperada,
    bool colocada,
    bool? feedback,
    int index,
    bool esFila1,
  ) {
    Color borde;
    if (colocada) {
      borde = Colors.green;
    } else if (feedback == false) {
      borde = Colors.red;
    } else {
      borde = Colors.black26;
    }

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !colocada,
      onAcceptWithDetails: (details) {
        final esperado = '$esFila1-$index';
        if (details.data == esperado) {
          _onDropCorrecto(esFila1, index);
        } else {
          _onDropIncorrecto(esFila1, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 110,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colocada ? _colorPastilla.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borde, width: 2),
          ),
          child: colocada
              ? Text(
                  palabraEsperada,
                  style: const TextStyle(
                    fontSize: 16,
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
              '¡Muy bien! Pegaste todas las palabras correctamente.',
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