import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulefront/providers/auth_provider.dart';
import 'package:schedulefront/screens/dashboard/menu_items.dart';
import 'package:schedulefront/screens/dashboard/pages/citas/citas_lista.dart';
import 'package:schedulefront/screens/dashboard/pages/empleados/Empleados.dart';
import 'package:schedulefront/screens/dashboard/pages/servicios/servicios_lista.dart';
import 'package:schedulefront/screens/dashboard/pages/setting/business_config_page.dart';
import 'package:schedulefront/screens/dashboard/pages/welcome/welcome_home.dart';
import '../login.dart';
import 'pages/page_1_1.dart';
import 'pages/page_1_2.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Object? _currentItem;

  late final List<MenuSection> _sections;

  @override
  void initState() {
    super.initState();

    _sections = [
      MenuSection(
        title: 'Home',
        icon: Icons.home,
        page: const WelcomeHome(),
      ),

      MenuSection(
        title: 'Citas',
        icon: Icons.calendar_today,
        items: [
          SubMenuItem(
            title: 'Todas las citas',
            icon: Icons.list,
            page: const CitasListaPage(),
          ),
          SubMenuItem(
            title: 'Calendario',
            icon: Icons.calendar_month,
            page: const Page12(),
          ),
        ],
      ),

      MenuSection(
        title: 'Empleados',
        icon: Icons.people,
        items: [
          SubMenuItem(
            title: 'Lista de empleados',
            icon: Icons.assignment,
            page: const EmpleadosPage(),
          ),
        ],
      ),

      MenuSection(
        title: 'Servicios',
        icon: Icons.spa,
        items: [
          SubMenuItem(
            title: 'Lista de Servicios',
            icon: Icons.list,
            page: const ServiciosListaPage(),
          ),
          SubMenuItem(
            title: 'Crear servicio',
            icon: Icons.add,
            page: const EmpleadosPage(),
          ),
        ],
      ),

      MenuSection(
        title: 'Configuración',
        icon: Icons.settings,
        items: [
          SubMenuItem(
            title: 'Lista de Servicios',
            icon: Icons.list,
            page: const BusinessConfigPage(),
          ),
        ],
      ),
    ];

    _currentItem = _sections.first;
  }

  Widget _getCurrentPage() {
    final item = _currentItem;

    if (item == null) {
      return const Center(child: Text('Selecciona una opción'));
    }

    if (item is MenuSection && item.isDirect) {
      return item.page!;
    }

    if (item is SubMenuItem) {
      return item.page;
    }

    if (item is MenuSection && item.items.isNotEmpty) {
      return item.items.first.page;
    }

    return const Center(child: Text('Selecciona una opción'));
  }

  bool _isSelected(Object item) {
    return _currentItem == item;
  }

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
    final user = context.watch<AuthProvider>().user;

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
                child: Text(user.name, style: const TextStyle(fontSize: 14)),
              ),
            ),
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
          SizedBox(width: 280, child: _buildSidebar(isWide)),
          const VerticalDivider(width: 1),
          Expanded(child: _getCurrentPage()),
        ],
      )
          : _getCurrentPage(),
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
            Container(
              color: Colors.pink,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.spa, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children:
                _sections.map((s) => _buildSection(s, isWide)).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una sección (ExpansionTile si tiene subsecciones, ListTile si es directa)
  Widget _buildSection(MenuSection section, bool isWide) {
    if (section.isDirect) {
      final isSelected = _isSelected(section);

      return ListTile(
        leading: Icon(
          section.icon,
          color: isSelected ? Colors.pink : Colors.grey.shade700,
        ),
        title: Text(
          section.title,
          style: TextStyle(
            color: isSelected ? Colors.pink : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.pink.withOpacity(0.1),
        onTap: () {
          setState(() => _currentItem = section);
          if (!isWide) Navigator.pop(context);
        },
      );
    }

    // Si tiene subsecciones → ExpansionTile
    return ExpansionTile(
      leading: Icon(section.icon, color: Colors.pink),
      title: Text(
        section.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: _isSectionExpanded(section),
      children: section.items.map((item) => _buildSubItem(item, isWide)).toList(),
    );
  }

  bool _isSectionExpanded(MenuSection section) {
    // Expandida si contiene el item actual
    return section.items.contains(_currentItem);
  }

  Widget _buildSubItem(SubMenuItem item, bool isWide) {
    final isSelected = _isSelected(item);

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
        setState(() => _currentItem = item);
        if (!isWide) Navigator.of(context).pop();
      },
    );
  }
}