import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Ajusta estos imports/colores a tu proyecto si ya tienes un tema global ───
const Color kPrimaryTeal = Color(0xFF00897B);
const Color kWordChipGreen = Color(0xFFD7E9CE);
const Color kReadChipPink = Color(0xFFF4C6D7);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kErrorRed = Color(0xFFE57373);
const Color kLineColor = Color(0xFF00897B);
// ───────────────────────────────────────────────────────────────────────────

class MatchItem {
  final String id; // también es el nombre del asset: assets/imagenes/<id>.png
  final String word;

  const MatchItem({required this.id, required this.word});
}

class Leccion17_6Screen extends StatefulWidget {
  const Leccion17_6Screen({super.key});

  @override
  State<Leccion17_6Screen> createState() => _Leccion17_6ScreenState();
}

class _Leccion17_6ScreenState extends State<Leccion17_6Screen> {
  final FlutterTts _tts = FlutterTts();

  // 0 = ejercicio 11 (unir imagen con palabra), 1 = ejercicio 12 (leer en voz alta)
  int _currentStep = 0;
  int _attempts = 0;
  bool _showSuccess = false;
  bool _showError = false;

  // ── Ejercicio 11: unir con línea ─────────────────────────────────────────
  final List<MatchItem> _images = const [
    MatchItem(id: 'puerta', word: 'puerta'),
    MatchItem(id: 'papa', word: 'papa'),
    MatchItem(id: 'popote', word: 'popote'),
    MatchItem(id: 'pelota', word: 'pelota'),
    MatchItem(id: 'pila', word: 'pila'),
  ];

  // Orden de palabras mostrado en la hoja original (mezclado a propósito)
  final List<String> _wordOrder = const ['popote', 'pelota', 'puerta', 'pila', 'papa'];

  String? _selectedImageId;
  final Map<String, String> _matchedPairs = {}; // imageId -> wordId (ambos iguales cuando aciertan)

  final GlobalKey _stackKey = GlobalKey();
  final Map<String, GlobalKey> _imageKeys = {};
  final Map<String, GlobalKey> _wordKeys = {};
  List<List<Offset>> _lines = [];

  bool get _allMatched => _matchedPairs.length == _images.length;

  // ── Ejercicio 12: leer en voz alta ───────────────────────────────────────
  final List<String> _readingWords = const ['papa', 'pelota', 'pila', 'popote', 'puerta'];
  final Set<String> _readWords = {};

  bool get _allRead => _readWords.length == _readingWords.length;

  @override
  void initState() {
    super.initState();
    _configureTts();
    for (final item in _images) {
      _imageKeys[item.id] = GlobalKey();
      _wordKeys[item.id] = GlobalKey();
    }
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.42);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Lógica: Ejercicio 11 ─────────────────────────────────────────────────
  void _onTapImage(String imageId) {
    if (_matchedPairs.containsKey(imageId)) return;
    setState(() {
      _showError = false;
      _selectedImageId = _selectedImageId == imageId ? null : imageId;
    });
  }

  void _onTapWord(String wordId) {
    if (_selectedImageId == null) return;
    if (_matchedPairs.containsValue(wordId)) return;

    final image = _images.firstWhere((it) => it.id == _selectedImageId);
    final isCorrect = image.word == wordId;

    setState(() {
      if (isCorrect) {
        _matchedPairs[_selectedImageId!] = wordId;
        _selectedImageId = null;
        _recalculateLines();
        if (_allMatched) {
          _showSuccess = true;
        }
      } else {
        _attempts++;
        _showError = true;
        _selectedImageId = null;
      }
    });
  }

  void _recalculateLines() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (stackBox == null) return;

      final newLines = <List<Offset>>[];
      _matchedPairs.forEach((imageId, wordId) {
        final imageBox = _imageKeys[imageId]?.currentContext?.findRenderObject() as RenderBox?;
        final wordBox = _wordKeys[wordId]?.currentContext?.findRenderObject() as RenderBox?;
        if (imageBox == null || wordBox == null) return;

        final imageCenter = imageBox.localToGlobal(
          Offset(imageBox.size.width, imageBox.size.height / 2),
          ancestor: stackBox,
        );
        final wordCenter = wordBox.localToGlobal(
          Offset(0, wordBox.size.height / 2),
          ancestor: stackBox,
        );
        newLines.add([imageCenter, wordCenter]);
      });

