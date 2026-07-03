import 'package:flutter/material.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_16_lee_enunciados.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_17_1_que_pan.dart';

/// ============================================================
/// LISTA DE LECCIONES — NyCM
///
/// Pantalla de menú que muestra todas las lecciones disponibles
/// del núcleo NyCM. Al agregar una lección nueva (18, 19, ...),
/// solo hay que:
///   1. Importarla arriba.
///   2. Agregar una entrada nueva en `_lecciones` más abajo.
///
/// Ubicación sugerida: lib/pantallas/NyCM/lecciones/leccion_lista_screen.dart
/// ============================================================

class _LeccionInfo {
  final String numero;
  final String titulo;
  final String descripcion;
  final Color color;
  final Widget pantalla;

  const _LeccionInfo({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.pantalla,
  });
}

class LeccionListaScreen extends StatelessWidget {
  const LeccionListaScreen({super.key});

  // Agrega aquí cada lección nueva que vayas creando.
  static final List<_LeccionInfo> _lecciones = [
    _LeccionInfo(
      numero: '16',
      titulo: 'Lee enunciados',
      descripcion:
          'Lee en voz alta los siguientes enunciados y menciona cuántas palabras los forman.',
      color: const Color(0xFF6FA8C9),
      pantalla: const Leccion16LeeEnunciados(),
    ),
    _LeccionInfo(
      numero: '17.1',
      titulo: '¿Qué es? pan',
      descripcion: 'Introducción a la letra P / p. Traza y encuentra la /p/. (1 de 9)',
      color: const Color(0xFF3DBFDA),
      pantalla: const Leccion17Parte1QueEsPan(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Lecciones'),
        backgroundColor: const Color(0xFF134074),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _lecciones.length,
          itemBuilder: (context, index) {
            final leccion = _lecciones[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTarjetaLeccion(context, leccion),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTarjetaLeccion(BuildContext context, _LeccionInfo leccion) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => leccion.pantalla),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: leccion.color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: leccion.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                leccion.numero,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leccion.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2A26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leccion.descripcion,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: leccion.color),
          ],
        ),
      ),
    );
  }
}