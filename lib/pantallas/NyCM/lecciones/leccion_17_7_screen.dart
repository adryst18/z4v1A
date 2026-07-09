import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Ajusta estos imports/colores a tu proyecto si ya tienes un tema global ───
const Color kPrimaryTeal = Color(0xFF00897B);
const Color kGuideTextColor = Color(0xFFBFC7CC);
const Color kBaselineColor = Color(0xFF9FD4E0);
const Color kInkColor = Color(0xFF1A1A1A);
const Color kSuccessGreen = Color(0xFF4CAF50);
// ───────────────────────────────────────────────────────────────────────────

class Leccion17_7Screen extends StatefulWidget {
  const Leccion17_7Screen({super.key});

  @override
  State<Leccion17_7Screen> createState() => _Leccion17_7ScreenState();
}

class _Leccion17_7ScreenState extends State<Leccion17_7Screen> {
  final FlutterTts _tts = FlutterTts();

  final List<String> _sentences = const [
    'Pía pela la papa.',
    'Lupe puso el popote.',
    'Polo pule la puerta.',
    'Pepe usa esa pila.',
    'Pili patea la pelota.',
  ];

  int _currentIndex = 0;
  List<List<Offset>> _strokes = [];

  String get _currentSentence => _sentences[_currentIndex];
  bool get _hasTraced => _strokes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.4);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _strokes = List<List<Offset>>.from(_strokes)..add([details.localPosition]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _strokes.last.add(details.localPosition);
    });
  }

  void _clearCanvas() {
    setState(() => _strokes = []);
  }

  void _nextSentence() {
    setState(() {
      if (_currentIndex < _sentences.length - 1) {
        _currentIndex++;
        _strokes = [];
      } else {
        _showLessonComplete();
      }
    });
  }

  void _showLessonComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Muy bien! 🎉'),
        content: const Text('Copiaste los 5 enunciados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: kPrimaryTeal,
        title: const Text('Copia los enunciados'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressDots(),
              const SizedBox(height: 20),
              _buildSentenceHeader(),
              const SizedBox(height: 20),
              _buildTracingArea(),
              const SizedBox(height: 12),
              _buildCanvasActions(),
              const Spacer(),
              if (!_hasTraced)
                const Text(
                  'Traza el enunciado sobre la línea con el dedo.',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sentences.length, (i) {
        final done = i < _currentIndex;
        final active = i == _currentIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 14 : 10,
          height: active ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? kSuccessGreen
                : (active ? kPrimaryTeal : Colors.grey.shade300),
          ),
        );
      }),
    );
  }

  Widget _buildSentenceHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _currentSentence,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _speak(_currentSentence),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: kPrimaryTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volume_up, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTracingArea() {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Guía punteada (texto tenue) + renglón, imitando la hoja de trazo.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        _currentSentence,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: kGuideTextColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  Container(height: 2, color: kBaselineColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Lienzo de trazo (captura el dibujo del usuario).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              child: CustomPaint(
                painter: _TracePainter(_strokes),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasActions() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _hasTraced ? _clearCanvas : null,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Borrar'),
        style: TextButton.styleFrom(foregroundColor: kPrimaryTeal),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLast = _currentIndex == _sentences.length - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _hasTraced ? _nextSentence : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTeal,
          disabledBackgroundColor: kPrimaryTeal.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          isLast ? 'Finalizar' : 'Siguiente enunciado',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class _TracePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _TracePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kInkColor
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => true;
}