import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entidades_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddEntidadPage extends StatefulWidget {
  const AddEntidadPage({super.key});

  @override
  State<AddEntidadPage> createState() => _AddEntidadPageState();
}

class _AddEntidadPageState extends State<AddEntidadPage> {
  final EntidadesController _entidadesController = EntidadesController();

  final TextEditingController _nombreController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final entidad = Entidades(
          id_Entidad: 0,
          entidad_Nombre: _nombreController.text,
        );

        final success = await _entidadesController.addEntidad(entidad);

        if (success) {
          showOk(context, 'Entidad registrada exitosamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar la entidad.');
        }
      } catch (e) {
        showAdvertence(
            context, 'Por favor complete todos los campos correctamente.');
      }
    } else {
      showAdvertence(
          context, 'Por favor completa todos los campos obligatorios.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clearForm() {
    _nombreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Entidad'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Nombre
                  CustomTextFielTexto(
                    controller: _nombreController,
                    labelText: 'Nombre',
                    validator: (nomEnt) {
                      if (nomEnt == null || nomEnt.isEmpty) {
                        return 'Nombre obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Botón
                  ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Registrar entidad',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
