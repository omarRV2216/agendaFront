import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddClosureDialog extends StatefulWidget {
  const AddClosureDialog({super.key});

  /// Devuelve un `Map` con los datos si el usuario confirma:
  /// {
  ///   'date': 'YYYY-MM-DD',
  ///   'type': 'closed' | 'custom',
  ///   'open_time': 'HH:MM:SS' | null,
  ///   'close_time': 'HH:MM:SS' | null,
  ///   'reason': String?,
  /// }
  ///
  /// O `null` si cancela.
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddClosureDialog(),
    );
  }

  @override
  State<AddClosureDialog> createState() => _AddClosureDialogState();
}

class _AddClosureDialogState extends State<AddClosureDialog> {
  DateTime? _fecha;
  String _tipo = 'closed';   // 'closed' | 'custom'

  TimeOfDay _horaApertura = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaCierre   = const TimeOfDay(hour: 14, minute: 0);

  final _motivoCtrl = TextEditingController();

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Selectores
  // ──────────────────────────────────────────────
  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 3)), // 3 años
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      locale: const Locale('es', 'ES'),
    );

    if (fecha == null) return;
    setState(() => _fecha = fecha);
  }

  Future<void> _elegirHoraApertura() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaApertura,
      helpText: 'Hora de apertura',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (hora == null) return;
    setState(() => _horaApertura = hora);
  }

  Future<void> _elegirHoraCierre() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaCierre,
      helpText: 'Hora de cierre',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (hora == null) return;
    setState(() => _horaCierre = hora);
  }

  // ──────────────────────────────────────────────
  // Guardar
  // ──────────────────────────────────────────────
  void _guardar() {
    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Si es custom, validar que cierre > apertura
    if (_tipo == 'custom') {
      final aperturaMin = _horaApertura.hour * 60 + _horaApertura.minute;
      final cierreMin   = _horaCierre.hour * 60 + _horaCierre.minute;

      if (cierreMin <= aperturaMin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La hora de cierre debe ser posterior a la de apertura'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final fechaStr = DateFormat('yyyy-MM-dd').format(_fecha!);

    String? openTime;
    String? closeTime;

    if (_tipo == 'custom') {
      openTime = '${_horaApertura.hour.toString().padLeft(2, '0')}:${_horaApertura.minute.toString().padLeft(2, '0')}:00';
      closeTime = '${_horaCierre.hour.toString().padLeft(2, '0')}:${_horaCierre.minute.toString().padLeft(2, '0')}:00';
    }

    Navigator.pop(context, {
      'date':       fechaStr,
      'type':       _tipo,
      'open_time':  openTime,
      'close_time': closeTime,
      'reason':     _motivoCtrl.text.trim().isEmpty ? null : _motivoCtrl.text.trim(),
    });
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final fechaStr = _fecha == null
        ? 'Selecciona una fecha'
        : DateFormat('EEEE d MMMM yyyy', 'es').format(_fecha!);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha
                    _buildLabel('Fecha'),
                    const SizedBox(height: 8),
                    _buildSelectorFecha(fechaStr),
                    const SizedBox(height: 20),

                    // Tipo
                    _buildLabel('Tipo de excepción'),
                    const SizedBox(height: 8),
                    _buildOpcionesTipo(),
                    const SizedBox(height: 20),

                    // Si es custom, mostrar horas
                    if (_tipo == 'custom') ...[
                      _buildLabel('Horario especial'),
                      const SizedBox(height: 8),
                      _buildHorasEspeciales(),
                      const SizedBox(height: 20),
                    ],

                    // Motivo
                    _buildLabel('Motivo (opcional)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _motivoCtrl,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: 'Ej: Navidad, Vacaciones, Mantenimiento...',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.pink, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy, size: 20, color: Colors.pink),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Agregar excepción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSelectorFecha(String texto) {
    return InkWell(
      onTap: _elegirFecha,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _fecha == null ? Colors.grey.shade200 : Colors.pink.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: _fecha == null ? Colors.grey.shade500 : Colors.pink,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 14,
                  color: _fecha == null ? Colors.grey.shade500 : Colors.black87,
                  fontWeight: _fecha == null ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionesTipo() {
    return Column(
      children: [
        _buildOpcionTipo(
          value: 'closed',
          titulo: 'Cerrado todo el día',
          subtitulo: 'El negocio no abre ese día',
          icono: Icons.block,
          color: Colors.red.shade600,
        ),
        const SizedBox(height: 8),
        _buildOpcionTipo(
          value: 'custom',
          titulo: 'Horario especial',
          subtitulo: 'Abre con un horario diferente',
          icono: Icons.schedule,
          color: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _buildOpcionTipo({
    required String value,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
  }) {
    final seleccionado = _tipo == value;

    return InkWell(
      onTap: () => setState(() => _tipo = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? color : Colors.grey.shade200,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: seleccionado ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildHorasEspeciales() {
    return Row(
      children: [
        Expanded(
          child: _buildBotonHora(
            label: 'Apertura',
            hora: _horaApertura,
            onTap: _elegirHoraApertura,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBotonHora(
            label: 'Cierre',
            hora: _horaCierre,
            onTap: _elegirHoraCierre,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonHora({
    required String label,
    required TimeOfDay hora,
    required VoidCallback onTap,
  }) {
    final str = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.pink),
                const SizedBox(width: 6),
                Text(
                  str,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Agregar'),
            style: FilledButton.styleFrom(backgroundColor: Colors.pink),
          ),
        ],
      ),
    );
  }
}