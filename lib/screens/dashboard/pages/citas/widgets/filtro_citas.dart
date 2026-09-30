import 'package:flutter/material.dart';

import 'package:schedulefront/models/empleado_simple.dart';

/// Dropdown con buscador para filtrar por empleado.
class FiltroEmpleadoDropdown extends StatefulWidget {
  final List<EmpleadoSimple> empleados;
  final int? seleccionadoId;
  final ValueChanged<int?> onChanged;
  final double? width;

  const FiltroEmpleadoDropdown({
    super.key,
    required this.empleados,
    required this.onChanged,
    this.seleccionadoId,
    this.width,
  });

  @override
  State<FiltroEmpleadoDropdown> createState() => _FiltroEmpleadoDropdownState();
}

class _FiltroEmpleadoDropdownState extends State<FiltroEmpleadoDropdown> {
  late int? _seleccionadoId;

  @override
  void initState() {
    super.initState();
    _seleccionadoId = widget.seleccionadoId;
  }

  @override
  void didUpdateWidget(covariant FiltroEmpleadoDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seleccionadoId != widget.seleccionadoId) {
      _seleccionadoId = widget.seleccionadoId;
    }
  }

  void _onSelected(int? id) {
    setState(() => _seleccionadoId = id);
    widget.onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final hayFiltro = _seleccionadoId != null;

    return SizedBox(
      width: widget.width ?? 220,
      child: DropdownMenu<int?>(
        initialSelection: _seleccionadoId,
        width: widget.width ?? 220,
        enableFilter: true,
        requestFocusOnTap: true,
        hintText: 'Todos',
        label: const Text('Empleado'),
        leadingIcon: Icon(
          hayFiltro ? Icons.person : Icons.people_outline,
          size: 18,
          color: hayFiltro ? Colors.pink : Colors.grey.shade600,
        ),
        textStyle: TextStyle(
          fontSize: 13.5,
          color: hayFiltro ? Colors.pink.shade700 : Colors.black87,
          fontWeight: hayFiltro ? FontWeight.w600 : FontWeight.normal,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hayFiltro ? Colors.pink.shade200 : Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.pink, width: 1.5),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onSelected: _onSelected,
        dropdownMenuEntries: [
          const DropdownMenuEntry<int?>(
            value: null,
            label: 'Todos los empleados',
            leadingIcon: Icon(Icons.people, size: 18),
          ),
          ...widget.empleados.map((e) {
            return DropdownMenuEntry<int?>(
              value: e.id,
              label: e.name,
              leadingIcon: const Icon(Icons.person_outline, size: 18),
            );
          }),
        ],
      ),
    );
  }
}