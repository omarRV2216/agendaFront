import 'package:flutter/material.dart';

/// AppBar reutilizable para el portal público.
///
/// Uso:
/// ```dart
/// Scaffold(
///   appBar: PortalAppBar(
///     seccionActual: 'inicio',   // 'inicio' | 'servicios' | 'contacto'
///   ),
///   body: ...,
/// )
/// ```
class PortalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String seccionActual;

  const PortalAppBar({
    super.key,
    this.seccionActual = 'inicio',
  });

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

      // ── Logo / marca ──
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

      // ── Secciones ──
      actions: isWide
          ? [
        _buildSecciones(context),
        const SizedBox(width: 20),
        _buildBotonLogin(context),
        const SizedBox(width: 20),
      ]
          : [
        _buildMenuHamburguesa(context),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Secciones (desktop)
  // ──────────────────────────────────────────────
  Widget _buildSecciones(BuildContext context) {
    return Row(
      children: [
        _buildSeccion(
          context,
          label: 'Inicio',
          value: 'inicio',
          onTap: () => Navigator.pushNamed(context, '/mipagina'),
        ),
        _buildSeccion(
          context,
          label: 'Servicios',
          value: 'servicios',
          onTap: () {
            // TODO: navegar a la sección de servicios
          },
        ),
        _buildSeccion(
          context,
          label: 'Contacto',
          value: 'contacto',
          onTap: () {
            // TODO: navegar a la sección de contacto
          },
        ),
      ],
    );
  }

  Widget _buildSeccion(
      BuildContext context, {
        required String label,
        required String value,
        required VoidCallback onTap,
      }) {
    final activo = seccionActual == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? Colors.pink.shade50 : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
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
  // Botón login (desktop)
  // ──────────────────────────────────────────────
  Widget _buildBotonLogin(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      icon: const Icon(Icons.login, size: 16),
      label: const Text('Iniciar sesión'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.pink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        switch (value) {
          case 'inicio':
            Navigator.pushNamed(context, '/mipagina');
            break;
          case 'servicios':
          // TODO
            break;
          case 'contacto':
          // TODO
            break;
          case 'login':
            Navigator.pushNamed(context, '/login');
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'inicio',
          child: Row(
            children: [
              Icon(Icons.home, size: 18),
              SizedBox(width: 8),
              Text('Inicio'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'servicios',
          child: Row(
            children: [
              Icon(Icons.spa, size: 18),
              SizedBox(width: 8),
              Text('Servicios'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'contacto',
          child: Row(
            children: [
              Icon(Icons.contact_mail, size: 18),
              SizedBox(width: 8),
              Text('Contacto'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login, size: 18, color: Colors.pink),
              SizedBox(width: 8),
              Text('Iniciar sesión', style: TextStyle(color: Colors.pink)),
            ],
          ),
        ),
      ],
    );
  }
}