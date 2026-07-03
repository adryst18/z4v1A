import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN 17 (parte 4 de 9) — Palabras con la letra P
///
///   7. Nombra las imágenes y lee las palabras.
///   8. Pega debajo la palabra que corresponda.
///
/// NOTA: se usan emojis como marcador visual de las imágenes
/// (pelota, popote, papa, pila, puerta) porque el cuadernillo
/// original trae ilustraciones a color que no forman parte de
/// este código. Si tienes esas imágenes como archivos, dime y
/// las reemplazamos fácilmente por Image.asset('...') en lugar
/// del emoji — solo pásamelas y las agrego a /assets.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_17_4_nombra_imagenes.dart
/// ============================================================

class Leccion17_4NombraImagenes extends StatefulWidget {
  const Leccion17_4NombraImagenes({super.key});

  @override
  State<Leccion17_4NombraImagenes> createState() =>
      _Leccion17_4NombraImagenesState();
}

class _Leccion17_4NombraImagenesState
    extends State<Leccion17_4NombraImagenes> {
  late final FlutterTts _tts;
  bool _hablando = false;

  // ---------- Actividad 7: nombra las imágenes ----------
  final List<_Imagen> _imagenes = const [
    _Imagen(emoji: '🏐', palabra: 'pelota'),
    _Imagen(emoji: '🥤', palabra: 'popote'),
    _Imagen(emoji: '🥔', palabra: 'papa'),
    _Imagen(emoji: '🔋', palabra: 'pila'),
    _Imagen(emoji: '🚪', palabra: 'puerta'),
  ];

  // ---------- Actividad 8: pega la palabra que corresponde ----------
  // Mismas 5 palabras; cada tile de arriba corresponde, por posición,
  // a la casilla de abajo en el mismo índice (igual que en el
  // cuadernillo, donde la palabra ya está arriba de su casilla).
  final List<String> _palabras = const [
    'pila', 'pelota', 'popote', 'puerta', 'papa'
  ];

  int? _tileSeleccionado;
  late List<bool> _casillaResuelta;
  int _intentos = 0;

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

    _casillaResuelta = List<bool>.filled(_palabras.length, false);
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

  // -------------------- Lógica actividad 8 --------------------

  void _tocarTile(int index) {
    if (_casillaResuelta[index]) return;
    _hablar(_palabras[index]);
    setState(() => _tileSeleccionado = index);
  }

  void _tocarCasilla(int index) {
    if (_tileSeleccionado == null || _casillaResuelta[index]) return;

    setState(() => _intentos++);

    if (_tileSeleccionado == index) {
      setState(() {
        _casillaResuelta[index] = true;
        _tileSeleccionado = null;
      });
      _hablar('¡Correcto! ${_palabras[index]}');
    } else {
      _hablar('Esa no va ahí. Intenta de nuevo.');
      setState(() => _tileSeleccionado = null);
    }
  }

  void _reiniciar() {
    setState(() {
      _casillaResuelta = List<bool>.filled(_palabras.length, false);
      _tileSeleccionado = null;
      _intentos = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completado = _casillaResuelta.every((r) => r);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Lección 17 (4/9)'),
        backgroundColor: const Color(0xFF3DBFDA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildActividad7(),
            const SizedBox(height: 28),
            _buildActividad8(completado),
          ],
        ),
      ),
    );
  }

  // -------------------- UI actividad 7 --------------------

  Widget _buildActividad7() {
    const instruccion = '7. Nombra las imágenes y lee las palabras.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
            children: _imagenes.map((img) => _buildTarjetaImagen(img)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaImagen(_Imagen img) {
    return GestureDetector(
      onTap: () => _hablar(img.palabra),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3FBFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBEE9F2)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(img.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  img.palabra,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.volume_up_outlined,
                  size: 16,
                  color: Color(0xFF3DBFDA),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- UI actividad 8 --------------------

  Widget _buildActividad8(bool completado) {
    const instruccion = '8. Pega debajo la palabra que corresponda.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 6),
          const Text(
            'Toca una palabra y luego toca la casilla que va debajo.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: List.generate(_palabras.length, (i) {
              return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    _buildPalabraTile(i),
                    const SizedBox(height: 8),
                    _buildCasillaVacia(i),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intentos: $_intentos',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                'Colocadas: ${_casillaResuelta.where((r) => r).length} / ${_palabras.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3DBFDA),
                ),
              ),
            ],
          ),
          if (completado) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7BC98C)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFF3C9A50)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Muy bien! Colocaste todas las palabras.',
                      style: TextStyle(
                        color: Color(0xFF2E7A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _reiniciar,
              icon: const Icon(Icons.replay),
              label: const Text('Reiniciar actividad'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalabraTile(int index) {
    final resuelto = _casillaResuelta[index];
    final seleccionado = _tileSeleccionado == index;

    return GestureDetector(
      onTap: () => _tocarTile(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: resuelto
              ? const Color(0xFFDFF5E1)
              : seleccionado
                  ? const Color(0xFF3DBFDA)
                  : const Color(0xFFA9D3E5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _palabras[index],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: resuelto
                ? const Color(0xFF2E7A3D)
                : seleccionado
                    ? Colors.white
                    : const Color(0xFF2D2A26),
          ),
        ),
      ),
    );
  }

  Widget _buildCasillaVacia(int index) {
    final resuelto = _casillaResuelta[index];
    return GestureDetector(
      onTap: () => _tocarCasilla(index),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: resuelto ? const Color(0xFF3C9A50) : Colors.black38,
            width: 2,
          ),
        ),
        child: resuelto
            ? Text(
                _palabras[index],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7A3D),
                ),
              )
            : null,
      ),
    );
  }

  // -------------------- Widgets compartidos --------------------

  Widget _buildInstruccionConAudio(String texto) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: Icon(_hablando ? Icons.volume_up : Icons.volume_up_outlined),
          color: const Color(0xFF3DBFDA),
          onPressed: () => _hablar(texto),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _Imagen {
  final String emoji;
  final String palabra;

  const _Imagen({required this.emoji, required this.palabra});
}