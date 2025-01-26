import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entidades_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditEntidadPage extends StatefulWidget {
  final Entidades entidad;
  const EditEntidadPage({super.key, required this.entidad});

  @override
  State<EditEntidadPage> createState() => _EditEntidadPageState();
}

class _EditEntidadPageState extends State<EditEntidadPage> {
  final EntidadesController _entidadesController = EntidadesController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.entidad.entidad_Nombre);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      final updateEntidad = widget.entidad.copyWith(
        id_Entidad: widget.entidad.id_Entidad,
        entidad_Nombre: _nameController.text,
      );

      final result = await _entidadesController.editEntidad(updateEntidad);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Entidad editada correctamente.');
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Entidad: ${widget.entidad.entidad_Nombre}'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Nomnbre
                  CustomTextFielTexto(
                    controller: _nameController,
                    labelText: 'Nombre',
                    validator: (entName) {
                      if (entName == null || entName.isEmpty) {
                        return 'Nombre de entidad obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Botón
                  ElevatedButton(
                      onPressed: _isLoading ? null : _saveChange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
