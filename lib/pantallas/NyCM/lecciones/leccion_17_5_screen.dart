import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Ajusta estos imports/colores a tu proyecto si ya tienes un tema global ───
const Color kPrimaryTeal = Color(0xFF00897B);
const Color kCardOrange = Color(0xFFF4A899);
const Color kOptionYellow = Color(0xFFF7E27A);
const Color kOptionYellowUsed = Color(0xFFE0DCC0);
const Color kWordChipGreen = Color(0xFFD7E9CE);
const Color kLetterTileBorder = Color(0xFF3A3A3A);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kErrorRed = Color(0xFFE57373);
// ───────────────────────────────────────────────────────────────────────────

class SyllableWord {
  final String word;
  final List<String> options; // 5 sílabas mostradas (incluye distractores)
  final List<String> correctSequence; // orden correcto que forma la palabra

  const SyllableWord({
    required this.word,
    required this.options,
    required this.correctSequence,
  });
}

class Leccion17_5Screen extends StatefulWidget {
  const Leccion17_5Screen({super.key});

  @override
  State<Leccion17_5Screen> createState() => _Leccion17_5ScreenState();
}

class _Leccion17_5ScreenState extends State<Leccion17_5Screen> {
  final FlutterTts _tts = FlutterTts();

  // 0 = ejercicio 9 (palmeo de sílabas), 1 = ejercicio 10 (abecedario móvil)
  int _currentStep = 0;

  int _attempts = 0;
  bool _showSuccess = false;
  bool _showError = false;

  // ── Datos y estado: Ejercicio 9 — Palmeo de sílabas ─────────────────────
  final List<SyllableWord> _syllableWords = const [
    SyllableWord(
      word: 'popote',
      options: ['po', 'te', 'et', 'op', 'po'],
      correctSequence: ['po', 'po', 'te'],
    ),
    SyllableWord(
      word: 'puerta',
      options: ['up', 'ta', 'at', 'puer', 're'],
      correctSequence: ['puer', 'ta'],
    ),
    SyllableWord(
      word: 'pila',
      options: ['il', 'la', 'pi', 'al', 'pa'],
      correctSequence: ['pi', 'la'],
    ),
    SyllableWord(
      word: 'pelota',
      options: ['at', 'ta', 'ol', 'lo', 'pe'],
      correctSequence: ['pe', 'lo', 'ta'],
    ),
    SyllableWord(
      word: 'papa',
      options: ['pa', 'lo', 'p', 'ata', 'pa'],
      correctSequence: ['pa', 'pa'],
    ),
  ];
  int _syllableIndex = 0;
  final List<int> _selectedOptionIndices = [];

  SyllableWord get _currentSyllableWord => _syllableWords[_syllableIndex];

  // ── Datos y estado: Ejercicio 10 — Abecedario móvil ─────────────────────
  final List<String> _abcWords = const ['papa', 'pelota', 'puerta', 'popote', 'pila'];
  int _abcIndex = 0;
  late List<String?> _boxes;
  late List<String> _bank;
  late List<bool> _bankUsed;

  String get _currentAbcWord => _abcWords[_abcIndex];
  bool get _allBoxesFilled => !_boxes.contains(null);

  @override
  void initState() {
    super.initState();
    _configureTts();
    _setupAbcWord();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.42);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Lógica: Ejercicio 9 ──────────────────────────────────────────────────
  void _toggleOption(int optionIndex) {
    setState(() {
      _showError = false;
      if (_selectedOptionIndices.contains(optionIndex)) {
        _selectedOptionIndices.remove(optionIndex);
      } else if (_selectedOptionIndices.length <
          _currentSyllableWord.correctSequence.length) {
        _selectedOptionIndices.add(optionIndex);
      }
    });
  }

