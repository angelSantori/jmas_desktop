import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddJuntaPage extends StatefulWidget {
  const AddJuntaPage({super.key});

  @override
  State<AddJuntaPage> createState() => _AddJuntaPageState();
}

class _AddJuntaPageState extends State<AddJuntaPage> {
  final JuntasController _juntasController = JuntasController();

  final TextEditingController _nombreController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final junta = Juntas(
          id_Junta: 0,
          junta_Name: _nombreController.text,
        );

        final success = await _juntasController.addJunta(junta);

        if (success) {
          showOk(context, 'Entidad registrada exitosamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar la junta.');
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
        title: const Text('Agregar entidad'),
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
                  //Name
                  CustomTextFielTexto(
                    controller: _nombreController,
                    labelText: 'Nombre junta',
                    validator: (nomJnt) {
                      if (nomJnt == null || nomJnt.isEmpty) {
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
                              'Registrar junta',
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
