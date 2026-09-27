import 'package:flutter/material.dart';

/// Subsección (dentro de una sección con subsecciones)
class SubMenuItem {
  final String title;
  final IconData icon;
  final Widget page;

  SubMenuItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}

/// Sección del menú.
/// - Si `page` está definido → es un item directo (sin subsecciones)
/// - Si `items` está definido → es una sección con subsecciones
class MenuSection {
  final String title;
  final IconData icon;
  final Widget? page;              // 👈 nuevo: página directa
  final List<SubMenuItem> items;   // 👈 subsecciones (vacío si es directa)

  MenuSection({
    required this.title,
    required this.icon,
    this.page,
    this.items = const [],
  });

  /// ¿Es un item directo (sin subsecciones)?
  bool get isDirect => page != null && items.isEmpty;
}