import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 12
/// "Lee en voz alta las siguientes palabras."
///
/// Fila de palabras con fichas de dos tonos rosas (como en el
/// cuadernillo). El niño toca cada una para escucharla, o le da
/// "Escuchar todas" para que la app las lea seguidas como modelo.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_12_lee_voz_alta_palabras.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS12LeeVozAltaPalabras extends StatefulWidget {
  const LeccionS12LeeVozAltaPalabras({super.key});

  @override
  State<LeccionS12LeeVozAltaPalabras> createState() =>
      _LeccionS12LeeVozAltaPalabrasState();
}

class _LeccionS12LeeVozAltaPalabrasState
    extends State<LeccionS12LeeVozAltaPalabras> {
  late final FlutterTts _tts;

  final List<String> _palabras = const ['sapo', 'seis', 'silla', 'sopa', 'suéter'];
  static const Color _colorFuerte = Color(0xFFF3B8C7);
  static const Color _colorClaro = Color(0xFFFAE0E7);

  int? _resaltada;
  bool _hablando = false;
  bool _leyendoTodas = false;

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

  Future<void> _tocarPalabra(int index) async {
    setState(() => _resaltada = index);
    await _hablar(_palabras[index]);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _resaltada = null);
  }

  Future<void> _leerTodas() async {
    if (_leyendoTodas) return;
    setState(() => _leyendoTodas = true);
    for (int i = 0; i < _palabras.length; i++) {
      if (!mounted) return;
      setState(() => _resaltada = i);
      await _tts.stop();
      await _tts.speak(_palabras[i]);
      await Future.delayed(const Duration(milliseconds: 700));
    }
    if (mounted) {
      setState(() {
        _resaltada = null;
        _leyendoTodas = false;
      });
    }
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
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < _palabras.length; i++) _buildFicha(i),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _leyendoTodas ? null : _leerTodas,
                icon: const Icon(Icons.record_voice_over),
                label: const Text('Escuchar todas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3DBFDA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto = '12. Lee en voz alta las siguientes palabras.';
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

  Widget _buildFicha(int index) {
    final resaltada = _resaltada == index;
    final colorBase = index.isEven ? _colorFuerte : _colorClaro;

    return GestureDetector(
      onTap: () => _tocarPalabra(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: resaltada ? const Color(0xFF3DBFDA) : colorBase,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: resaltada ? 6 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _palabras[index],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: resaltada ? Colors.white : const Color(0xFF2D2A26),
          ),
        ),
      ),
    );
  }
}