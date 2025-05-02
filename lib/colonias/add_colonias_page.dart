import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddColoniasPage extends StatefulWidget {
  const AddColoniasPage({super.key});

  @override
  State<AddColoniasPage> createState() => _AddColoniasPageState();
}

class _AddColoniasPageState extends State<AddColoniasPage> {
  final ColoniasController _coloniasController = ColoniasController();
  final TextEditingController _nombreColonia = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newColonia = Colonias(
          idColonia: 0,
          nombreColonia: _nombreColonia.text,
        );

        final success = await _coloniasController.addColonia(newColonia);

        if (success) {
          showOk(context, 'Colonia registrada exitosamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar la colonia');
        }
      } catch (e) {
        showAdvertence(
            context, 'Por favor complete todos los campos correctamente.');
      }
    } else {
      showAdvertence(
          context, 'Por favor completa todos los campos obligatorios.');
    }

    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _nombreColonia.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Colonia'),
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
                    controller: _nombreColonia,
                    labelText: 'Nombre de colonia',
                    validator: (nomCol) {
                      if (nomCol == null || nomCol.isEmpty) {
                        return 'Nombre obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Botón Guardar
                  ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        elevation: 8,
                        shadowColor: Colors.blue.shade900,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Registrar Colonia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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
