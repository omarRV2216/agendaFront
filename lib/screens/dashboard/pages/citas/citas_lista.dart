import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulefront/screens/dashboard/pages/citas/widgets/create_cita.dart';
import 'package:schedulefront/screens/dashboard/pages/citas/widgets/detalles_cita.dart';
import '../../../../models/cita.dart';
import '../../../../services/cita_service.dart';

class CitasListaPage extends StatefulWidget {
  const CitasListaPage({super.key});

  @override
  State<CitasListaPage> createState() => _CitasListaPageState();
}

class _CitasListaPageState extends State<CitasListaPage> {
  final _service = AppointmentService();

  // Semana actual (lunes de la semana mostrada)
  DateTime _semanaActual = _lunesDe(DateTime.now());

  List<Appointment> _citas = [];
  bool _loading = true;
  String? _error;

  // ──────────────────────────────────────────────
  // Helpers de fechas
  // ──────────────────────────────────────────────
  static DateTime _lunesDe(DateTime d) {
    final sinHora = DateTime(d.year, d.month, d.day);
    return sinHora.subtract(Duration(days: sinHora.weekday - 1));
  }

  DateTime get _domingo => _semanaActual.add(const Duration(days: 6));

  String get _rangoTexto {
    final fmt = DateFormat('d MMM', 'es');
    final mismoMes = _semanaActual.month == _domingo.month;
    final fmtFin = DateFormat(mismoMes ? 'd MMM yyyy' : 'd MMM yyyy', 'es');
    return '${fmt.format(_semanaActual)} – ${fmtFin.format(_domingo)}';
  }

