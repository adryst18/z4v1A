import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN 17 (parte 2 de 9) — Sílabas con la letra P
///
///   3. Pega debajo la sílaba que corresponda.
///   4. Une con una línea las sílabas que correspondan.
///
/// NOTA: la actividad 3 en el cuadernillo original probablemente
/// tiene una imagen guía arriba de cada casilla (no visible en el
/// recorte). Aquí se digitalizó como "ordena las sílabas en orden
/// alfabético de la vocal (pa, pe, pi, po, pu)". Si la versión
/// impresa usa otro criterio de orden, dime cuál es el orden
/// correcto de las casillas y ajusto la lista `_ordenCorrecto`.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_17_2_silabas_pa_pe_pi_po_pu.dart
/// ============================================================

class Leccion17_2SilabasPaPePiPoPu extends StatefulWidget {
  const Leccion17_2SilabasPaPePiPoPu({super.key});

  @override
  State<Leccion17_2SilabasPaPePiPoPu> createState() =>
      _Leccion17_2SilabasPaPePiPoPuState();
}

class _Leccion17_2SilabasPaPePiPoPuState
    extends State<Leccion17_2SilabasPaPePiPoPu> {
  late final FlutterTts _tts;
  bool _hablando = false;

  // ---------- Actividad 3: ordenar sílabas ----------
  final List<String> _silabasDisponibles = ['pe', 'pa', 'pi', 'pu', 'po'];
  final List<String> _ordenCorrecto = ['pa', 'pe', 'pi', 'po', 'pu'];

  // Casillas destino: null = vacía, si no, contiene la sílaba colocada.
  late List<String?> _casillas;
  String? _silabaSeleccionada;
  int _intentosOrden = 0;
  bool? _resultadoOrden; // null = sin verificar

  // ---------- Actividad 4: unir con línea ----------
  final List<String> _columnaIzquierda = ['PI', 'PA', 'PE', 'PU', 'PO'];
  final List<String> _columnaDerecha = ['pe', 'pi', 'pa', 'po', 'pu'];

  // Índice izquierdo seleccionado en espera de pareja.
  int? _izqSeleccionado;
  // Mapa: índice izquierdo -> índice derecho ya conectado correctamente.
  final Map<int, int> _conexionesCorrectas = {};
  int _intentosUnir = 0;

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

    _casillas = List<String?>.filled(5, null);
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

  // -------------------- Lógica actividad 3 --------------------

  void _seleccionarSilaba(String silaba) {
    _hablar(silaba);
    setState(() {
      _silabaSeleccionada = silaba;
    });
  }

  void _colocarEnCasilla(int index) {
    if (_silabaSeleccionada == null) return;
    if (_casillas[index] != null) return; // ya ocupada

    setState(() {
      _casillas[index] = _silabaSeleccionada;
      _silabasDisponibles.remove(_silabaSeleccionada);
      _silabaSeleccionada = null;
      _resultadoOrden = null;
    });
  }

  void _quitarDeCasilla(int index) {
    if (_casillas[index] == null) return;
    setState(() {
      _silabasDisponibles.add(_casillas[index]!);
      _casillas[index] = null;
      _resultadoOrden = null;
    });
  }

  void _verificarOrden() {
    setState(() {
      _intentosOrden++;
      _resultadoOrden =
          _casillas.every((s) => s != null) && _listasIguales(_casillas.cast<String>(), _ordenCorrecto);
    });
    _hablar(_resultadoOrden == true
        ? '¡Muy bien! El orden es correcto.'
        : 'Todavía no. Sigue intentando.');
  }

  bool _listasIguales(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _reiniciarOrden() {
    setState(() {
      _casillas = List<String?>.filled(5, null);
      _silabasDisponibles
        ..clear()
        ..addAll(['pe', 'pa', 'pi', 'pu', 'po']);
      _silabaSeleccionada = null;
      _intentosOrden = 0;
      _resultadoOrden = null;
    });
  }

  // -------------------- Lógica actividad 4 --------------------

  void _tocarIzquierda(int index) {
    _hablar(_columnaIzquierda[index].toLowerCase());
    setState(() => _izqSeleccionado = index);
  }

  void _tocarDerecha(int index) {
    if (_izqSeleccionado == null) return;
    final palabraIzq = _columnaIzquierda[_izqSeleccionado!].toLowerCase();
    final palabraDer = _columnaDerecha[index];

    setState(() => _intentosUnir++);

    if (palabraIzq == palabraDer) {
      setState(() {
        _conexionesCorrectas[_izqSeleccionado!] = index;
        _izqSeleccionado = null;
      });
      _hablar('¡Correcto! $palabraDer');
    } else {
      _hablar('Esa no es la pareja. Intenta de nuevo.');
      setState(() => _izqSeleccionado = null);
    }
  }

  void _reiniciarUnir() {
    setState(() {
      _conexionesCorrectas.clear();
      _izqSeleccionado = null;
      _intentosUnir = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Lección 17 (2/9)'),
        backgroundColor: const Color(0xFF3DBFDA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildActividad3(),
            const SizedBox(height: 28),
            _buildActividad4(),
          ],
        ),
      ),
    );
  }

  // -------------------- UI actividad 3 --------------------

  Widget _buildActividad3() {
    const instruccion = '3. Pega debajo la sílaba que corresponda.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 6),
          const Text(
            'Toca una sílaba y luego toca la casilla donde va.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // Sílabas disponibles (tiles amarillos, igual al cuadernillo).
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _silabasDisponibles.map((s) {
              final seleccionada = _silabaSeleccionada == s;
              return GestureDetector(
                onTap: () => _seleccionarSilaba(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? const Color(0xFFF2C14E)
                        : const Color(0xFFF6E27A),
                    borderRadius: BorderRadius.circular(10),
                    border: seleccionada
                        ? Border.all(color: const Color(0xFFB8860B), width: 2)
                        : null,
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          // Casillas destino.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) => _buildCasilla(i)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intentos: $_intentosOrden',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _reiniciarOrden,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reiniciar'),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: _verificarOrden,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3DBFDA),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verificar'),
                  ),
                ],
              ),
            ],
          ),
          if (_resultadoOrden != null) ...[
            const SizedBox(height: 10),
            _buildMensajeResultado(_resultadoOrden!),
          ],
        ],
      ),
    );
  }

  Widget _buildCasilla(int index) {
    final contenido = _casillas[index];
    return GestureDetector(
      onTap: () {
        if (contenido == null) {
          _colocarEnCasilla(index);
        } else {
          _quitarDeCasilla(index);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: contenido != null
                ? const Color(0xFF3DBFDA)
                : Colors.black38,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          contenido ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // -------------------- UI actividad 4 --------------------

  Widget _buildActividad4() {
    const instruccion = '4. Une con una línea las sílabas que correspondan.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstruccionConAudio(instruccion),
          const SizedBox(height: 6),
          const Text(
            'Toca una sílaba mayúscula y luego su pareja en minúscula.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPalabraUnion(
                      texto: _columnaIzquierda[i],
                      seleccionada: _izqSeleccionado == i,
                      conectada: _conexionesCorrectas.containsKey(i),
                      onTap: () => _tocarIzquierda(i),
                    ),
                    Expanded(
                      child: Icon(
                        _conexionesCorrectas.containsKey(i)
                            ? Icons.trending_flat
                            : Icons.remove,
                        color: _conexionesCorrectas.containsKey(i)
                            ? const Color(0xFF3C9A50)
                            : Colors.black26,
                      ),
                    ),
                    _buildPalabraUnion(
                      texto: _columnaDerecha[i],
                      seleccionada: false,
                      conectada: _conexionesCorrectas.containsValue(i),
                      onTap: () => _tocarDerecha(i),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intentos: $_intentosUnir',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                'Conectadas: ${_conexionesCorrectas.length} / 5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3DBFDA),
                ),
              ),
            ],
          ),
          if (_conexionesCorrectas.length == 5) ...[
            const SizedBox(height: 10),
            _buildMensajeResultado(true, texto: '¡Uniste todas las parejas!'),
          ],
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _reiniciarUnir,
              icon: const Icon(Icons.replay),
              label: const Text('Reiniciar actividad'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalabraUnion({
    required String texto,
    required bool seleccionada,
    required bool conectada,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: conectada
              ? const Color(0xFFDFF5E1)
              : seleccionada
                  ? const Color(0xFFBEE9F2)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: conectada
                ? const Color(0xFF3C9A50)
                : seleccionada
                    ? const Color(0xFF3DBFDA)
                    : Colors.black26,
            width: 2,
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
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

  Widget _buildMensajeResultado(bool correcto, {String? texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: correcto ? const Color(0xFFDFF5E1) : const Color(0xFFFBE4E4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: correcto ? const Color(0xFF7BC98C) : const Color(0xFFE39A9A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            correcto ? Icons.emoji_events : Icons.info_outline,
            color: correcto ? const Color(0xFF3C9A50) : const Color(0xFFB94A4A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto ??
                  (correcto
                      ? '¡Muy bien! El orden es correcto.'
                      : 'Todavía no es correcto, sigue intentando.'),
              style: TextStyle(
                color: correcto
                    ? const Color(0xFF2E7A3D)
                    : const Color(0xFF8A3B3B),
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