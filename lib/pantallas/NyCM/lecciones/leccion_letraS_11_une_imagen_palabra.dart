import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 11
/// "Toca la imagen y luego toca la palabra correcta."
///
/// NOTA: se usa un emoji como marcador temporal de imagen (igual
/// que en la actividad 7). Cuando tengas las fotos reales,
/// reemplaza el `Text(emoji, ...)` en `_buildImagen` por
/// `Image.asset('assets/images/....png')`.
///
/// El niño toca una imagen a la izquierda y luego su palabra a
/// la derecha; si coinciden, ambas se pintan del mismo color.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_11_une_imagen_palabra.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class LeccionS11UneImagenPalabra extends StatefulWidget {
  const LeccionS11UneImagenPalabra({super.key});

  @override
  State<LeccionS11UneImagenPalabra> createState() =>
      _LeccionS11UneImagenPalabraState();
}

class _LeccionS11UneImagenPalabraState
    extends State<LeccionS11UneImagenPalabra> {
  late final FlutterTts _tts;

  // Imágenes (emoji) en el orden del cuadernillo, con su palabra correcta.
  final List<Map<String, String>> _imagenes = const [
    {'emoji': '🪑', 'palabra': 'silla'},
    {'emoji': '🧥', 'palabra': 'suéter'},
    {'emoji': '🐸', 'palabra': 'sapo'},
    {'emoji': '6️⃣', 'palabra': 'seis'},
    {'emoji': '🍲', 'palabra': 'sopa'},
  ];

  // Palabras a la derecha, en el orden revuelto del cuadernillo.
  final List<String> _palabras = const ['suéter', 'seis', 'sopa', 'silla', 'sapo'];

  final List<Color> _paleta = const [
    Color(0xFFA9D3E5),
    Color(0xFFC3D9A0),
    Color(0xFFF3B8C7),
    Color(0xFFF3B68A),
    Color(0xFFF6E27A),
  ];

  int? _seleccionImagen;
  int? _shakeIndex;
  bool _shakeEsImagen = false;

  late List<int> _colorPorImagen;
  late List<int> _colorPorPalabra;

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

    _colorPorImagen = List<int>.filled(_imagenes.length, -1);
    _colorPorPalabra = List<int>.filled(_palabras.length, -1);
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

  void _tocarImagen(int index) {
    if (_colorPorImagen[index] != -1) return;
    setState(() => _seleccionImagen = index);
    _hablar(_imagenes[index]['palabra']!);
  }

  void _tocarPalabra(int indexPalabra) {
    if (_colorPorPalabra[indexPalabra] != -1) return;
    if (_seleccionImagen == null) return;

    final indexImg = _seleccionImagen!;
    final correcto =
        _imagenes[indexImg]['palabra'] == _palabras[indexPalabra];

    _hablar(_palabras[indexPalabra]);

    if (correcto) {
      final colorIndex = _colorPorImagen.where((c) => c != -1).length;
      setState(() {
        _colorPorImagen[indexImg] = colorIndex;
        _colorPorPalabra[indexPalabra] = colorIndex;
        _seleccionImagen = null;
      });
    } else {
      setState(() {
        _shakeIndex = indexPalabra;
        _shakeEsImagen = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shakeIndex = null;
            _seleccionImagen = null;
          });
        }
      });
    }
  }

  void _reiniciar() {
    setState(() {
      _colorPorImagen = List<int>.filled(_imagenes.length, -1);
      _colorPorPalabra = List<int>.filled(_palabras.length, -1);
      _seleccionImagen = null;
    });
  }

  bool get _completo => _colorPorImagen.every((c) => c != -1);

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    for (int i = 0; i < _imagenes.length; i++)
                      _buildImagen(i),
                  ],
                ),
                Column(
                  children: [
                    for (int i = 0; i < _palabras.length; i++)
                      _buildPalabra(i),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_completo) _buildMensajeExito() else _buildBotonReiniciar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto =
        '11. Toca la imagen y luego toca la palabra correcta.';
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
                  fontSize: 16,
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

  Widget _buildImagen(int index) {
    final colorIndex = _colorPorImagen[index];
    final seleccionado = _seleccionImagen == index;

    Color fondo = Colors.white;
    Color borde = Colors.black12;
    if (colorIndex != -1) {
      fondo = _paleta[colorIndex % _paleta.length];
      borde = fondo;
    } else if (seleccionado) {
      fondo = const Color(0xFF3DBFDA).withOpacity(0.15);
      borde = const Color(0xFF3DBFDA);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _tocarImagen(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borde, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(_imagenes[index]['emoji']!,
              style: const TextStyle(fontSize: 38)),
        ),
      ),
    );
  }

  Widget _buildPalabra(int index) {
    final colorIndex = _colorPorPalabra[index];
    final error = !_shakeEsImagen && _shakeIndex == index;

    Color fondo = Colors.white;
    Color borde = Colors.black12;
    if (colorIndex != -1) {
      fondo = _paleta[colorIndex % _paleta.length];
      borde = fondo;
    } else if (error) {
      fondo = Colors.red.withOpacity(0.15);
      borde = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _tocarPalabra(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borde, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _palabras[index],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2A26),
            ),
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
              '¡Muy bien! Uniste todas las imágenes con su palabra.',
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