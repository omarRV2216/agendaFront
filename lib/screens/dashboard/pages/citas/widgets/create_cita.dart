import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulefront/models/empleado_simple.dart';
import 'package:schedulefront/models/service.dart';
import 'package:schedulefront/services/empleado_service.dart';
import 'package:schedulefront/services/service_service.dart';
import '../../../../../models/cita.dart';
import '../../../../../services/cita_service.dart';

class NuevaCitaWizard extends StatefulWidget {
  final DateTime? fechaInicial;
  final Appointment? citaExistente;   // 👈 NUEVO

  const NuevaCitaWizard({
    super.key,
    this.fechaInicial,
    this.citaExistente,
  });

  static Future<bool?> show(
      BuildContext context, {
        DateTime? fechaInicial,
        Appointment? citaExistente,       // 👈 NUEVO
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NuevaCitaWizard(
        fechaInicial: fechaInicial,
        citaExistente: citaExistente,
      ),
    );
  }

  @override
  State<NuevaCitaWizard> createState() => _NuevaCitaWizardState();
}

class _NuevaCitaWizardState extends State<NuevaCitaWizard> {
  int _paso = 0;

  // ── Paso 1: servicio ──
  List<Service> _servicios = [];
  bool _loadingServicios = true;
  String? _errorServicios;
  Service? _servicioSeleccionado;


  // ── Empleados (se cargan al abrir, TODOS) ──
  List<EmpleadoSimple> _empleados = [];
  bool _loadingEmpleados = true;

  // ── Paso 2: cliente ──
  final _clientNameCtrl  = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _clientEmailCtrl = TextEditingController();

  // ── Paso 3: fecha / hora / empleado ──
  EmpleadoSimple? _empleadoSeleccionado;
  DateTime _mesActual = DateTime.now();
  DateTime? _fechaSeleccionada;
  Map<String, dynamic>? _disponibilidad;
  bool _loadingSlots = false;
  String? _horaSeleccionada;
  int? _empleadoPendienteId;

  // ── Paso 4: notas ──
  final _notesCtrl = TextEditingController();

  bool _enviando = false;

  final _serviceService  = ServiceService();
  final _empleadoService = EmpleadoService();
  final _apptService     = AppointmentService();

  @override
  void initState() {
    super.initState();

    // Modo edición/reagendar
    final c = widget.citaExistente;

    if (c != null) {
      // Cliente
      _clientNameCtrl.text  = c.clientName;
      _clientPhoneCtrl.text = c.clientPhone ?? '';
      _clientEmailCtrl.text = c.clientEmail ?? '';
      _notesCtrl.text       = c.notes ?? '';

      // Empleado
      _empleadoSeleccionado = EmpleadoSimple(      // ❌ ESTO ES EL PROBLEMA
        id: c.employeeId,
        name: c.employeeName ?? '',
      );

      // Fecha (opcional: precargar la actual, o dejar null para forzar a elegir)
      // _fechaSeleccionada = DateTime.tryParse(c.appointmentDate);

      // NO precargamos hora → para forzar a elegir nueva
      // _horaSeleccionada = c.startTime.substring(11, 16);
    } else if (widget.fechaInicial != null) {
      _fechaSeleccionada = widget.fechaInicial;
    }

    _cargarServicios().then((_) {
      // Si estamos reagendando, seleccionar el servicio que tenía
      if (c != null && mounted) {
        final servicio = _servicios.firstWhere(
              (s) => s.id == c.serviceId,
          orElse: () => _servicios.isEmpty ? _servicios.first : _servicios.first,
        );
        setState(() => _servicioSeleccionado = servicio);
      }
    });

    _cargarEmpleados();
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _clientEmailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // CARGA DE SERVICIOS
  // ──────────────────────────────────────────────
  Future<void> _cargarServicios() async {
    setState(() {
      _loadingServicios = true;
      _errorServicios = null;
    });

    try {
      final lista = await _serviceService.listar(active: true);
      if (!mounted) return;

      setState(() {
        _servicios = lista;
        _loadingServicios = false;
      });

      // 👇 Si estamos reagendando, preselecciona el servicio
      if (widget.citaExistente != null) {
        _preseleccionarServicio();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorServicios = e.toString().replaceAll('Exception: ', '');
        _loadingServicios = false;
      });
    }
  }

  void _preseleccionarServicio() {
    final c = widget.citaExistente;
    if (c == null) return;

    try {
      final servicio = _servicios.firstWhere((s) => s.id == c.serviceId);
      setState(() => _servicioSeleccionado = servicio);
    } catch (_) {
      // El servicio ya no existe o está inactivo → no preseleccionar
    }
  }

