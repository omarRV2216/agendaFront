import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulefront/providers/auth_provider.dart';
import 'package:schedulefront/screens/dashboard/menu_items.dart';
import 'package:schedulefront/screens/dashboard/pages/page_2_1.dart';
import '../login.dart';
import 'pages/page_1_1.dart';
import 'pages/page_1_2.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SubMenuItem? _currentItem;
  late final List<MenuSection> _sections;

  @override
  void initState() {
    super.initState();

    _sections = [
      MenuSection(
        title: 'Citas',
        icon: Icons.folder,
        items: [
          SubMenuItem(
            title: 'Todas las citas',
            icon: Icons.insert_drive_file,
            page: const Page11(),
          ),
          SubMenuItem(
            title: 'Calendario',
            icon: Icons.insert_drive_file,
            page: const Page12(),
          ),
        ],
      ),
      MenuSection(
        title: 'Empleados',
        icon: Icons.work,
        items: [
          SubMenuItem(
            title: 'Lista de empleados',
            icon: Icons.assignment,
            page: const Page21(),
          ),
        ],
      ),
      MenuSection(
        title: 'Servicios',
        icon: Icons.work,
        items: [
          SubMenuItem(
            title: 'Catalogo',
            icon: Icons.assignment,
            page: const Page21(),
          ),
          SubMenuItem(
            title: 'Crear Servicio',
            icon: Icons.assignment,
            page: const Page21(),
          ),
        ],
      ),
    ];

    _currentItem = _sections.first.items.first;
  }

  void _selectItem(SubMenuItem item) {
    setState(() {
      _currentItem = item;
    });
  }

  /// Cierra la sesión y regresa al login
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cerrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,

        actions: [

          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  user.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: isWide ? null : _buildDrawer(isWide),
      body: isWide
          ? Row(
        children: [
          SizedBox(
            width: 280,
            child: _buildSidebar(isWide),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
        ],
      )
          : _buildContent(),
    );
  }

  Widget _buildSidebar(bool isWide) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          ..._sections.map((s) => _buildSection(s, isWide)).toList(),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isWide) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer con info del usuario
            Container(
              color: Colors.pink,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.spa, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Nail Salon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Secciones
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _sections
                    .map((s) => _buildSection(s, isWide))
                    .toList(),
              ),
            ),

            // 👇 Logout al final del drawer (opcional)
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);   // cierra el drawer
                _logout();                // luego logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(MenuSection section, bool isWide) {
    return ExpansionTile(
      leading: Icon(section.icon, color: Colors.pink),
      title: Text(
        section.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: _isSectionExpanded(section),
      children:
      section.items.map((item) => _buildSubItem(item, isWide)).toList(),
    );
  }

  bool _isSectionExpanded(MenuSection section) {
    return section.items.contains(_currentItem);
  }

  Widget _buildSubItem(SubMenuItem item, bool isWide) {
    final isSelected = _currentItem == item;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40, right: 16),
      leading: Icon(
        item.icon,
        color: isSelected ? Colors.pink : Colors.grey.shade700,
        size: 20,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected ? Colors.pink : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.pink.withOpacity(0.1) : null,
      selected: isSelected,
      selectedTileColor: Colors.pink.withOpacity(0.1),
      onTap: () {
        _selectItem(item);

        if (!isWide) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildContent() {
    if (_currentItem == null) {
      return const Center(child: Text('Selecciona una opción del menú'));
    }
    return _currentItem!.page;
  }
}