import 'package:flutter/material.dart';

/// Representa una opción de submenú (la "subsección")
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

/// Representa un grupo del menú (la "sección")
class MenuSection {
  final String title;
  final IconData icon;
  final List<SubMenuItem> items;

  MenuSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}