      if (mounted) setState(() => _lines = newLines);
    });
  }

  void _goToReadingStep() {
    setState(() {
      _showSuccess = false;
      _currentStep = 1;
    });
  }

  // ── Lógica: Ejercicio 12 ─────────────────────────────────────────────────
  Future<void> _onTapReadWord(String word) async {
    await _speak(word);
    setState(() {
      _readWords.add(word);
      if (_allRead) {
        _showSuccess = true;
      }
    });
  }

  Future<void> _listenAll() async {
    for (final word in _readingWords) {
      await _speak(word);
      await Future.delayed(const Duration(milliseconds: 700));
    }
    setState(() {
      _readWords.addAll(_readingWords);
      _showSuccess = true;
    });
  }

  void _finishLesson() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Excelente trabajo! 🎉'),
        content: const Text('Uniste las imágenes con su palabra y leíste todas en voz alta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: kPrimaryTeal,
        title: Text(_currentStep == 0
            ? 'Une la imagen con la palabra'
            : 'Lee en voz alta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Ejercicio ${_currentStep + 1} de 2',
                style: const TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildAttemptsCounter(),
              const SizedBox(height: 12),
              Expanded(
                child: _currentStep == 0 ? _buildMatchingExercise() : _buildReadingExercise(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttemptsCounter() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kPrimaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Intentos: $_attempts',
          style: const TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Widgets: Ejercicio 11 ────────────────────────────────────────────────
  Widget _buildMatchingExercise() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            key: _stackKey,
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _LinesPainter(_lines),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildImageColumn()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildWordColumn()),
                ],
              ),
            ],
          ),
        ),
        if (_showError) _buildErrorBanner('Esa no es la pareja correcta, intenta otra vez.'),
        if (_showSuccess) _buildSuccessBanner('¡Muy bien, uniste todas las parejas!'),
        const SizedBox(height: 12),
        if (_showSuccess) _buildActionButton(label: 'Siguiente ejercicio', onPressed: _goToReadingStep),
      ],
    );
  }

  Widget _buildImageColumn() {
    return Column(
      children: _images.map((item) {
        final isMatched = _matchedPairs.containsKey(item.id);
        final isSelected = _selectedImageId == item.id;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            key: _imageKeys[item.id],
            onTap: () => _onTapImage(item.id),
            child: Container(
              height: 76,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMatched
                      ? kSuccessGreen
                      : (isSelected ? kPrimaryTeal : Colors.grey.shade300),
                  width: isSelected || isMatched ? 3 : 1,
                ),
              ),
              child: Opacity(
                opacity: isMatched ? 0.55 : 1,
                // Ruta corregida: tus imágenes están directo en
                // assets/imagenes/ (no en assets/images/leccion17/).
                child: Image.asset(
                  'assets/imagenes/${item.id}.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordColumn() {
    return Column(
      children: _wordOrder.map((wordId) {
        final isMatched = _matchedPairs.containsValue(wordId);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            key: _wordKeys[wordId],
            onTap: () => _onTapWord(wordId),
            child: Container(
              height: 76,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isMatched ? kSuccessGreen.withOpacity(0.25) : kWordChipGreen,
                borderRadius: BorderRadius.circular(12),
                border: isMatched ? Border.all(color: kSuccessGreen, width: 2) : null,
              ),
              child: Text(
                wordId,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Widgets: Ejercicio 12 ────────────────────────────────────────────────
  Widget _buildReadingExercise() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          'Toca cada palabra para escucharla y practicar su lectura:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _readingWords.map((word) {
            final isRead = _readWords.contains(word);
            return GestureDetector(
              onTap: () => _onTapReadWord(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isRead ? kSuccessGreen.withOpacity(0.2) : kReadChipPink,
                  borderRadius: BorderRadius.circular(14),
                  border: isRead ? Border.all(color: kSuccessGreen, width: 2) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isRead ? Icons.check_circle : Icons.volume_up,
                      size: 20,
                      color: isRead ? kSuccessGreen : kPrimaryTeal,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _listenAll,
          icon: const Icon(Icons.playlist_play, color: kPrimaryTeal),
          label: const Text('Escuchar todas', style: TextStyle(color: kPrimaryTeal)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryTeal),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const Spacer(),
        if (_showSuccess) _buildSuccessBanner('¡Leíste todas las palabras, muy bien!'),
        const SizedBox(height: 12),
        if (_showSuccess) _buildActionButton(label: 'Finalizar', onPressed: _finishLesson),
      ],
    );
  }

  // ── Widgets compartidos ──────────────────────────────────────────────────
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kErrorRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.close, color: kErrorRed),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: kErrorRed))),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSuccessGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kSuccessGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: kSuccessGreen))),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTeal,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class _LinesPainter extends CustomPainter {
  final List<List<Offset>> lines;

  _LinesPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kLineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final pair in lines) {
      if (pair.length == 2) {
        canvas.drawLine(pair[0], pair[1], paint);
        canvas.drawCircle(pair[0], 5, paint..style = PaintingStyle.fill);
        canvas.drawCircle(pair[1], 5, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinesPainter oldDelegate) => true;
}