  void _checkSyllableAnswer() {
    final built =
        _selectedOptionIndices.map((i) => _currentSyllableWord.options[i]).toList();
    final target = _currentSyllableWord.correctSequence;

    final isCorrect = built.length == target.length &&
        List.generate(built.length, (i) => built[i] == target[i])
            .every((match) => match);

    setState(() {
      if (isCorrect) {
        _showSuccess = true;
        _showError = false;
      } else {
        _attempts++;
        _showError = true;
        _selectedOptionIndices.clear();
      }
    });
  }

  void _nextSyllableWord() {
    setState(() {
      _showSuccess = false;
      _showError = false;
      _selectedOptionIndices.clear();
      if (_syllableIndex < _syllableWords.length - 1) {
        _syllableIndex++;
      } else {
        // Termina el ejercicio 9 → pasa al ejercicio 10
        _currentStep = 1;
      }
    });
  }

  // ── Lógica: Ejercicio 10 ─────────────────────────────────────────────────
  void _setupAbcWord() {
    final letters = _currentAbcWord.split('');
    final shuffled = List<String>.from(letters)..shuffle(Random());
    _boxes = List<String?>.filled(letters.length, null);
    _bank = shuffled;
    _bankUsed = List<bool>.filled(shuffled.length, false);
  }

  void _placeLetter(int bankIndex) {
    if (_bankUsed[bankIndex]) return;
    final emptyBoxIndex = _boxes.indexWhere((b) => b == null);
    if (emptyBoxIndex == -1) return;

    setState(() {
      _showError = false;
      _boxes[emptyBoxIndex] = _bank[bankIndex];
      _bankUsed[bankIndex] = true;
    });
  }

  void _removeLetter(int boxIndex) {
    if (_boxes[boxIndex] == null) return;
    final letter = _boxes[boxIndex]!;

    setState(() {
      for (int i = 0; i < _bank.length; i++) {
        if (_bankUsed[i] && _bank[i] == letter) {
          _bankUsed[i] = false;
          break;
        }
      }
      _boxes[boxIndex] = null;
    });
  }

  void _checkAbcAnswer() {
    final built = _boxes.map((l) => l ?? '').join();
    setState(() {
      if (built == _currentAbcWord) {
        _showSuccess = true;
        _showError = false;
      } else {
        _attempts++;
        _showError = true;
      }
    });
  }

  void _resetAbcAttempt() {
    setState(() {
      for (int i = 0; i < _boxes.length; i++) {
        _boxes[i] = null;
      }
      _bankUsed = List<bool>.filled(_bank.length, false);
      _showError = false;
    });
  }

