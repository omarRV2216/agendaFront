import 'package:flutter/material.dart';

import 'package:schedulefront/models/empleado_simple.dart';

class FiltroEmpleadoDialog extends StatefulWidget {
  final List<EmpleadoSimple> empleados;
  final int? seleccionadoId;

  const FiltroEmpleadoDialog({
    super.key,
    required this.empleados,
    this.seleccionadoId,
  });

  /// Devuelve:
  /// - `FiltroResultado(empleadoId: null)` si el usuario elige "Todos"
  /// - `FiltroResultado(empleadoId: 5)` si el usuario elige un empleado
  /// - `null` si cierra sin elegir
  static Future<FiltroResultado?> show(
      BuildContext context, {
        required List<EmpleadoSimple> empleados,
        int? seleccionadoId,
      }) {
    return showDialog<FiltroResultado>(
      context: context,
      barrierDismissible: true,
      builder: (_) => FiltroEmpleadoDialog(
        empleados: empleados,
        seleccionadoId: seleccionadoId,
      ),
    );
  }

  @override
  State<FiltroEmpleadoDialog> createState() => _FiltroEmpleadoDialogState();
}

/// Wrapper para distinguir "Todos" (null) de "cerró sin elegir" (null)
class FiltroResultado {
  final int? empleadoId;
  FiltroResultado({required this.empleadoId});
}

class _FiltroEmpleadoDialogState extends State<FiltroEmpleadoDialog> {
  final _searchCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EmpleadoSimple> get _filtrados {
    if (_busqueda.trim().isEmpty) return widget.empleados;
    final q = _busqueda.toLowerCase();
    return widget.empleados
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildBuscador(),
            const Divider(height: 1),
            Flexible(child: _buildLista()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.filter_alt, color: Colors.pink, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Filtrar por empleado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _busqueda = v),
        decoration: InputDecoration(
          hintText: 'Buscar empleado...',
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLista() {
    final filtrados = _filtrados;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opción "Todos" (si no hay búsqueda activa)
          if (_busqueda.trim().isEmpty)
            _buildItem(
              id: null,
              nombre: 'Todos los empleados',
              icono: Icons.people,
              esTodos: true,
            ),

          if (filtrados.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No se encontraron empleados',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            for (final e in filtrados)
              _buildItem(
                id: e.id,
                nombre: e.name,
                icono: Icons.person_outline,
                esTodos: false,
              ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required int? id,
    required String nombre,
    required IconData icono,
    required bool esTodos,
  }) {
    final isSelected = widget.seleccionadoId == id;
    final color = esTodos ? Colors.pink : Colors.grey.shade700;

    return InkWell(
      onTap: () {
        Navigator.pop(
          context,
          FiltroResultado(empleadoId: id),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icono, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.pink.shade700 : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.pink, size: 20),
          ],
        ),
      ),
    );
  }
}