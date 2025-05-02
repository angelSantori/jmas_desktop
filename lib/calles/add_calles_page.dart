import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddCallesPage extends StatefulWidget {
  const AddCallesPage({super.key});

  @override
  State<AddCallesPage> createState() => _AddCallesPageState();
}

class _AddCallesPageState extends State<AddCallesPage> {
  final CallesController _callesController = CallesController();

  final TextEditingController _nombreCalle = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newCalle = Calles(
          idCalle: 0,
          calleNombre: _nombreCalle.text,
        );

        final success = await _callesController.addCalles(newCalle);

        if (success) {
          showOk(context, 'Calle registrada exitosamente');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar la colonia');
        }
      } catch (e) {
        showAdvertence(
            context, 'Por fabor complete todos los campos correctamente.');
      }
    } else {
      showAdvertence(
          context, 'Por fabor complete todos los campos correctamente.');
    }
    setState(() => _isLoading = false);
  }

  void _clearForm() {
    _nombreCalle.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Calle'),
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
                    controller: _nombreCalle,
                    labelText: 'Nombre de calle',
                    validator: (nomCall) {
                      if (nomCall == null || nomCall.isEmpty) {
                        return 'Nombre obligatorio';
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
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
