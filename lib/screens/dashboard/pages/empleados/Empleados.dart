import 'package:flutter/material.dart';
import 'package:schedulefront/screens/dashboard/pages/empleados/widgets/create_empleado.dart';

import '../../../../services/empleado_service.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosListaPageState();
}

class _EmpleadosListaPageState extends State<EmpleadosPage> {
  final _service = EmpleadoService();
  final _searchController = TextEditingController();

  List<dynamic> _empleados = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargar({
    String? search
  }) async
  {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lista = await _service.listar(
        search: _searchController.text
      );
      if (!mounted) return;
      setState(() {
        _empleados = lista;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContenido()),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Header con título + buscador
  // ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_empleados.length}',
                          style: const TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Empleados',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),
                  const Text(
                    'Gestiona a tu equipo de trabajo',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),


                ],
              ),
              // Contador
              IconButton(
                onPressed: () async {
                  final creado = await CrearEmpleadoDialog.show(context);

                  if (creado == true) {
                    // Se creó correctamente → recargar la lista
                    _cargar();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Empleado creado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
              ),

            ],
          ),
          const SizedBox(height: 16),

          // Buscador
          TextField(
            controller: _searchController,
            onSubmitted: (v) => _cargar(search: v),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, usuario o teléfono...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _cargar();
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(dynamic e) {
    final name = (e['name'] as String? ?? '').trim();
    final username = e['username'] ?? '';
    final phone = e['phone'] ?? '';
    final gender = e['gender'] ?? '';
    final active = e['active'] == 1 || e['active'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor(name),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name.isEmpty ? 'Sin nombre' : name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusChip(active),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.alternate_email,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.phone_outlined,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Contenido: loading / error / lista / vacío
  // ──────────────────────────────────────────────
  Widget _buildContenido() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pink),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_empleados.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: Colors.pink,
      onRefresh: () => _cargar(search: _searchController.text),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _empleados.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildCard(_empleados[index]),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _cargar(search: _searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay empleados',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registra uno para empezar',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Card de cada empleado
  // ──────────────────────────────────────────────


  Widget _statusChip(bool active) {
    final color = active ? Colors.green : Colors.grey;
    final bgColor = active ? Colors.green.shade50 : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helpers visuales
  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _avatarColor(String name) {
    final colors = [
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.indigo.shade300,
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.blueGrey.shade400,
    ];
    if (name.isEmpty) return colors.first;
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}