  void _nextAbcWord() {
    setState(() {
      _showSuccess = false;
      _showError = false;
      if (_abcIndex < _abcWords.length - 1) {
        _abcIndex++;
        _setupAbcWord();
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
        title: const Text('¡Excelente! 🎉'),
        content: const Text('Completaste el palmeo de sílabas y el abecedario móvil.'),
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
            ? 'Palmea y marca las sílabas'
            : 'Abecedario móvil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 12),
              _buildProgressDots(),
              const SizedBox(height: 16),
              _buildAttemptsCounter(),
              const SizedBox(height: 12),
              Expanded(
                child: _currentStep == 0
                    ? _buildSyllableExercise()
                    : _buildAbcExercise(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Text(
      'Ejercicio ${_currentStep + 1} de 2',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black45,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProgressDots() {
    final total = _currentStep == 0 ? _syllableWords.length : _abcWords.length;
    final index = _currentStep == 0 ? _syllableIndex : _abcIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final done = i < index;
        final active = i == index;
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

  // ── Widgets: Ejercicio 9 ─────────────────────────────────────────────────
  Widget _buildSyllableExercise() {
    final builtSyllables =
        _selectedOptionIndices.map((i) => _currentSyllableWord.options[i]).join('-');

    return Column(
      children: [
        _buildWordCard(),
        const SizedBox(height: 24),
        const Text(
          'Toca las sílabas en orden:',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _buildOptionsRow(),
        const SizedBox(height: 24),
        _buildBuiltAnswerBox(builtSyllables),
        const Spacer(),
        if (_showError) _buildErrorBanner('Casi, intenta otra vez.'),
        if (_showSuccess) _buildSuccessBanner('¡Muy bien, así se forma la palabra!'),
        const SizedBox(height: 12),
        _buildActionButton(
          label: _showSuccess ? 'Siguiente palabra' : 'Comprobar',
          onPressed: _showSuccess ? _nextSyllableWord : _checkSyllableAnswer,
        ),
      ],
    );
  }

  Widget _buildWordCard() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: kCardOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _currentSyllableWord.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildAudioButton(() => _speak(_currentSyllableWord.word)),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_currentSyllableWord.options.length, (i) {
        final used = _selectedOptionIndices.contains(i);
        return GestureDetector(
          onTap: () => _toggleOption(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: used ? kOptionYellowUsed : kOptionYellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: used ? Colors.grey.shade400 : Colors.transparent,
              ),
            ),
            child: Text(
              _currentSyllableWord.options[i],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: used ? Colors.grey.shade500 : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBuiltAnswerBox(String built) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryTeal.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        built.isEmpty ? '···' : built,
        style: const TextStyle(fontSize: 20, letterSpacing: 1.2),
      ),
    );
  }

  // ── Widgets: Ejercicio 10 ────────────────────────────────────────────────
  Widget _buildAbcExercise() {
    return Column(
      children: [
        _buildWordChipsRow(),
        const SizedBox(height: 24),
        _buildTargetWordHeader(),
        const SizedBox(height: 16),
        _buildBoxesRow(),
        const SizedBox(height: 24),
        const Text(
          'Toca las letras para formar la palabra:',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _buildLetterBank(),
        const Spacer(),
        if (_showError) _buildErrorBanner('Revisa el orden de las letras.'),
        if (_showSuccess) _buildSuccessBanner('¡Perfecto, así se escribe la palabra!'),
        const SizedBox(height: 12),
        _buildAbcActionButtons(),
      ],
    );
  }

  Widget _buildWordChipsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _abcWords.map((w) {
        final isCurrent = w == _currentAbcWord;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: kWordChipGreen,
            borderRadius: BorderRadius.circular(20),
            border: isCurrent ? Border.all(color: kPrimaryTeal, width: 2) : null,
          ),
          child: Text(
            w,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTargetWordHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Palabra: $_currentAbcWord',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(width: 10),
        _buildAudioButton(() => _speak(_currentAbcWord), small: true),
      ],
    );
  }

  Widget _buildBoxesRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_boxes.length, (i) {
        final letter = _boxes[i];
        return GestureDetector(
          onTap: () => _removeLetter(i),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kLetterTileBorder, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              letter ?? '',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterBank() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_bank.length, (i) {
        final used = _bankUsed[i];
        return GestureDetector(
          onTap: () => _placeLetter(i),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: used ? 0.25 : 1,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPrimaryTeal.withOpacity(0.1),
                border: Border.all(color: kPrimaryTeal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _bank[i],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTeal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAbcActionButtons() {
    return Row(
      children: [
        if (!_showSuccess)
          Expanded(
            child: OutlinedButton(
              onPressed: _resetAbcAttempt,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: kPrimaryTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Borrar', style: TextStyle(color: kPrimaryTeal)),
            ),
          ),
        if (!_showSuccess) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: _showSuccess ? 'Siguiente palabra' : 'Comprobar',
            onPressed: _showSuccess
                ? _nextAbcWord
                : (_allBoxesFilled ? _checkAbcAnswer : null),
          ),
        ),
      ],
    );
  }

  // ── Widgets compartidos ──────────────────────────────────────────────────
  Widget _buildAudioButton(VoidCallback onTap, {bool small = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(small ? 10 : 14),
        decoration: const BoxDecoration(
          color: kPrimaryTeal,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.volume_up, color: Colors.white, size: small ? 18 : 24),
      ),
    );
  }

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

  Widget _buildActionButton({required String label, required VoidCallback? onPressed}) {
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