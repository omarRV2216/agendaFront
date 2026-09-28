import 'package:flutter/material.dart';
import '../../../../../models/role.dart';
import '../../../../../services/empleado_service.dart';

class EditarEmpleadoDialog extends StatefulWidget {
  final Map<String, dynamic> empleado;   // 👈 recibe el empleado a editar

  const EditarEmpleadoDialog({super.key, required this.empleado});

  static Future<bool?> show(BuildContext context, Map<String, dynamic> empleado) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditarEmpleadoDialog(empleado: empleado),
    );
  }

  @override
  State<EditarEmpleadoDialog> createState() => _EditarEmpleadoDialogState();
}

class _EditarEmpleadoDialogState extends State<EditarEmpleadoDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;

  final _service = EmpleadoService();

  // ──────────────────────────────────────────
  // Roles dinámicos
  // ──────────────────────────────────────────
  List<Role> _roles = [];
  int? _selectedRoleId;
  bool _loadingRoles = true;
  String? _rolesError;

  String _gender = 'F';
  bool _active = true;
  bool _loading = false;
  bool _obscurePassword = true;

  // 👇 Datos originales del empleado (para el payload)
  late final int _empleadoId;

  @override
  void initState() {
    super.initState();

    // 👇 Precargar datos del empleado
    final e = widget.empleado;

    _empleadoId = e['id'];

    _nameController = TextEditingController(
      text: (e['name'] ?? '').toString(),
    );
    _usernameController = TextEditingController(
      text: (e['username'] ?? '').toString(),
    );
    _phoneController = TextEditingController(
      text: (e['phone'] ?? '').toString(),
    );
    // ⚠️ Password NO se precarga por seguridad (vacío)
    _passwordController = TextEditingController();

    _gender = (e['gender'] ?? 'F').toString();
    _active = e['active'] == 1 || e['active'] == true;
    _selectedRoleId = e['role_id'] != null
        ? int.tryParse(e['role_id'].toString())
        : null;

    _cargarRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Cargar roles
  // ──────────────────────────────────────────────
  Future<void> _cargarRoles() async {
    setState(() {
      _loadingRoles = true;
      _rolesError = null;
    });

    try {
      final roles = await _service.roles();

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _loadingRoles = false;

        // Si _selectedRoleId es null, preseleccionar "empleado"
        if (_selectedRoleId == null && roles.isNotEmpty) {
          final empleado = roles.firstWhere(
                (r) => r.name == 'empleado',
            orElse: () => roles.first,
          );
          _selectedRoleId = empleado.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rolesError = e.toString().replaceAll('Exception: ', '');
        _loadingRoles = false;
      });
    }
  }

  // ──────────────────────────────────────────────
  // Submit
  // ──────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un rol'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 👇 Si el password está vacío, no se manda (no se cambia)
      final password = _passwordController.text.trim();

      await _service.actualizar(
        id: _empleadoId,
        roleId: _selectedRoleId!,
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        password: password.isEmpty ? null : password,
        phone: _phoneController.text.trim(),
        gender: _gender,
        active: _active,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _close() {
    if (_loading) return;
    Navigator.pop(context, false);
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 500 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: AbsorbPointer(
          absorbing: _loading,
          child: AnimatedOpacity(
            opacity: _loading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildField(
                            controller: _nameController,
                            label: 'Nombre completo',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? 'Mínimo 3 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _usernameController,
                            label: 'Usuario',
                            icon: Icons.alternate_email,
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? 'Mínimo 3 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                            // 👇 Password opcional al editar
                            validator: (v) {
                              // Si está vacío, OK (no se cambia)
                              if (v == null || v.trim().isEmpty) return null;
                              // Si se escribió, mínimo 6
                              if (v.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Deja vacío para no cambiar la contraseña',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                            validator: (v) =>
                            (v == null || v.length != 10) ? 'Debe tener 10 dígitos' : null,
                          ),
                          const SizedBox(height: 14),

                          // 👇 Dropdown de rol y género
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildRoleDropdown()),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: _decoration('Género', Icons.wc_outlined),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'F', child: Text('Femenino')),
                                    DropdownMenuItem(value: 'M', child: Text('Masculino')),
                                    DropdownMenuItem(value: 'O', child: Text('Otro')),
                                  ],
                                  onChanged: (v) => setState(() => _gender = v ?? 'F'),
                                  validator: (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Activo'),
                            subtitle: Text(
                              _active
                                  ? 'El empleado puede iniciar sesión'
                                  : 'Acceso bloqueado',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            value: _active,
                            activeColor: Colors.pink,
                            onChanged: (v) => setState(() => _active = v),
                          ),
                          const SizedBox(height: 16),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Dropdown de roles (igual que en create)
  // ──────────────────────────────────────────────
  Widget _buildRoleDropdown() {
    // Cargando
    if (_loadingRoles) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pink),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargando roles...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Error
    if (_rolesError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _rolesError!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: _cargarRoles,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Sin roles
    if (_roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No hay roles disponibles',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // OK → dropdown
    return DropdownButtonFormField<int>(
      value: _selectedRoleId,
      decoration: _decoration('Rol', Icons.badge_outlined),
      isExpanded: true,
      items: _roles.map((role) {
        return DropdownMenuItem<int>(
          value: role.id,
          child: Text(role.displayName),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedRoleId = v),
      validator: (v) => v == null ? 'Selecciona un rol' : null,
    );
  }

  // ──────────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit, color: Colors.pink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar empleado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Actualiza los datos del empleado.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _close,
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Botones
  // ──────────────────────────────────────────────
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _close,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: (_loading || _loadingRoles) ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Guardar cambios',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────
  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.pink, width: 1.5),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      decoration: _decoration(label, icon, suffix: suffix),
    );
  }
}