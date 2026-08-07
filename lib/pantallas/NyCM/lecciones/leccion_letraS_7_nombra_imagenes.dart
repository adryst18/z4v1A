import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 7
/// "Nombra las imágenes y lee las palabras."
///
/// NOTA IMPORTANTE:
/// Todavía no hay fotos/dibujos reales para estas palabras, así
/// que aquí se usa un emoji como marcador temporal de imagen.
/// Cuando tengas las imágenes reales en tu carpeta assets, nomás
/// reemplaza en `_ItemImagen` el campo `emoji` por una imagen:
///
///   Image.asset('assets/images/sueter.png', width: 90, height: 90)
///
/// en vez de `Text(emoji, style: TextStyle(fontSize: 64))`.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_7_nombra_imagenes.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class _ItemImagen {
  final String emoji;
  final String palabra;

  const _ItemImagen({required this.emoji, required this.palabra});
}

class LeccionS7NombraImagenes extends StatefulWidget {
  const LeccionS7NombraImagenes({super.key});

  @override
  State<LeccionS7NombraImagenes> createState() =>
      _LeccionS7NombraImagenesState();
}

class _LeccionS7NombraImagenesState extends State<LeccionS7NombraImagenes> {
  late final FlutterTts _tts;

  final List<_ItemImagen> _items = const [
    _ItemImagen(emoji: '🧥', palabra: 'suéter'),
    _ItemImagen(emoji: '🍲', palabra: 'sopa'),
    _ItemImagen(emoji: '🪑', palabra: 'silla'),
    _ItemImagen(emoji: '6️⃣', palabra: 'seis'),
    _ItemImagen(emoji: '🐸', palabra: 'sapo'),
  ];

  int? _resaltado;
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

  Future<void> _tocarItem(int index) async {
    setState(() => _resaltado = index);
    await _hablar(_items[index].palabra);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _resaltado = null);
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < _items.length; i++) _buildTarjeta(i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto = '7. Nombra las imágenes y lee las palabras.';
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

  Widget _buildTarjeta(int index) {
    final item = _items[index];
    final resaltado = _resaltado == index;

    return GestureDetector(
      onTap: () => _tocarItem(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: resaltado
              ? const Color(0xFF3DBFDA).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: resaltado ? const Color(0xFF3DBFDA) : Colors.black12,
            width: resaltado ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 10),
            Text(
              item.palabra,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2A26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}