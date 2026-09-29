import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:schedulefront/models/cita.dart';
import 'package:schedulefront/screens/dashboard/pages/citas/widgets/create_cita.dart';
import 'package:schedulefront/services/cita_service.dart';

class DetalleCitaDialog extends StatefulWidget {
  final Appointment cita;

  const DetalleCitaDialog({super.key, required this.cita});

  static Future<String?> show(BuildContext context, Appointment cita) {   // ✅ String
    return showDialog<String>(                                            // ✅ String
      context: context,
      barrierDismissible: true,
      builder: (_) => DetalleCitaDialog(cita: cita),
    );
  }

  @override
  State<DetalleCitaDialog> createState() => _DetalleCitaDialogState();
}

class _DetalleCitaDialogState extends State<DetalleCitaDialog> {
  final _service = AppointmentService();

  late Appointment _cita;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cita = widget.cita;
  }

  // ──────────────────────────────────────────────
  // Color / label según estado
  // ──────────────────────────────────────────────
  Color get _colorEstado => switch (_cita.status) {
    'pending'   => Colors.orange.shade700,
    'completed' => Colors.green.shade700,
    'cancelled' => Colors.red.shade600,
    _           => Colors.grey.shade600,
  };

  String get _labelEstado => switch (_cita.status) {
    'pending'   => 'Pendiente',
    'completed' => 'Asistió',
    'cancelled' => 'Canceló',
    _           => 'Desconocido',
  };

  IconData get _iconoEstado => switch (_cita.status) {
    'pending'   => Icons.schedule,
    'completed' => Icons.check_circle,
    'cancelled' => Icons.cancel,
    _           => Icons.help_outline,
  };

  // ──────────────────────────────────────────────
  // Cambiar estado
  // ──────────────────────────────────────────────
  Future<void> _cambiarEstado(String nuevoEstado) async {
    if (_cita.status == nuevoEstado) return;

    setState(() => _procesando = true);

    try {
      await _service.cambiarEstado(_cita.id!, nuevoEstado);

      if (!mounted) return;

      setState(() {
        _cita = _cita.copyWith(status: nuevoEstado);
        _procesando = false;
      });

      Navigator.pop(context, 'updated');
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
  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cita'),
        content: Text(
          '¿Estás seguro de eliminar la cita de "${_cita.clientName}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),   // ✅ ctx
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _procesando = true);

    try {
      await _service.eliminar(_cita.id!);

      if (!mounted) return;
      Navigator.pop(context, 'deleted');   // ✅ 'deleted'
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Flexible(child: _buildContenido()),
            const Divider(height: 1),
            _buildFooter(),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _colorEstado.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconoEstado, color: _colorEstado, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cita.clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _labelEstado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _colorEstado,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _procesando ? null : () => Navigator.pop(context),   // ✅
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFila(
            icono: Icons.spa_outlined,
            label: 'Servicio',
            valor: _cita.serviceName,
          ),
          _buildFila(
            icono: Icons.attach_money,
            label: 'Precio',
            valor: '\$${_cita.servicePrice.toStringAsFixed(2)}',
          ),
          _buildFila(
            icono: Icons.schedule,
            label: 'Duración',
            valor: '${_cita.durationMinutes} min',
          ),

          const Divider(height: 24),

          _buildFila(
            icono: Icons.calendar_today_outlined,
            label: 'Fecha',
            valor: DateFormat('EEEE d MMMM yyyy', 'es')
                .format(DateTime.parse(_cita.startTime)),
          ),
          _buildFila(
            icono: Icons.access_time,
            label: 'Hora',
            valor:
            '${DateFormat('HH:mm').format(DateTime.parse(_cita.startTime))} – ${DateFormat('HH:mm').format(DateTime.parse(_cita.endTime))}',
          ),

          if (_cita.employeeName != null) ...[
            const Divider(height: 24),
            _buildFila(
              icono: Icons.person_outline,
              label: 'Atiende',
              valor: _cita.employeeName!,
            ),
          ],

          if (_cita.clientPhone != null && _cita.clientPhone!.isNotEmpty)
            _buildFila(
              icono: Icons.phone_outlined,
              label: 'Teléfono',
              valor: _cita.clientPhone!,
            ),

          if (_cita.clientEmail != null && _cita.clientEmail!.isNotEmpty)
            _buildFila(
              icono: Icons.email_outlined,
              label: 'Email',
              valor: _cita.clientEmail!,
            ),

          if (_cita.notes != null && _cita.notes!.isNotEmpty) ...[
            const Divider(height: 24),
            const Text(
              'Notas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cita.notes!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFila({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Botones de estado
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _procesando || _cita.status == 'completed'
                      ? null
                      : () => _cambiarEstado('completed'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Asistió'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _procesando || _cita.status == 'cancelled'
                      ? null
                      : () => _cambiarEstado('cancelled'),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Canceló'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reagendar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _procesando ? null : _reagendar,
              icon: const Icon(Icons.event_repeat, size: 18),
              label: const Text('Reagendar cita'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.pink,
                side: const BorderSide(color: Colors.pink),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Eliminar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _procesando ? null : _eliminar,
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              label: const Text('Eliminar cita', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reagendar() async {
    // Cerrar el diálogo de detalle avisando que va a reagendar
    Navigator.pop(context, 'reschedule');
  }


}