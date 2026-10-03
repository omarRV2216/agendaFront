import 'package:flutter/material.dart';

class ServiciosSection extends StatelessWidget {
  const ServiciosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 80 : 50,
        horizontal: 24,
      ),
      color: Colors.grey.shade50,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa, size: 14, color: Colors.pink),
                    SizedBox(width: 6),
                    Text(
                      'Nuestros servicios',
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

              // ── Título ──
              Text(
                'Lo que ofrecemos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtítulo ──
              Text(
                'Servicios profesionales para consentirte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 16 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // ── Grid de servicios ──
              _buildGridServicios(isWide),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridServicios(bool isWide) {
    // 👇 Datos fake. Después los traes del API con ServiceService
    final servicios = [
      {
        'nombre': 'Corte de cabello',
        'precio': '\$150',
        'duracion': '30 min',
        'icono': Icons.content_cut,
        'color': Colors.pink,
      },
      {
        'nombre': 'Tinte',
        'precio': '\$300',
        'duracion': '90 min',
        'icono': Icons.palette,
        'color': Colors.purple,
      },
      {
        'nombre': 'Peinado',
        'precio': '\$200',
        'duracion': '45 min',
        'icono': Icons.brush,
        'color': Colors.orange,
      },
      {
        'nombre': 'Manicure',
        'precio': '\$180',
        'duracion': '60 min',
        'icono': Icons.back_hand,
        'color': Colors.teal,
      },
      {
        'nombre': 'Pedicure',
        'precio': '\$220',
        'duracion': '60 min',
        'icono': Icons.spa,
        'color': Colors.indigo,
      },
      {
        'nombre': 'Maquillaje',
        'precio': '\$250',
        'duracion': '45 min',
        'icono': Icons.face_retouching_natural,
        'color': Colors.red,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWide ? 1.4 : 2.8,
      ),
      itemCount: servicios.length,
      itemBuilder: (context, i) => _buildCardServicio(servicios[i]),
    );
  }

  Widget _buildCardServicio(Map<String, dynamic> s) {
    final Color color = s['color'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s['icono'], color: color, size: 24),
          ),
          const SizedBox(height: 14),

          // Nombre
          Text(
            s['nombre'],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Precio y duración
          Row(
            children: [
              Text(
                s['precio'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.schedule, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                s['duracion'],
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}