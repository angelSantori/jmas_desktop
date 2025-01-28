import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditAlmacenPage extends StatefulWidget {
  final Almacenes almacen;
  const EditAlmacenPage({super.key, required this.almacen});

  @override
  State<EditAlmacenPage> createState() => _EditAlmacenPageState();
}

class _EditAlmacenPageState extends State<EditAlmacenPage> {
  final AlmacenesController _almacenesController = AlmacenesController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.almacen.almacen_Nombre);
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
      final updateAlmacen = widget.almacen.copyWith(
        id_Almacen: widget.almacen.id_Almacen,
        almacen_Nombre: _nameController.text,
      );

      final result = await _almacenesController.editAlmacen(updateAlmacen);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Almacen editada correctamente.');
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
        title: Text('Editar Almacen: ${widget.almacen.almacen_Nombre}'),
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
                        return 'Nombre de almacen obligatorio.';
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
