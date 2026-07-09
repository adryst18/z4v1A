import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Ajusta estos imports/colores a tu proyecto si ya tienes un tema global ───
const Color kPrimaryTeal = Color(0xFF00897B);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kErrorRed = Color(0xFFE57373);
// ───────────────────────────────────────────────────────────────────────────

class OrderExercise {
  final List<String> options; // palabras desordenadas, tal como aparecen en la hoja
  final List<String> correctOrder; // orden correcto que forma el enunciado
  final Color chipColor;

  const OrderExercise({
    required this.options,
    required this.correctOrder,
    required this.chipColor,
  });

  String get fullSentence => correctOrder.join(' ');
}

class Leccion17_8Screen extends StatefulWidget {
  const Leccion17_8Screen({super.key});

  @override
  State<Leccion17_8Screen> createState() => _Leccion17_8ScreenState();
}

class _Leccion17_8ScreenState extends State<Leccion17_8Screen> {
  final FlutterTts _tts = FlutterTts();

  final List<OrderExercise> _exercises = const [
    OrderExercise(
      options: ['pela', 'papa.', 'Pía', 'la'],
      correctOrder: ['Pía', 'pela', 'la', 'papa.'],
      chipColor: Color(0xFFF7E27A),
    ),
    OrderExercise(
      options: ['popote.', 'Lupe', 'el', 'puso'],
      correctOrder: ['Lupe', 'puso', 'el', 'popote.'],
      chipColor: Color(0xFFF4B183),
    ),
    OrderExercise(
      options: ['la', 'pule', 'Polo', 'puerta.'],
      correctOrder: ['Polo', 'pule', 'la', 'puerta.'],
      chipColor: Color(0xFFF4C6D7),
    ),
    OrderExercise(
      options: ['Pepe', 'pila.', 'esa', 'usa'],
      correctOrder: ['Pepe', 'usa', 'esa', 'pila.'],
      chipColor: Color(0xFFAED9E8),
    ),
    OrderExercise(
      options: ['la', 'patea', 'pelota.', 'Pili'],
      correctOrder: ['Pili', 'patea', 'la', 'pelota.'],
      chipColor: Color(0xFFD7E9CE),
    ),
  ];

  // Estado por tarjeta (mismo índice que _exercises).
  late List<List<int>> _selected;
  late List<bool> _completed;
  late List<bool> _showError;

  int _attempts = 0;

  bool get _allCompleted => _completed.every((c) => c);

  @override
  void initState() {
    super.initState();
    _configureTts();
    _selected = List.generate(_exercises.length, (_) => []);
    _completed = List.generate(_exercises.length, (_) => false);
    _showError = List.generate(_exercises.length, (_) => false);
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.42);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _toggleWord(int exerciseIndex, int optionIndex) {
    if (_completed[exerciseIndex]) return;
    final exercise = _exercises[exerciseIndex];
    final selected = _selected[exerciseIndex];

    setState(() {
      _showError[exerciseIndex] = false;
      if (selected.contains(optionIndex)) {
        selected.remove(optionIndex);
      } else if (selected.length < exercise.correctOrder.length) {
        selected.add(optionIndex);
      }

      if (selected.length == exercise.correctOrder.length) {
        _checkExercise(exerciseIndex);
      }
    });
  }

  void _checkExercise(int exerciseIndex) {
    final exercise = _exercises[exerciseIndex];
    final built = _selected[exerciseIndex].map((i) => exercise.options[i]).toList();
    final isCorrect = List.generate(
      built.length,
      (i) => built[i] == exercise.correctOrder[i],
    ).every((match) => match);

    if (isCorrect) {
      _completed[exerciseIndex] = true;
      _showError[exerciseIndex] = false;
    } else {
      _attempts++;
      _showError[exerciseIndex] = true;
      _selected[exerciseIndex] = [];
    }
  }

  void _showLessonComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Excelente! 🎉'),
        content: const Text('Ordenaste todos los enunciados correctamente.'),
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
        title: const Text('Ordena las palabras'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: _exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 22),
                itemBuilder: (context, i) => _buildExerciseCard(i),
              ),
            ),
            _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final completedCount = _completed.where((c) => c).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Completados: $completedCount/${_exercises.length}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          Container(
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
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int i) {
    final exercise = _exercises[i];
    final selected = _selected[i];
    final completed = _completed[i];
    final built = selected.map((idx) => exercise.options[idx]).join(' ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? kSuccessGreen : Colors.grey.shade200,
          width: completed ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(exercise.options.length, (optIndex) {
                    final used = selected.contains(optIndex);
                    return GestureDetector(
                      onTap: () => _toggleWord(i, optIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: used
                              ? exercise.chipColor.withOpacity(0.35)
                              : exercise.chipColor,
                          borderRadius: BorderRadius.circular(10),
                          border: used
                              ? Border.all(color: Colors.grey.shade400)
                              : null,
                        ),
                        child: Text(
                          exercise.options[optIndex],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: used ? Colors.grey.shade500 : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              InkWell(
                onTap: () => _speak(exercise.fullSentence),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryTeal.withOpacity(completed ? 1 : 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: completed ? kSuccessGreen.withOpacity(0.1) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                bottom: BorderSide(
                  color: completed ? kSuccessGreen : Colors.blue.shade100,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    built.isEmpty ? '···' : built,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (completed) const Icon(Icons.check_circle, color: kSuccessGreen, size: 20),
              ],
            ),
          ),
          if (_showError[i]) ...[
            const SizedBox(height: 8),
            const Text(
              'Ese no es el orden correcto, intenta de nuevo.',
              style: TextStyle(color: kErrorRed, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _allCompleted ? _showLessonComplete : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryTeal,
            disabledBackgroundColor: kPrimaryTeal.withOpacity(0.35),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Finalizar', style: TextStyle(fontSize: 16, color: Colors.white)),
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