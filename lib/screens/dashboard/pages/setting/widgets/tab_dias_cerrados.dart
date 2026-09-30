import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/business_closure.dart';

class TabDiasCerrados extends StatelessWidget {
  final List<BusinessClosure> closures;
  final VoidCallback onRefresh;

  const TabDiasCerrados({
    super.key,
    required this.closures,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitulo(context),
          const SizedBox(height: 16),
          if (closures.isEmpty)
            _buildSinExcepciones()
          else
            Column(
              children: closures.map((c) => _buildCardExcepcion(c)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTitulo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Días cerrados y excepciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Feriados, vacaciones u horarios especiales',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        if (closures.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${closures.length}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            'Todos los días siguen el horario semanal',
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
          // Icono
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

          // Info
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
                    // Chip del tipo
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
                    // Motivo
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
        ],
      ),
    );
  }
}