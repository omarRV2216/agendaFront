import 'package:flutter/material.dart';
import 'appbar/appbar.dart';
import 'home/inicio/inicio_section.dart';
import 'home/servicios/servicios_section.dart';
import 'home/contacto/contacto_section.dart';

class PortalHome extends StatefulWidget {
  const PortalHome({super.key});

  @override
  State<PortalHome> createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome> {
  final _scrollController = ScrollController();

  // Keys para cada sección
  final _inicioKey = GlobalKey();
  final _serviciosKey = GlobalKey();
  final _contactoKey = GlobalKey();

  // Sección activa (para resaltar en el AppBar)
  String _seccionActual = 'inicio';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Detectar qué sección está visible al hacer scroll
  // ──────────────────────────────────────────────
  void _onScroll() {
    final keys = {
      'inicio': _inicioKey,
      'servicios': _serviciosKey,
      'contacto': _contactoKey,
    };

    String nuevaSeccion = _seccionActual;

    for (final entry in keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final offset = box.localToGlobal(Offset.zero).dy;

      // Si la sección está cerca del top (o pasó), es la activa
      if (offset <= 200) {
        nuevaSeccion = entry.key;
      }
    }

    if (nuevaSeccion != _seccionActual) {
      setState(() => _seccionActual = nuevaSeccion);
    }
  }

  // ──────────────────────────────────────────────
  // Scroll a una sección (cuando click en AppBar)
  // ──────────────────────────────────────────────
  void _scrollASeccion(String seccion) {
    final keys = {
      'inicio': _inicioKey,
      'servicios': _serviciosKey,
      'contacto': _contactoKey,
    };

    final key = keys[seccion];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    setState(() => _seccionActual = seccion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PortalAppBar(
        seccionActual: _seccionActual,
        onSeccionSeleccionada: _scrollASeccion,   // 👈 callback
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── Sección 1: Inicio ──
            Container(
              key: _inicioKey,
              child: const InicioSection(),
            ),

            // ── Sección 2: Servicios ──
            Container(
              key: _serviciosKey,
              child: const ServiciosSection(),
            ),

            // ── Sección 3: Contacto ──
            Container(
              key: _contactoKey,
              child: const ContactoSection(),
            ),
          ],
        ),
      ),
    );
  }
}