import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/business_closure.dart';
import '../../../../../services/business_config_service.dart';
import 'add_closure_dialog.dart';

class TabDiasCerrados extends StatefulWidget {
  final List<BusinessClosure> closures;
  final VoidCallback onRefresh;

  const TabDiasCerrados({
    super.key,
    required this.closures,
    required this.onRefresh,
  });

  @override
  State<TabDiasCerrados> createState() => _TabDiasCerradosState();
}

class _TabDiasCerradosState extends State<TabDiasCerrados> {
  final _service = BusinessConfigService();
  bool _procesando = false;

  // ──────────────────────────────────────────────
  // Agregar
  // ──────────────────────────────────────────────
  Future<void> _agregarExcepcion() async {
    final data = await AddClosureDialog.show(context);

    if (data == null) return;

    setState(() => _procesando = true);

    try {
      await _service.agregarCierre(
        date:       data['date'],
        type:       data['type'],
        openTime:   data['open_time'],
        closeTime:  data['close_time'],
        reason:     data['reason'],
      );

      if (!mounted) return;
      setState(() => _procesando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Excepción agregada'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Eliminar
  // ──────────────────────────────────────────────
  Future<void> _eliminarExcepcion(BusinessClosure c) async {
    final fecha = DateTime.parse(c.date);
    final fechaFmt = DateFormat('d MMMM yyyy', 'es').format(fecha);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar excepción'),
        content: Text(
          '¿Estás seguro de eliminar la excepción del $fechaFmt?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _procesando = true);

    try {
      await _service.eliminarCierre(c.id);

      if (!mounted) return;
      setState(() => _procesando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Excepción eliminada'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onRefresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);

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
                if (widget.closures.isEmpty)
                  _buildSinExcepciones()
                else
                  Column(
                    children: widget.closures
                        .map((c) => _buildCardExcepcion(c))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        _buildFooterAgregar(),
      ],
    );
  }

  Widget _buildTitulo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Días cerrados y excepciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.closures.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.closures.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Feriados, vacaciones u horarios especiales',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSinExcepciones() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No hay excepciones configuradas',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega feriados, vacaciones u horarios especiales',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCardExcepcion(BusinessClosure c) {
    final fecha = DateTime.parse(c.date);
    final fechaFmt = DateFormat('EEEE d MMMM yyyy', 'es').format(fecha);
    final fechaCapitalized = fechaFmt[0].toUpperCase() + fechaFmt.substring(1);

    final color = c.esCerrado ? Colors.red.shade600 : Colors.orange.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              c.esCerrado ? Icons.block : Icons.schedule,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fechaCapitalized,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c.esCerrado
                            ? 'Cerrado todo el día'
                            : '${c.openTimeShort} – ${c.closeTimeShort}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    if (c.reason != null && c.reason!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          c.reason!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Botón eliminar
          IconButton(
            onPressed: _procesando ? null : () => _eliminarExcepcion(c),
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade400,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAgregar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _procesando ? null : _agregarExcepcion,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Agregar excepción'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.pink,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}