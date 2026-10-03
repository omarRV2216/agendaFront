import 'package:flutter/material.dart';

class ContactoSection extends StatelessWidget {
  const ContactoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 80 : 50,
        horizontal: 24,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.contact_mail, size: 14, color: Colors.pink),
                    SizedBox(width: 6),
                    Text(
                      'Contáctanos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                '¿Tienes alguna duda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Estamos aquí para ayudarte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 16 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // Info de contacto (grid)
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildContactoCard(
                    icono: Icons.phone,
                    titulo: 'Teléfono',
                    valor: '555 123 4567',
                    color: Colors.green,
                  ),
                  _buildContactoCard(
                    icono: Icons.email,
                    titulo: 'Email',
                    valor: 'hola@nailsalon.com',
                    color: Colors.blue,
                  ),
                  _buildContactoCard(
                    icono: Icons.location_on,
                    titulo: 'Dirección',
                    valor: 'Av. Principal 123',
                    color: Colors.red,
                  ),
                  _buildContactoCard(
                    icono: Icons.access_time,
                    titulo: 'Horario',
                    valor: 'Lun-Sáb 9-20h',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactoCard({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}