import 'package:flutter/material.dart';

class PortalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String seccionActual;

  /// Callback cuando el usuario elige una sección
  final void Function(String seccion)? onSeccionSeleccionada;

  const PortalAppBar({
    super.key,
    this.seccionActual = 'inicio',
    this.onSeccionSeleccionada,
  });

  /// Definición de secciones (agregar aquí las nuevas)
  static const List<({String label, String value})> _secciones = [
    (label: 'Inicio',    value: 'inicio'),
    (label: 'Servicios', value: 'servicios'),
    (label: 'Contacto',  value: 'contacto'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.spa, color: Colors.pink, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Nail Salon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: isWide
          ? [
        _buildSeccionesDesktop(context),
      ]
          : [
        _buildMenuHamburguesa(context),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Secciones (desktop)
  // ──────────────────────────────────────────────
  Widget _buildSeccionesDesktop(BuildContext context) {
    return Row(
      children: _secciones.map((s) => _buildSeccion(s)).toList(),
    );
  }

  Widget _buildSeccion(({String label, String value}) seccion) {
    final activo = seccionActual == seccion.value;

    return InkWell(
      onTap: () => onSeccionSeleccionada?.call(seccion.value),   // 👈 callback
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? Colors.pink.shade50 : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          seccion.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
            color: activo ? Colors.pink : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Menú hamburguesa (móvil/tablet)
  // ──────────────────────────────────────────────
  Widget _buildMenuHamburguesa(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.black87),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'login') {
          // TODO
          return;
        }
        onSeccionSeleccionada?.call(value);   // 👈 callback
      },
      itemBuilder: (_) => [
        ..._secciones.map((s) {
          return PopupMenuItem<String>(
            value: s.value,
            child: Row(
              children: [
                Icon(_iconoDeSeccion(s.value), size: 18),
                const SizedBox(width: 8),
                Text(s.label),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _iconoDeSeccion(String value) {
    switch (value) {
      case 'inicio':    return Icons.home_outlined;
      case 'servicios': return Icons.spa_outlined;
      case 'contacto':  return Icons.contact_mail_outlined;
      default:          return Icons.circle_outlined;
    }
  }
}