  // ──────────────────────────────────────────────
  // CARGA DE EMPLEADOS (TODOS)
  // ──────────────────────────────────────────────
  Future<void> _cargarEmpleados() async {
    setState(() => _loadingEmpleados = true);

    try {
      final lista = await _empleadoService.listaSimple();
      if (!mounted) return;

      // 👇 Buscar el empleado pendiente antes de hacer setState
      EmpleadoSimple? pendiente;
      if (_empleadoPendienteId != null) {
        for (final e in lista) {
          if (e.id == _empleadoPendienteId) {
            pendiente = e;
            break;
          }
        }
      }

      setState(() {
        _empleados = lista;
        _loadingEmpleados = false;

        if (pendiente != null) {
          _empleadoSeleccionado = pendiente;
          _empleadoPendienteId = null;
        }
      });

      // Si ya hay servicio + fecha + empleado, cargar disponibilidad
      if (_empleadoSeleccionado != null &&
          _servicioSeleccionado != null &&
          _fechaSeleccionada != null) {
        _cargarDisponibilidad();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingEmpleados = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // CARGA DE DISPONIBILIDAD
  // ──────────────────────────────────────────────
  Future<void> _cargarDisponibilidad() async {
    if (_servicioSeleccionado == null ||
        _empleadoSeleccionado == null ||
        _fechaSeleccionada == null) {
      return;
    }

    setState(() {
      _loadingSlots = true;
      _horaSeleccionada = null;
      _disponibilidad = null;
    });

    try {
      final data = await _apptService.disponibilidad(
        serviceId: _servicioSeleccionado!.id,
        employeeId: _empleadoSeleccionado!.id,
        date: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
      );

      if (!mounted) return;

      setState(() {
        _disponibilidad = data;
        _loadingSlots = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _disponibilidad = null;
        _loadingSlots = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // SELECCIONES
  // ──────────────────────────────────────────────
  void _seleccionarServicio(Service s) {
    setState(() {
      _servicioSeleccionado = s;
      _horaSeleccionada = null;
      _disponibilidad = null;
    });

    if (_empleadoSeleccionado != null && _fechaSeleccionada != null) {
      _cargarDisponibilidad();
    }
  }

  void _seleccionarEmpleado(EmpleadoSimple? e) {
    setState(() {
      _empleadoSeleccionado = e;
      _horaSeleccionada = null;
      _disponibilidad = null;
    });

    if (e != null && _fechaSeleccionada != null && _servicioSeleccionado != null) {
      _cargarDisponibilidad();
    }
  }

  void _seleccionarFecha(DateTime fecha) {
    setState(() {
      _fechaSeleccionada = fecha;
      _horaSeleccionada = null;
      _disponibilidad = null;
    });

    if (_empleadoSeleccionado != null && _servicioSeleccionado != null) {
      _cargarDisponibilidad();
    }
  }

  // ──────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 900,
        height: 700,
        child: Column(
          children: [
            _buildHeader(),
            _buildStepper(),
            const Divider(height: 1),
            Expanded(child: _buildPasoActual()),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final esReagendar = widget.citaExistente != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        children: [
          Text(
            esReagendar ? 'Reagendar cita' : 'Nueva cita',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: _enviando ? null : () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    const pasos = ['Servicio', 'Cliente', 'Fecha y hora', 'Confirmar'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < pasos.length; i++) ...[
            _buildPasoIndicador(i, pasos[i]),
            if (i < pasos.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: i < _paso ? Colors.pink : Colors.grey.shade300,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasoIndicador(int index, String label) {
    final activo     = index == _paso;
    final completado = index < _paso;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completado || activo ? Colors.pink : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: completado
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
            '${index + 1}',
            style: TextStyle(
              color: activo ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: activo ? Colors.pink : Colors.grey.shade700,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPasoActual() {
    return switch (_paso) {
      0 => _buildPaso1Servicio(),
      1 => _buildPaso2Cliente(),
      2 => _buildPaso3FechaHora(),
      3 => _buildPaso4Confirmar(),
      _ => const SizedBox(),
    };
  }

  // ══════════════════════════════════════════════
  // PASO 1: SERVICIO
  // ══════════════════════════════════════════════
  Widget _buildPaso1Servicio() {
    if (_loadingServicios) {
      return const Center(child: CircularProgressIndicator(color: Colors.pink));
    }

    if (_errorServicios != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(_errorServicios!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _cargarServicios,
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
            const Text('No hay servicios disponibles'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elige un servicio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca uno para seleccionarlo',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: _servicios.length,
              itemBuilder: (_, i) => _buildCardServicio(_servicios[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardServicio(Service s) {
    final isSelected = _servicioSeleccionado?.id == s.id;

    return GestureDetector(
      onTap: () => _seleccionarServicio(s),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.pink : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: Container(
                        color: Colors.pink.shade50,
                        child: s.photoUrl != null
                            ? Image.network(
                          s.photoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.spa_outlined,
                            color: Colors.pink.shade200,
                            size: 48,
                          ),
                        )
                            : Icon(
                          Icons.spa_outlined,
                          color: Colors.pink.shade200,
                          size: 48,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          s.priceFormatted,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.schedule, size: 11, color: Colors.grey.shade500),
                        const SizedBox(width: 2),
                        Text(
                          s.durationFormatted,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // PASO 2: CLIENTE
  // ══════════════════════════════════════════════
  Widget _buildPaso2Cliente() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos del cliente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa los datos de contacto',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _clientNameCtrl,
            label: 'Nombre completo',
            icon: Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _clientPhoneCtrl,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _clientEmailCtrl,
            label: 'Email (opcional)',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 1.5),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // PASO 3: FECHA Y HORA
  // ══════════════════════════════════════════════
  Widget _buildPaso3FechaHora() {
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empleado que atiende',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildDropdownEmpleado(),
                const SizedBox(height: 20),

                const Text(
                  'Fecha',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildCalendarioSimple(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildSlotsPanel()),
      ],
    );
  }

  Widget _buildDropdownEmpleado() {
    if (_loadingEmpleados) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pink),
        ),
      );
    }

    if (_empleados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No hay empleados disponibles',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      );
    }

    final bool existeSeleccionado =
    _empleados.any((e) => e.id == _empleadoSeleccionado?.id);

    return DropdownButtonFormField<int>(
      value: existeSeleccionado ? _empleadoSeleccionado!.id : null,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Selecciona empleado',
        prefixIcon: const Icon(Icons.person_outline, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
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
      items: _empleados.map<DropdownMenuItem<int>>((e) {
        return DropdownMenuItem<int>(
          value: e.id,
          child: Text(e.name),
        );
      }).toList(),
      onChanged: (val) {
        if (val == null) return;
        final emp = _empleados.firstWhere((e) => e.id == val);
        _seleccionarEmpleado(emp);
      },
    );
  }

  Widget _buildCalendarioSimple() {
    final hoy = DateTime.now();
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final ultimoDia = DateTime(_mesActual.year, _mesActual.month + 1, 0);
    final diasEnMes = ultimoDia.day;
    final primerDiaSemana = primerDia.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _mesActual = DateTime(_mesActual.year, _mesActual.month - 1, 1);
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy', 'es').format(_mesActual),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _mesActual = DateTime(_mesActual.year, _mesActual.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final d in ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: primerDiaSemana + diasEnMes,
            itemBuilder: (_, i) {
              if (i < primerDiaSemana) return const SizedBox();

              final dia = i - primerDiaSemana + 1;
              final fecha = DateTime(_mesActual.year, _mesActual.month, dia);
              final esHoy = fecha.year == hoy.year &&
                  fecha.month == hoy.month &&
                  fecha.day == hoy.day;
              final esPasado = fecha.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
              final esSelected = _fechaSeleccionada != null &&
                  _fechaSeleccionada!.year == fecha.year &&
                  _fechaSeleccionada!.month == fecha.month &&
                  _fechaSeleccionada!.day == fecha.day;

              return InkWell(
                onTap: esPasado ? null : () => _seleccionarFecha(fecha),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: esSelected
                        ? Colors.pink
                        : esHoy
                        ? Colors.pink.shade50
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: esSelected || esHoy
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: esPasado
                          ? Colors.grey.shade300
                          : esSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios disponibles',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _fechaSeleccionada == null
                ? 'Selecciona una fecha primero'
                : DateFormat('EEEE d MMMM', 'es').format(_fechaSeleccionada!),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          if (_loadingSlots)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: Colors.pink)),
            )
          else if (_servicioSeleccionado == null ||
              _empleadoSeleccionado == null ||
              _fechaSeleccionada == null)
            Expanded(
              child: Center(
                child: Text(
                  'Elige servicio, empleado y fecha',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_disponibilidad == null ||
                (_disponibilidad!['slots'] as List).isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No hay horarios disponibles',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              Expanded(
                child: _buildSlotsDisponibles(),
              ),
        ],
      ),
    );
  }


  Widget _buildSlotsDisponibles() {
    // Filtrar solo los disponibles
    final todosLosSlots = _disponibilidad!['slots'] as List;
    final slotsDisponibles = todosLosSlots
        .where((s) => (s as Map<String, dynamic>)['available'] == true)
        .toList();

    // Si no hay disponibles, mostrar mensaje
    if (slotsDisponibles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No hay horarios disponibles este día',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Prueba con otra fecha o empleado',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: slotsDisponibles.length,
      itemBuilder: (_, i) {
        final slot = slotsDisponibles[i] as Map<String, dynamic>;
        final start = slot['start'] as String;
        final isSelected = _horaSeleccionada == start;

        return GestureDetector(
          onTap: () => setState(() => _horaSeleccionada = start),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.pink : Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.pink : Colors.pink.shade100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                start,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.pink.shade700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  // PASO 4: CONFIRMAR
  // ══════════════════════════════════════════════
  Widget _buildPaso4Confirmar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirma tu cita',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Verifica que todo esté correcto',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _buildResumenFila(
            icono: Icons.spa_outlined,
            label: 'Servicio',
            valor: _servicioSeleccionado?.name ?? '-',
          ),
          _buildResumenFila(
            icono: Icons.attach_money,
            label: 'Precio',
            valor: _servicioSeleccionado?.priceFormatted ?? '-',
          ),
          _buildResumenFila(
            icono: Icons.schedule,
            label: 'Duración',
            valor: _servicioSeleccionado?.durationFormatted ?? '-',
          ),
          const Divider(height: 32),
          _buildResumenFila(
            icono: Icons.person,
            label: 'Atiende',
            valor: _empleadoSeleccionado?.name ?? '-',
          ),
          const Divider(height: 32),
          _buildResumenFila(
            icono: Icons.person_outline,
            label: 'Cliente',
            valor: _clientNameCtrl.text.trim(),
          ),
          if (_clientPhoneCtrl.text.trim().isNotEmpty)
            _buildResumenFila(
              icono: Icons.phone_outlined,
              label: 'Teléfono',
              valor: _clientPhoneCtrl.text.trim(),
            ),
          if (_clientEmailCtrl.text.trim().isNotEmpty)
            _buildResumenFila(
              icono: Icons.email_outlined,
              label: 'Email',
              valor: _clientEmailCtrl.text.trim(),
            ),
          const Divider(height: 32),
          _buildResumenFila(
            icono: Icons.calendar_today_outlined,
            label: 'Fecha',
            valor: _fechaSeleccionada != null
                ? DateFormat('EEEE d MMMM yyyy', 'es').format(_fechaSeleccionada!)
                : '-',
          ),
          _buildResumenFila(
            icono: Icons.access_time,
            label: 'Hora',
            valor: _horaSeleccionada ?? '-',
          ),
          const Divider(height: 32),

          const Text(
            'Notas (opcional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Alguna indicación especial...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenFila({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
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

  // ══════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_paso > 0)
            TextButton.icon(
              onPressed: _enviando ? null : () => setState(() => _paso--),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Atrás'),
            ),
          const Spacer(),
          TextButton(
            onPressed: _enviando ? null : () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _puedeAvanzar() && !_enviando ? _avanzar : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: _enviando
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(_paso == 3 ? 'Agendar cita' : 'Siguiente'),
          ),
        ],
      ),
    );
  }

  bool _puedeAvanzar() {
    return switch (_paso) {
      0 => _servicioSeleccionado != null,
      1 => _clientNameCtrl.text.trim().isNotEmpty,
      2 => _empleadoSeleccionado != null &&
          _fechaSeleccionada != null &&
          _horaSeleccionada != null,
      3 => true,
      _ => false,
    };
  }

  Future<void> _avanzar() async {
    if (_paso < 3) {
      setState(() => _paso++);
      return;
    }
    await _crearCita();
  }

  Future<void> _crearCita() async {
    if (_empleadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falta seleccionar empleado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final esReagendar = widget.citaExistente != null;

      if (esReagendar) {
        // 👇 ACTUALIZAR cita existente
        await _apptService.actualizar(
          id: widget.citaExistente!.id!,   // ✅
          serviceId:       _servicioSeleccionado!.id,
          employeeId:      _empleadoSeleccionado!.id,
          clientName:      _clientNameCtrl.text.trim(),
          clientPhone:     _clientPhoneCtrl.text.trim().isEmpty
              ? null
              : _clientPhoneCtrl.text.trim(),
          clientEmail:     _clientEmailCtrl.text.trim().isEmpty
              ? null
              : _clientEmailCtrl.text.trim(),
          appointmentDate: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
          startTime:       _horaSeleccionada!,
          notes:           _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          status:          widget.citaExistente!.status,   // mantener estado
        );
      } else {
        // 👇 CREAR nueva cita
        await _apptService.crear(
          serviceId:       _servicioSeleccionado!.id,
          employeeId:      _empleadoSeleccionado!.id,
          clientName:      _clientNameCtrl.text.trim(),
          clientPhone:     _clientPhoneCtrl.text.trim().isEmpty
              ? null
              : _clientPhoneCtrl.text.trim(),
          clientEmail:     _clientEmailCtrl.text.trim().isEmpty
              ? null
              : _clientEmailCtrl.text.trim(),
          appointmentDate: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!),
          startTime:       _horaSeleccionada!,
          notes:           _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _enviando = false);
    }
  }
}