  void _abrirCrearCita() async {
    final creado = await NuevaCitaWizard.show(context);
    if (creado == true) {
      _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cita creada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // ──────────────────────────────────────────────
  // Carga
  // ──────────────────────────────────────────────
  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final lista = await _service.listar(
        from: fmt.format(_semanaActual),
        to:   fmt.format(_domingo),
      );

      final citas = lista.map((e) => Appointment.fromJson(e)).toList();

      if (!mounted) return;
      setState(() {
        _citas = citas;
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

  void _semanaAnterior() {
    setState(() {
      _semanaActual = _semanaActual.subtract(const Duration(days: 7));
    });
    _cargar();
  }

  void _semanaSiguiente() {
    setState(() {
      _semanaActual = _semanaActual.add(const Duration(days: 7));
    });
    _cargar();
  }

  void _irAHoy() {
    setState(() {
      _semanaActual = _lunesDe(DateTime.now());
    });
    _cargar();
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_citas.length}',
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Citas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gestiona la agenda semanal',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _abrirCrearCita,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva cita'),
                style: FilledButton.styleFrom(backgroundColor: Colors.pink),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              IconButton(
                onPressed: _semanaAnterior,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Semana anterior',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Center(
                  child: Text(
                    _rangoTexto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _semanaSiguiente,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Semana siguiente',
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _irAHoy,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  side: const BorderSide(color: Colors.pink),
                ),
                child: const Text('Hoy'),
              ),
            ],
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.pink),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double anchoMinimoDia = 130;
        const double anchoHoras = 60;
        final double anchoDisponible = constraints.maxWidth - anchoHoras;
        final double anchoTotal = anchoMinimoDia * 7;

        if (anchoDisponible >= anchoTotal) {
          return _buildGrid(anchoDia: anchoDisponible / 7);
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: anchoHoras + anchoTotal,
              child: _buildGrid(anchoDia: anchoMinimoDia),
            ),
          );
        }
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Grid semanal
  // ──────────────────────────────────────────────
  Widget _buildGrid({required double anchoDia}) {
    const double altoHora = 60;
    const double altoHeader = 60;
    const int horaInicio = 8;
    const int horaFin = 21;
    final int totalHoras = horaFin - horaInicio;

    final citasPorDia = <int, List<Appointment>>{};
    for (int i = 0; i < 7; i++) {
      citasPorDia[i] = [];
    }
    for (final c in _citas) {
      final fecha = DateTime.tryParse(c.appointmentDate);
      if (fecha == null) continue;

      final diff = DateTime(fecha.year, fecha.month, fecha.day)
          .difference(_semanaActual)
          .inDays;

      if (diff >= 0 && diff < 7) {
        citasPorDia[diff]!.add(c);
      }
    }

    return Column(
      children: [
        Container(
          height: altoHeader,
          color: Colors.white,
          child: Row(
            children: [
              const SizedBox(width: 60),
              for (int i = 0; i < 7; i++)
                _buildHeaderDia(
                  fecha: _semanaActual.add(Duration(days: i)),
                  ancho: anchoDia,
                ),
            ],
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: totalHoras * altoHora,
              child: Stack(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            for (int h = horaInicio; h < horaFin; h++)
                              SizedBox(
                                height: altoHora,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6, top: 4),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      '${h.toString().padLeft(2, '0')}:00',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      for (int i = 0; i < 7; i++)
                        _buildColumnaDia(
                          ancho: anchoDia,
                          altoHora: altoHora,
                          horaInicio: horaInicio,
                          totalHoras: totalHoras,
                          citas: citasPorDia[i]!,
                          esHoy: _esHoy(_semanaActual.add(Duration(days: i))),
                        ),
                    ],
                  ),

                  ..._buildLineaAhora(
                    altoHora: altoHora,
                    horaInicio: horaInicio,
                    anchoDia: anchoDia,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDia({required DateTime fecha, required double ancho}) {
    final esHoy = _esHoy(fecha);
    final fmtDia = DateFormat('EEE', 'es');
    final fmtNum = DateFormat('d');

    return Container(
      width: ancho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fmtDia.format(fecha).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: esHoy ? Colors.pink : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esHoy ? Colors.pink : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              fmtNum.format(fecha),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: esHoy ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Algoritmo de columnas
  // ──────────────────────────────────────────────
  /// Dado un grupo de citas, calcula en qué sub-columna va cada una.
  List<Map<String, dynamic>> _calcularColumnas(List<Appointment> citas) {
    if (citas.isEmpty) return [];

    final ordenadas = List<Appointment>.from(citas)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final resultado = <Map<String, dynamic>>[];

    // Agrupar en clusters (citas que se solapan entre sí)
    final clusters = <List<Appointment>>[];

    for (final cita in ordenadas) {
      bool agregada = false;

      for (final cluster in clusters) {
        final seSolapa = cluster.any((c) {
          return cita.startTime.compareTo(c.endTime) < 0 &&
              cita.endTime.compareTo(c.startTime) > 0;
        });

        if (seSolapa) {
          cluster.add(cita);
          agregada = true;
          break;
        }
      }

      if (!agregada) {
        clusters.add([cita]);
      }
    }

    // Dentro de cada cluster, asignar columnas
    for (final cluster in clusters) {
      final columnas = <DateTime>[];

      for (final cita in cluster) {
        final inicio = DateTime.parse(cita.startTime);

        int colIndex = -1;
        for (int i = 0; i < columnas.length; i++) {
          if (!columnas[i].isAfter(inicio)) {
            colIndex = i;
            break;
          }
        }

        if (colIndex == -1) {
          columnas.add(DateTime.parse(cita.endTime));
          colIndex = columnas.length - 1;
        } else {
          columnas[colIndex] = DateTime.parse(cita.endTime);
        }

        resultado.add({
          'cita': cita,
          'columnIndex': colIndex,
          'totalColumns': 0,
        });
      }

      final totalCols = columnas.length;

      for (final item in resultado) {
        if (cluster.contains(item['cita'])) {
          item['totalColumns'] = totalCols;
        }
      }
    }

    return resultado;
  }

  // ──────────────────────────────────────────────
  // Columna de un día
  // ──────────────────────────────────────────────
  Widget _buildColumnaDia({
    required double ancho,
    required double altoHora,
    required int horaInicio,
    required int totalHoras,
    required List<Appointment> citas,
    required bool esHoy,
  }) {
    // Calcular posiciones con el algoritmo de columnas
    final posiciones = _calcularColumnas(citas);

    final eventos = <Widget>[];

    for (final item in posiciones) {
      final cita = item['cita'] as Appointment;
      final colIndex = item['columnIndex'] as int;
      final totalCols = item['totalColumns'] as int;

      final inicio = DateTime.tryParse(cita.startTime);
      final fin = DateTime.tryParse(cita.endTime);
      if (inicio == null || fin == null) continue;

      final minutosDesdeInicio =
          (inicio.hour - horaInicio) * 60 + inicio.minute;
      final duracionMinutos = fin.difference(inicio).inMinutes;

      final top = (minutosDesdeInicio / 60) * altoHora;
      final height = (duracionMinutos / 60) * altoHora;

      if (top + height < 0 || top > totalHoras * altoHora) continue;

      // Repartir el ancho entre las columnas del cluster
      final anchoSlot = (ancho - 4) / totalCols;
      final left = colIndex * anchoSlot + 2;

      eventos.add(
        Positioned(
          top: top,
          left: left,
          width: anchoSlot - 2,
          height: height.clamp(20, double.infinity),
          child: _buildEventoCita(cita, esHoy: esHoy),
        ),
      );
    }

    return Container(
      width: ancho,
      height: totalHoras * altoHora,
      decoration: BoxDecoration(
        color: esHoy ? Colors.pink.withOpacity(0.03) : Colors.transparent,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              for (int h = 0; h < totalHoras; h++)
                Container(
                  height: altoHora,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
                    ),
                  ),
                ),
            ],
          ),

          ...eventos,
        ],
      ),
    );
  }

  Widget _buildEventoCita(Appointment c, {required bool esHoy}) {
    final color = _colorEstado(c.status);

    return GestureDetector(
      onTap: () => _abrirDetalleCita(c),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                c.clientName,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (c.durationMinutes >= 45)
                Text(
                  c.serviceName,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (c.durationMinutes >= 60)
                Text(
                  DateFormat('HH:mm').format(DateTime.parse(c.startTime)),
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Línea roja "ahora"
  // ──────────────────────────────────────────────
  List<Widget> _buildLineaAhora({
    required double altoHora,
    required int horaInicio,
    required double anchoDia,
  }) {
    final ahora = DateTime.now();

    final diff = DateTime(ahora.year, ahora.month, ahora.day)
        .difference(_semanaActual)
        .inDays;

    if (diff < 0 || diff > 6) return [];

    final minutos = (ahora.hour - horaInicio) * 60 + ahora.minute;
    if (minutos < 0) return [];

    final top = (minutos / 60) * altoHora;
    final left = 60 + diff * anchoDia;

    return [
      Positioned(
        top: top,
        left: left,
        right: 0,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 1.5,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ──────────────────────────────────────────────
  // Colores por estado
  // ──────────────────────────────────────────────
  Color _colorEstado(String status) => switch (status) {
    'pending'   => Colors.tealAccent.shade700,   // 🟠
    'completed' => Colors.green.shade700,    // 🟢
    'cancelled' => Colors.red.shade600,      // 🔴
    _           => Colors.grey.shade600,
  };

  bool _esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  // ──────────────────────────────────────────────
  // Acciones
  // ──────────────────────────────────────────────
  Future<void> _abrirDetalleCita(Appointment c) async {
    final accion = await DetalleCitaDialog.show(context, c);

    if (!mounted || accion == null) return;

    if (accion == 'updated') {
      _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cita actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (accion == 'deleted') {
      _cargar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Cita eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (accion == 'reschedule') {
      // 👇 El padre abre el wizard
      final reagendada = await NuevaCitaWizard.show(
        context,
        citaExistente: c,
      );

      if (reagendada == true) {
        _cargar();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cita reagendada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}