import 'package:flutter/material.dart';

class InicioSection extends StatelessWidget {
  const InicioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 80 : 50,
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F5), Colors.white],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
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
                    Icon(Icons.star, size: 14, color: Colors.pink),
                    SizedBox(width: 6),
                    Text(
                      'Bienvenido a Nail Salon',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'Agenda tu cita en línea',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 44 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Subtítulo
              Text(
                'Rápido, fácil y sin esperas.\nElige el servicio, la fecha y listo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 18 : 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Botón
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/agendar');
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Agendar cita'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 24,
                    vertical: isWide ? 18 : 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Link secundario
              TextButton(
                onPressed: () {
                  // TODO: scroll a servicios
                },
                child: const Text('Ver servicios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}