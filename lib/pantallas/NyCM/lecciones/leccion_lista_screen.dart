import 'package:flutter/material.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_16_lee_enunciados.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_17_1_que_pan.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_17_2_silabas_pa_pe_pi_po_pu.dart';
import 'package:sabia/pantallas/NyCM/lecciones/leccion_17_3_ilumina_silabas.dart';

/// ============================================================
/// LISTA DE LECCIONES — NyCM
///
/// Pantalla de menú que muestra todas las lecciones disponibles
/// del núcleo NyCM.
///
/// Hay 2 tipos de tarjeta:
///  - Lección simple (ej. 16): toca la tarjeta y navega directo.
///  - Lección con partes (ej. 17, que tiene 9 páginas): toca la
///    flecha para desplegar la lista de partes; cada parte se
///    navega por separado. Las partes que aún no tengan pantalla
///    creada se muestran como "Próximamente" y no son tocables.
///
/// Para agregar una lección nueva:
///   1. Importa su(s) archivo(s) arriba.
///   2. Agrega una entrada nueva en `_lecciones` más abajo.
///
/// Ubicación sugerida: lib/pantallas/NyCM/lecciones/leccion_lista_screen.dart
/// ============================================================

/// Representa una parte/página individual dentro de una lección larga.
/// Si `pantalla` es null, la parte todavía no está creada y se
/// muestra deshabilitada como "Próximamente".
class _ParteLeccion {
  final int numero; // 1, 2, 3...
  final String titulo;
  final Widget? pantalla;

  const _ParteLeccion({
    required this.numero,
    required this.titulo,
    this.pantalla,
  });

  bool get disponible => pantalla != null;
}

class _LeccionInfo {
  final String numero;
  final String titulo;
  final String descripcion;
  final Color color;

  /// Para lecciones simples de una sola pantalla.
  final Widget? pantalla;

  /// Para lecciones con varias partes/páginas (ej. la 17, con 9).
  final List<_ParteLeccion>? partes;

  const _LeccionInfo({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.color,
    this.pantalla,
    this.partes,
  });

  bool get tienePartes => partes != null && partes!.isNotEmpty;
}

class LeccionListaScreen extends StatefulWidget {
  const LeccionListaScreen({super.key});

  @override
  State<LeccionListaScreen> createState() => _LeccionListaScreenState();
}

class _LeccionListaScreenState extends State<LeccionListaScreen> {
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
      numero: '17',
      titulo: 'Lección 17: Aprende la letra P',
      descripcion: 'Introducción a la letra P / p. 9 actividades en total.',
      color: const Color(0xFF3DBFDA),
      partes: [
        _ParteLeccion(
          numero: 1,
          titulo: '¿Qué es? pan',
          pantalla: const Leccion17Parte1QueEsPan(),
        ),
        _ParteLeccion(
          numero: 2,
          titulo: 'Sílabas con la letra P',
          pantalla: const Leccion17_2SilabasPaPePiPoPu(),
        ),
        _ParteLeccion(
          numero: 3,
          titulo: 'Ilumina las sílabas',
          pantalla: const Leccion17_3IluminaSilabas(),
        ),
        const _ParteLeccion(numero: 4, titulo: 'Próximamente'),
        const _ParteLeccion(numero: 5, titulo: 'Próximamente'),
        const _ParteLeccion(numero: 6, titulo: 'Próximamente'),
        const _ParteLeccion(numero: 7, titulo: 'Próximamente'),
        const _ParteLeccion(numero: 8, titulo: 'Próximamente'),
        const _ParteLeccion(numero: 9, titulo: 'Próximamente'),
      ],
    ),
  ];

  // Índice de la lección actualmente desplegada (null = ninguna).
  int? _expandidoIndex;

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
            final expandido = _expandidoIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: leccion.tienePartes
                  ? _buildTarjetaConPartes(context, leccion, index, expandido)
                  : _buildTarjetaSimple(context, leccion),
            );
          },
        ),
      ),
    );
  }

  /// Tarjeta para lecciones de una sola pantalla (ej. lección 16).
  Widget _buildTarjetaSimple(BuildContext context, _LeccionInfo leccion) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => leccion.pantalla!),
        );
      },
      child: _cajaTarjeta(
        leccion: leccion,
        trailing: Icon(Icons.chevron_right, color: leccion.color),
      ),
    );
  }

  /// Tarjeta para lecciones con varias partes (ej. lección 17).
  /// Al tocar la flecha, despliega/oculta la lista de partes.
  Widget _buildTarjetaConPartes(
    BuildContext context,
    _LeccionInfo leccion,
    int index,
    bool expandido,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expandidoIndex = expandido ? null : index;
            });
          },
          child: _cajaTarjeta(
            leccion: leccion,
            trailing: Icon(
              expandido ? Icons.expand_less : Icons.expand_more,
              color: leccion.color,
            ),
          ),
        ),
        if (expandido)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: leccion.color.withOpacity(0.25)),
            ),
            child: Column(
              children: leccion.partes!
                  .map((parte) => _buildFilaParte(context, leccion, parte))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFilaParte(
    BuildContext context,
    _LeccionInfo leccion,
    _ParteLeccion parte,
  ) {
    return GestureDetector(
      onTap: parte.disponible
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => parte.pantalla!),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: parte.disponible
                    ? leccion.color.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${parte.numero}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: parte.disponible ? leccion.color : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                parte.titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: parte.disponible
                      ? const Color(0xFF2D2A26)
                      : Colors.grey,
                ),
              ),
            ),
            if (parte.disponible)
              Icon(Icons.chevron_right, size: 20, color: leccion.color)
            else
              const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Caja base compartida entre los dos tipos de tarjeta.
  Widget _cajaTarjeta({required _LeccionInfo leccion, required Widget trailing}) {
    return Container(
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
          trailing,
        ],
      ),
    );
  }
}