import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Ajusta estos imports/colores a tu proyecto si ya tienes un tema global ───
const Color kPrimaryTeal = Color(0xFF00897B);
const Color kBankYellow = Color(0xFFF7E27A);
const Color kBankYellowUsed = Color(0xFFE0DCC0);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kErrorRed = Color(0xFFE57373);
const Color kBlankLine = Color(0xFF9FD4E0);
// ───────────────────────────────────────────────────────────────────────────

class FillBlankSentence {
  final String before; // texto antes del espacio en blanco
  final String after; // texto después del espacio en blanco (incluye el punto final)
  final String correctWord;

  const FillBlankSentence({
    required this.before,
    required this.after,
    required this.correctWord,
  });

  String get fullSentence => '$before $correctWord$after'.replaceAll('  ', ' ');
}

class Leccion17_9Screen extends StatefulWidget {
  const Leccion17_9Screen({super.key});

  @override
  State<Leccion17_9Screen> createState() => _Leccion17_9ScreenState();
}

class _Leccion17_9ScreenState extends State<Leccion17_9Screen> {
  final FlutterTts _tts = FlutterTts();

  final List<FillBlankSentence> _sentences = const [
    FillBlankSentence(before: 'Pía', after: ' la papa.', correctWord: 'pela'),
    FillBlankSentence(before: 'Lupe puso el', after: '.', correctWord: 'popote'),
    FillBlankSentence(before: 'Polo', after: ' la puerta.', correctWord: 'pule'),
    FillBlankSentence(before: 'Pepe usa esa', after: '.', correctWord: 'pila'),
    FillBlankSentence(before: 'Pili patea la', after: '.', correctWord: 'pelota'),
  ];

  late List<String?> _filledAnswers; // palabra colocada en cada oración (o null)
  late List<bool?> _checkedCorrect; // null = sin revisar, true/false tras "Comprobar"
  late List<String> _bank; // banco de palabras (todas mezcladas)
  late List<bool> _bankUsed;

  int _attempts = 0;
  bool _showSuccess = false;

  bool get _allFilled => _filledAnswers.every((a) => a != null);
  bool get _allCorrect => _checkedCorrect.every((c) => c == true);

  @override
  void initState() {
    super.initState();
    _configureTts();
    _filledAnswers = List<String?>.filled(_sentences.length, null);
    _checkedCorrect = List<bool?>.filled(_sentences.length, null);
    _bank = _sentences.map((s) => s.correctWord).toList()..shuffle();
    _bankUsed = List<bool>.filled(_bank.length, false);
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.42);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _placeWord(int bankIndex) {
    if (_bankUsed[bankIndex]) return;
    final emptySentenceIndex = _filledAnswers.indexWhere((a) => a == null);
    if (emptySentenceIndex == -1) return;

    setState(() {
      _filledAnswers[emptySentenceIndex] = _bank[bankIndex];
      _bankUsed[bankIndex] = true;
      _checkedCorrect[emptySentenceIndex] = null;
      _showSuccess = false;
    });
  }

  void _clearBlank(int sentenceIndex) {
    final word = _filledAnswers[sentenceIndex];
    if (word == null) return;

    setState(() {
      for (int i = 0; i < _bank.length; i++) {
        if (_bankUsed[i] && _bank[i] == word) {
          _bankUsed[i] = false;
          break;
        }
      }
      _filledAnswers[sentenceIndex] = null;
      _checkedCorrect[sentenceIndex] = null;
      _showSuccess = false;
    });
  }

  void _checkAnswers() {
    setState(() {
      bool anyWrong = false;
      for (int i = 0; i < _sentences.length; i++) {
        final correct = _filledAnswers[i] == _sentences[i].correctWord;
        _checkedCorrect[i] = correct;
        if (!correct) anyWrong = true;
      }
      if (anyWrong) {
        _attempts++;
        // Regresa al banco solo las respuestas incorrectas para reintentar.
        for (int i = 0; i < _sentences.length; i++) {
          if (_checkedCorrect[i] == false) {
            final word = _filledAnswers[i];
            if (word != null) {
              for (int b = 0; b < _bank.length; b++) {
                if (_bankUsed[b] && _bank[b] == word) {
                  _bankUsed[b] = false;
                  break;
                }
              }
            }
            _filledAnswers[i] = null;
            _checkedCorrect[i] = null;
          }
        }
      } else {
        _showSuccess = true;
      }
    });
  }

  void _showLessonComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Lección 17 completada! 🎉'),
        content: const Text('Completaste todos los enunciados con la palabra correcta.'),
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
        title: const Text('Completa los enunciados'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildAttemptsCounter(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                itemCount: _sentences.length,
                separatorBuilder: (_, __) => const SizedBox(height: 22),
                itemBuilder: (context, i) => _buildSentenceRow(i),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Toca una palabra para completar el siguiente espacio:',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  _buildWordBank(),
                  const SizedBox(height: 14),
                  if (_showSuccess) _buildSuccessBanner(),
                  const SizedBox(height: 10),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptsCounter() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
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
      ),
    );
  }

  Widget _buildSentenceRow(int i) {
    final sentence = _sentences[i];
    final filled = _filledAnswers[i];
    final checked = _checkedCorrect[i];

    Color blankColor;
    if (checked == true) {
      blankColor = kSuccessGreen;
    } else if (checked == false) {
      blankColor = kErrorRed;
    } else {
      blankColor = kBlankLine;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${sentence.before} ', style: const TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () => _clearBlank(i),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 90),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: blankColor, width: 2)),
                  ),
                  child: Text(
                    filled ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: checked == false ? kErrorRed : Colors.black87,
                    ),
                  ),
                ),
              ),
              Text(sentence.after, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
        InkWell(
          onTap: () => _speak(sentence.fullSentence),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: kPrimaryTeal, shape: BoxShape.circle),
            child: const Icon(Icons.volume_up, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildWordBank() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(_bank.length, (i) {
        final used = _bankUsed[i];
        return GestureDetector(
          onTap: () => _placeWord(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: used ? kBankYellowUsed : kBankYellow,
              borderRadius: BorderRadius.circular(10),
              border: used ? Border.all(color: Colors.grey.shade400) : null,
            ),
            child: Text(
              _bank[i],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: used ? Colors.grey.shade500 : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSuccessGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: kSuccessGreen),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '¡Muy bien, completaste todos los enunciados!',
              style: TextStyle(color: kSuccessGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccess
            ? _showLessonComplete
            : (_allFilled ? _checkAnswers : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTeal,
          disabledBackgroundColor: kPrimaryTeal.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _showSuccess ? 'Finalizar' : 'Comprobar',
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