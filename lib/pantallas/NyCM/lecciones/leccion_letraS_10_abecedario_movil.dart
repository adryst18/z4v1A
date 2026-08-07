import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// LECCIÓN "Aprendiendo la letra S" — Actividad 10
/// "Escribe con tu abecedario móvil las siguientes palabras."
///
/// "sopa" se muestra ya resuelta como ejemplo (igual que en el
/// cuadernillo). Las otras 4 palabras (silla, suéter, seis,
/// sapo) el niño las arma tocando las letras revueltas en el
/// orden correcto para llenar los cuadros vacíos.
///
/// Ubicación sugerida:
///   lib/pantallas/NyCM/lecciones/leccion_letraS_10_abecedario_movil.dart
///
/// Requiere en pubspec.yaml:
///   dependencies:
///     flutter_tts: ^4.0.2
/// ============================================================

class _EstadoPalabra {
  final String palabra;
  late final List<String> letras;
  late final List<String> fichas; // letras revueltas
  late List<String?> colocado;
  late List<bool> fichaUsada;
  int? fichaError;

  _EstadoPalabra(this.palabra) {
    letras = palabra.split('');
    fichas = List<String>.from(letras)..shuffle();
    colocado = List<String?>.filled(letras.length, null);
    fichaUsada = List<bool>.filled(fichas.length, false);
  }

  bool get completa => !colocado.contains(null);

  void reiniciar() {
    fichas.shuffle();
    colocado = List<String?>.filled(letras.length, null);
    fichaUsada = List<bool>.filled(fichas.length, false);
    fichaError = null;
  }
}

class LeccionS10AbecedarioMovil extends StatefulWidget {
  const LeccionS10AbecedarioMovil({super.key});

  @override
  State<LeccionS10AbecedarioMovil> createState() =>
      _LeccionS10AbecedarioMovilState();
}

class _LeccionS10AbecedarioMovilState
    extends State<LeccionS10AbecedarioMovil> {
  late final FlutterTts _tts;

  late final List<_EstadoPalabra> _palabras;
  bool _hablando = false;

  static const Color _colorPastilla = Color(0xFFC3D9A0); // verde clarito

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

    _palabras = [
      _EstadoPalabra('silla'),
      _EstadoPalabra('suéter'),
      _EstadoPalabra('seis'),
      _EstadoPalabra('sapo'),
    ];
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

  void _tocarFicha(_EstadoPalabra estado, int fichaIndex) {
    if (estado.fichaUsada[fichaIndex]) return;
    final posVacia = estado.colocado.indexOf(null);
    if (posVacia == -1) return;

    final letraFicha = estado.fichas[fichaIndex];
    final letraEsperada = estado.letras[posVacia];

    if (letraFicha == letraEsperada) {
      setState(() {
        estado.colocado[posVacia] = letraFicha;
        estado.fichaUsada[fichaIndex] = true;
      });
      _hablar(letraFicha);
      if (estado.completa) _hablar(estado.palabra);
    } else {
      setState(() => estado.fichaError = fichaIndex);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => estado.fichaError = null);
      });
    }
  }

  void _reiniciarPalabra(_EstadoPalabra estado) {
    setState(() => estado.reiniciar());
  }

  bool get _todoCompleto => _palabras.every((p) => p.completa);

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
            _buildEjemplo(),
            const SizedBox(height: 28),
            for (final estado in _palabras) ...[
              _buildBloquePalabra(estado),
              const SizedBox(height: 26),
            ],
            if (_todoCompleto) _buildMensajeExito(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicacion() {
    const texto =
        '10. Escribe con tu abecedario móvil las siguientes palabras.';
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

  /// "sopa" ya resuelta, solo de referencia (no interactiva).
  Widget _buildEjemplo() {
    const letras = ['s', 'o', 'p', 'a'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ejemplo:',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _colorPastilla,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'sopa',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final letra in letras)
              Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.only(right: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.withOpacity(0.08),
                ),
                child: Text(
                  letra,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBloquePalabra(_EstadoPalabra estado) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estado.completa ? Colors.green : Colors.black12,
          width: estado.completa ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _hablar(estado.palabra),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _colorPastilla,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado.palabra,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (estado.completa)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: const Color(0xFF3DBFDA),
                  tooltip: 'Reiniciar palabra',
                  onPressed: () => _reiniciarPalabra(estado),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Cuadros de destino.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < estado.letras.length; i++)
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: estado.colocado[i] != null
                          ? Colors.green
                          : Colors.black45,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: estado.colocado[i] != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Text(
                    estado.colocado[i] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Fichas revueltas para tocar en orden.
          if (!estado.completa)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < estado.fichas.length; i++)
                  _buildFicha(estado, i),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFicha(_EstadoPalabra estado, int index) {
    final usada = estado.fichaUsada[index];
    final error = estado.fichaError == index;

    if (usada) {
      return const SizedBox(width: 40, height: 40);
    }

    return GestureDetector(
      onTap: () => _tocarFicha(estado, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: error ? Colors.red.withOpacity(0.3) : const Color(0xFFF6E27A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: error ? Colors.red : Colors.black26),
        ),
        child: Text(
          estado.fichas[index],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
              '¡Excelente! Armaste todas las palabras.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}