import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/herramientas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddHerramientaPage extends StatefulWidget {
  const AddHerramientaPage({super.key});

  @override
  State<AddHerramientaPage> createState() => _AddHerramientaPageState();
}

class _AddHerramientaPageState extends State<AddHerramientaPage> {
  final HerramientasController _herramientasController =
      HerramientasController();

  final TextEditingController _htaNombreController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newHta = Herramientas(
            idHerramienta: 0,
            htaNombre: _htaNombreController.text,
            htaEstado: 'Disponible');

        final success = await _herramientasController.addHta(newHta);

        if (success) {
          showOk(context, 'Herramienta registrada exitosamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar la herramienta');
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
    _htaNombreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Herramienta'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Nombre
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _htaNombreController,
                          labelText: 'Nombre de Herramienta',
                          validator: (nomHta) {
                            if (nomHta == null || nomHta.isEmpty) {
                              return 'Nombre obligatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  //Botón Guardar Save
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
