import 'package:flutter/material.dart';

import '../../../../../models/business_hour.dart';
import '../../../../../services/business_config_service.dart';

class TabHorarios extends StatefulWidget {
  final List<BusinessHour> hours;
  final VoidCallback onRefresh;

  const TabHorarios({
    super.key,
    required this.hours,
    required this.onRefresh,
  });

  @override
  State<TabHorarios> createState() => _TabHorariosState();
}

class _TabHorariosState extends State<TabHorarios> {
  final _service = BusinessConfigService();

  late List<BusinessHour> _horas;
  bool _guardando = false;
  bool _hayCambios = false;

  @override
  void initState() {
    super.initState();
    _horas = List.from(widget.hours);
  }

  @override
  void didUpdateWidget(covariant TabHorarios oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el padre recarga los datos, resincronizar
    if (oldWidget.hours != widget.hours) {
      _horas = List.from(widget.hours);
      _hayCambios = false;
    }
  }

  // ──────────────────────────────────────────────
  // Acciones
  // ──────────────────────────────────────────────
  void _toggleDia(int index, bool valor) {
    setState(() {
      _horas[index] = _horas[index].copyWith(isOpen: valor);
      _hayCambios = true;
    });
  }

  Future<void> _editarHora(int index, bool esApertura) async {
    final h = _horas[index];
    final horaActual = esApertura ? h.openTime : h.closeTime;

    final partes = horaActual.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );

    final nueva = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: esApertura ? 'Hora de apertura' : 'Hora de cierre',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (nueva == null) return;

    final horaStr = '${nueva.hour.toString().padLeft(2, '0')}:${nueva.minute.toString().padLeft(2, '0')}:00';

    setState(() {
      if (esApertura) {
        _horas[index] = _horas[index].copyWith(openTime: horaStr);
      } else {
        _horas[index] = _horas[index].copyWith(closeTime: horaStr);
      }
      _hayCambios = true;
    });
  }

  Future<void> _guardar() async {
    // Validar: si está abierto, close > open
    for (final h in _horas) {
      if (h.isOpen) {
        if (h.closeTime.compareTo(h.openTime) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${h.nombreDia}: la hora de cierre debe ser posterior a la de apertura'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    setState(() => _guardando = true);

    try {
      await _service.actualizarHorarios(_horas);

      if (!mounted) return;

      setState(() {
        _guardando = false;
        _hayCambios = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Horario guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitulo(),
                const SizedBox(height: 16),
                _buildListaHorarios(),
              ],
            ),
          ),
        ),
        if (_hayCambios) _buildFooterGuardar(),
      ],
    );
  }

  Widget _buildTitulo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horario semanal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Activa o desactiva los días y ajusta las horas',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildListaHorarios() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _horas.length; i++) ...[
            _buildFilaHorario(i),
            if (i < _horas.length - 1)
              Divider(height: 1, color: Colors.grey.shade100),
          ],
        ],
      ),
    );
  }

  Widget _buildFilaHorario(int index) {
    final h = _horas[index];
    final color = h.isOpen ? Colors.green.shade700 : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Indicador
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre del día
          SizedBox(
            width: 100,
            child: Text(
              h.nombreDia,
              style: TextStyle(
                fontSize: 14,
                fontWeight: h.isOpen ? FontWeight.w600 : FontWeight.normal,
                color: h.isOpen ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),

          // Switch
          Switch(
            value: h.isOpen,
            onChanged: _guardando ? null : (v) => _toggleDia(index, v),
            activeColor: Colors.pink,
          ),
          const SizedBox(width: 8),

          // Horas o "Cerrado"
          Expanded(
            child: h.isOpen
                ? Row(
              children: [
                _buildBotonHora(
                  h.openTimeShort,
                  onTap: _guardando ? null : () => _editarHora(index, true),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward,
                    size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                _buildBotonHora(
                  h.closeTimeShort,
                  onTap: _guardando ? null : () => _editarHora(index, false),
                ),
              ],
            )
                : Text(
              'Cerrado',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonHora(String hora, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade700.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.shade700.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hora,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 12,
              color: Colors.green.shade700.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterGuardar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tienes cambios sin guardar',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.save, size: 18),
            label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            style: FilledButton.styleFrom(backgroundColor: Colors.pink),
          ),
        ],
      ),
    );
  }
}