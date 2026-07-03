import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN 17 (parte 3 de 9) — Sílabas con la letra P
///
///   5. Ilumina cada sílaba con el color que le corresponda.
///   6. Lee en voz alta.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_17_3_ilumina_silabas.dart
/// ============================================================

class Leccion17_3IluminaSilabas extends StatefulWidget {
  const Leccion17_3IluminaSilabas({super.key});

  @override
  State<Leccion17_3IluminaSilabas> createState() =>
      _Leccion17_3IluminaSilabasState();
}

class _Leccion17_3IluminaSilabasState
    extends State<Leccion17_3IluminaSilabas> {
  late final FlutterTts _tts;
  bool _hablando = false;

  // ---------- Actividad 5: clave de colores ----------
  final Map<String, Color> _clave = const {
    'pa': Color(0xFFF6E45A), // amarillo
    'pe': Color(0xFFE8A33D), // mostaza / naranja
    'pi': Color(0xFFF3A18E), // coral / salmón
    'po': Color(0xFFA9D3E5), // azul
    'pu': Color(0xFFA9D48C), // verde
  };

  // Cuadrícula de sílabas a iluminar (incluye distractores que no
  // pertenecen a la clave, como en el cuadernillo).
  final List<List<String>> _cuadricula = const [
    ['po', 'sa', 'pu', 'pa', 'lo'],
    ['le', 'pa', 'li', 'po', 'so'],
    ['pu', 'lu', 'pi', 'su', 'pe'],
    ['pi', 'si', 'pe', 'la', 'se'],
  ];

  // Estado de cada celda: color aplicado (null = sin iluminar).
  late List<List<Color?>> _coloreado;
  int _aciertos = 0;
  int _intentos = 0;
  late int _totalCorrectas;

  // ---------- Actividad 6: leer en voz alta ----------
  final List<String> _silabasLectura = const [
    'pi', 'pa', 'la', 'po', 'pe', 'pu', 'le'
  ];
  int? _silabaLeyendo;

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

    _coloreado = _cuadricula
        .map((fila) => List<Color?>.filled(fila.length, null))
        .toList();

    _totalCorrectas = _cuadricula
        .expand((fila) => fila)
        .where((s) => _clave.containsKey(s))
        .length;
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

  // -------------------- Lógica actividad 5 --------------------

  void _tocarCelda(int fila, int col) {
    final silaba = _cuadricula[fila][col];
    if (_coloreado[fila][col] != null) return; // ya resuelta

    setState(() => _intentos++);

    if (_clave.containsKey(silaba)) {
      setState(() {
        _coloreado[fila][col] = _clave[silaba];
        _aciertos++;
      });
      _hablar(silaba);
    } else {
      _hablar('$silaba no lleva color. Intenta con otra.');
      // Breve destello rojo de "incorrecto" sin dejarlo pintado.
      setState(() => _coloreado[fila][col] = Colors.red.withOpacity(0.25));
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _coloreado[fila][col] = null);
        }
      });
    }
  }

  void _reiniciarIluminar() {
    setState(() {
      _coloreado = _cuadricula
          .map((fila) => List<Color?>.filled(fila.length, null))
          .toList();
      _aciertos = 0;
      _intentos = 0;
    });
  }

  // -------------------- Lógica actividad 6 --------------------

  Future<void> _leerSilaba(int index) async {
    setState(() => _silabaLeyendo = index);
    await _hablar(_silabasLectura[index]);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _silabaLeyendo = null);
  }

  Future<void> _leerTodas() async {
    for (int i = 0; i < _silabasLectura.length; i++) {
      if (!mounted) return;
      setState(() => _silabaLeyendo = i);
      await _tts.stop();
      await _tts.speak(_silabasLectura[i]);
      await Future.delayed(const Duration(milliseconds: 750));
    }
    if (mounted) setState(() => _silabaLeyendo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Lección 17 (3/9)'),
        backgroundColor: const Color(0xFF3DBFDA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildActividad5(),
            const SizedBox(height: 28),
            _buildActividad6(),
          ],
        ),
      ),
    );
  }

  // -------------------- UI actividad 5 --------------------

  Widget _buildActividad5() {
    const instruccion = '5. Ilumina cada sílaba con el color que le corresponda.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 16),
          // Clave de colores (círculos de referencia, igual al cuadernillo).
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _clave.entries.map((e) {
              return GestureDetector(
                onTap: () => _hablar(e.key),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: e.value,
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2A26),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Cuadrícula de sílabas a iluminar.
          for (int f = 0; f < _cuadricula.length; f++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_cuadricula[f].length, (c) {
                  final silaba = _cuadricula[f][c];
                  final color = _coloreado[f][c];
                  return GestureDetector(
                    onTap: () => _tocarCelda(f, c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color ?? Colors.white,
                        border: Border.all(color: Colors.black45, width: 1.5),
                      ),
                      child: Text(
                        silaba,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intentos: $_intentos',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                'Iluminadas: $_aciertos / $_totalCorrectas',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3DBFDA),
                ),
              ),
            ],
          ),
          if (_aciertos == _totalCorrectas) ...[
            const SizedBox(height: 10),
            _buildMensajeExito('¡Iluminaste todas las sílabas correctas!'),
          ],
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _reiniciarIluminar,
              icon: const Icon(Icons.replay),
              label: const Text('Reiniciar actividad'),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- UI actividad 6 --------------------

  Widget _buildActividad6() {
    const instruccion = '6. Lee en voz alta.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_silabasLectura.length, (i) {
              final activa = _silabaLeyendo == i;
              // Alterna colores como en el cuadernillo (mostaza / durazno claro).
              final colorBase =
                  i.isEven ? const Color(0xFFE8A33D) : const Color(0xFFF3D9A8);
              return GestureDetector(
                onTap: () => _leerSilaba(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: activa ? const Color(0xFF3DBFDA) : colorBase,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _silabasLectura[i],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: activa ? Colors.white : const Color(0xFF2D2A26),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _leerTodas,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Leer todas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DBFDA),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
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

  Widget _buildMensajeExito(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7BC98C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFF3C9A50)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Color(0xFF2E7A3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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