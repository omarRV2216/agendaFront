import 'package:flutter/material.dart';

import '../../../../../models/business_hour.dart';

class TabHorarios extends StatelessWidget {
  final List<BusinessHour> hours;
  final VoidCallback onRefresh;

  const TabHorarios({
    super.key,
    required this.hours,
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
          _buildListaHorarios(context),
        ],
      ),
    );
  }

  Widget _buildTitulo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horario semanal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Días y horas en que el negocio está abierto al público',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildListaHorarios(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < hours.length; i++) ...[
            _buildFilaHorario(hours[i]),
            if (i < hours.length - 1)
              Divider(height: 1, color: Colors.grey.shade100),
          ],
        ],
      ),
    );
  }

  Widget _buildFilaHorario(BusinessHour h) {
    final color = h.isOpen ? Colors.green.shade700 : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            width: 110,
            child: Text(
              h.nombreDia,
              style: TextStyle(
                fontSize: 14,
                fontWeight: h.isOpen ? FontWeight.w600 : FontWeight.normal,
                color: h.isOpen ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),

          // Estado + horario
          Expanded(
            child: h.isOpen
                ? Row(
              children: [
                _buildChipHora(h.openTimeShort),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward,
                    size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                _buildChipHora(h.closeTimeShort),
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

  Widget _buildChipHora(String hora) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade700.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hora,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade700,
        ),
      ),
    );
  }
}