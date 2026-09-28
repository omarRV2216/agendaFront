import 'package:flutter/material.dart';
import '../../../../models/service.dart';
import '../../../../services/service_service.dart';

class ServiciosListaPage extends StatefulWidget {
  const ServiciosListaPage({super.key});

  @override
  State<ServiciosListaPage> createState() => _ServiciosListaPageState();
}

class _ServiciosListaPageState extends State<ServiciosListaPage> {
  final _service = ServiceService();
  final _searchController = TextEditingController();

  List<Service> _servicios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargar({String? search}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lista = await _service.listar(
        search: (search == null || search.isEmpty) ? null : search,
      );
      if (!mounted) return;
      setState(() {
        _servicios = lista;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContenido()),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_servicios.length}',
                      style: const TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Servicios',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: () async {
                 /*
                 final creado = await CrearServicioDialog.show(context);
                  if (creado == true) {
                    _cargar();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Servicio creado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                 * */
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Gestiona tu catálogo de servicios',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _searchController,
            onSubmitted: (v) => _cargar(search: v),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o descripción...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _cargar();
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Contenido
  // ──────────────────────────────────────────────
  Widget _buildContenido() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.pink));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _cargar(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(backgroundColor: Colors.pink),
              ),
            ],
          ),
        ),
      );
    }

    if (_servicios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay servicios',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea uno para empezar',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.pink,
      onRefresh: () => _cargar(search: _searchController.text),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _servicios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildCard(_servicios[index]),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Card de servicio
  // ──────────────────────────────────────────────
  Widget _buildCard(Service s) {
    print('🖼️ photoPath: ${s.photoPath}');
    print('🖼️ photoUrl: ${s.photoUrl}');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Foto
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 72,
                color: Colors.pink.shade50,
                child: s.photoUrl != null
                    ? Image.network(
                  s.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.pink.shade200,
                    size: 28,
                  ),
                )
                    : Icon(
                  Icons.spa_outlined,
                  color: Colors.pink.shade200,
                  size: 28,
                )
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!s.active)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Inactivo',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (s.description != null && s.description!.isNotEmpty)
                    Text(
                      s.description!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Precio
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.priceFormatted,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Duración
                      Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        s.durationFormatted,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}