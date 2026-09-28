import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../models/service.dart';
import '../../../../../services/service_service.dart';

class EditarServicioDialog extends StatefulWidget {
  final Service servicio;

  const EditarServicioDialog({super.key, required this.servicio});

  static Future<bool?> show(BuildContext context, Service servicio) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditarServicioDialog(servicio: servicio),
    );
  }

  @override
  State<EditarServicioDialog> createState() => _EditarServicioDialogState();
}

class _EditarServicioDialogState extends State<EditarServicioDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;

  final _service = ServiceService();
  final _picker = ImagePicker();

  XFile? _photoFile;
  Uint8List? _photoBytes;
  late bool _active;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final s = widget.servicio;
    _nameController = TextEditingController(text: s.name);
    _descriptionController = TextEditingController(text: s.description ?? '');
    _priceController = TextEditingController(text: s.price.toStringAsFixed(2));
    _durationController = TextEditingController(text: s.durationMinutes.toString());
    _active = s.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Selector de imagen
  // ──────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoFile = picked;
          _photoBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showImageSourceSheet() {
    final hasOldImage = widget.servicio.photoPath != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Cambiar / elegir imagen
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.pink),
              title: Text(hasOldImage ? 'Cambiar imagen' : 'Elegir imagen'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),

            // Descartar cambio (solo si cambió imagen)
            if (_photoBytes != null)
              ListTile(
                leading: const Icon(Icons.undo, color: Colors.orange),
                title: const Text('Descartar cambio'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoFile = null;
                    _photoBytes = null;
                  });
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Submit
  // ──────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.actualizar(
        id: widget.servicio.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationMinutes: int.parse(_durationController.text.trim()),
        active: _active,
        photoBytes: _photoBytes,
        photoFileName: _photoFile?.name,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          _buildImagePicker(),
                          const SizedBox(height: 20),
                          _buildField(
                            controller: _nameController,
                            label: 'Nombre del servicio',
                            icon: Icons.spa_outlined,
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? 'Mínimo 3 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _descriptionController,
                            label: 'Descripción',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _priceController,
                                  label: 'Precio',
                                  icon: Icons.attach_money,
                                  keyboard: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Requerido';
                                    final n = double.tryParse(v);
                                    if (n == null || n < 0) return 'Inválido';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _durationController,
                                  label: 'Duración (min)',
                                  icon: Icons.schedule,
                                  keyboard: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Requerido';
                                    final n = int.tryParse(v);
                                    if (n == null || n < 15) return 'Mín. 15';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Activo'),
                            subtitle: Text(
                              _active ? 'Visible para agendar' : 'Oculto',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            value: _active,
                            activeColor: Colors.pink,
                            onChanged: (v) => setState(() => _active = v),
                          ),
                          const SizedBox(height: 12),
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
  // Selector de imagen (nueva o existente)
  // ──────────────────────────────────────────────
  Widget _buildImagePicker() {
    final hasNewImage = _photoBytes != null;
    final hasOldImage = widget.servicio.photoPath != null;
    final hasImage = hasNewImage || hasOldImage;

    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSheet,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasImage ? Colors.pink.shade200 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: !hasImage
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: Colors.pink.shade300,
              ),
              const SizedBox(height: 8),
              Text(
                'Subir foto',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
              : Stack(
            fit: StackFit.expand,
            children: [
              if (hasNewImage)
                Image.memory(_photoBytes!, fit: BoxFit.cover)
              else
                Image.network(
                  widget.servicio.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
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
                  'Editar servicio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Actualiza los datos del servicio.',
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
            onPressed: _loading ? null : _submit,
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
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
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
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      maxLines: maxLines,
      decoration: _decoration(label, icon),
    );
  }
}