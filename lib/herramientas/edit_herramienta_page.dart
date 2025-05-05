import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/herramientas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditHerramientaPage extends StatefulWidget {
  final Herramientas herramienta;
  const EditHerramientaPage({super.key, required this.herramienta});

  @override
  State<EditHerramientaPage> createState() => _EditHerramientaPageState();
}

class _EditHerramientaPageState extends State<EditHerramientaPage> {
  final HerramientasController _herramientasController =
      HerramientasController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _htaNombreController;

  String? _selectedEstado;
  final List<String> _estados = ['Disponible', 'Prestada', 'Mantenimiento'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _htaNombreController =
        TextEditingController(text: widget.herramienta.htaNombre);

    _selectedEstado = widget.herramienta.htaEstado;
  }

  @override
  void dispose() {
    _htaNombreController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedHta = widget.herramienta.copyWith(
        htaNombre: _htaNombreController.text.trim(),
        htaEstado: _selectedEstado,
      );

      final result = await _herramientasController.editHta(updatedHta);

      if (!mounted) return;

      if (result) {
        // Limpiar caché después de editar
        HerramientasController.cacheHerramientas = null;

        await showOk(context, 'Herramienta actualizada correctamente');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al actualizar la herramienta');
      }
    } catch (e) {
      if (!mounted) return;
      showError(context, 'Error inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Editar Herramienta con ID: ${widget.herramienta.idHerramienta}'),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Nombre
              CustomTextFielTexto(
                controller: _htaNombreController,
                labelText: 'Nombre de Herramienta',
                prefixIcon: Icons.arrow_forward_ios_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de herramienta obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              //Estado
              CustomListaDesplegable(
                value: _selectedEstado,
                labelText: 'Estado',
                items: _estados,
                onChanged: (value) {
                  setState(() {
                    _selectedEstado = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Estado de herramienta onligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              //Botón Save
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
