import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditJuntaPage extends StatefulWidget {
  final Juntas junta;
  const EditJuntaPage({super.key, required this.junta});

  @override
  State<EditJuntaPage> createState() => _EditJuntaPageState();
}

class _EditJuntaPageState extends State<EditJuntaPage> {
  final JuntasController _juntasController = JuntasController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _encargadoController;
  late TextEditingController _cuentaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.junta.junta_Name);
    _phoneController = TextEditingController(text: widget.junta.junta_Telefono);
    _encargadoController =
        TextEditingController(text: widget.junta.junta_Encargado);
    _cuentaController = TextEditingController(text: widget.junta.junta_Cuenta);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _encargadoController.dispose();
    _cuentaController.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      final updateJunta = widget.junta.copyWith(
          junta_Name: _nameController.text,
          junta_Telefono: _phoneController.text,
          junta_Encargado: _encargadoController.text,
          junta_Cuenta: _cuentaController.text);

      final result = await _juntasController.editJunta(updateJunta);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Junta editada correctamente');
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
        title: Text('Editar junta: ${widget.junta.junta_Name}'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Nombre
                  CustomTextFielTexto(
                    controller: _nameController,
                    labelText: 'Nombre de junta',
                    validator: (jntName) {
                      if (jntName == null || jntName.isEmpty) {
                        return 'Nombre de junta obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Phone
                  CustomTextFieldNumero(
                    controller: _phoneController,
                    prefixIcon: Icons.phone,
                    labelText: 'Teléfono',
                    validator: (jntPh) {
                      if (jntPh == null || jntPh.isEmpty) {
                        return 'Teléfono obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Encargado
                  CustomTextFielTexto(
                    controller: _encargadoController,
                    prefixIcon: Icons.person,
                    labelText: 'Encargado',
                    validator: (encJnt) {
                      if (encJnt == null || encJnt.isEmpty) {
                        return 'Encargado obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Cuenta
                  CustomTextFielTexto(
                    controller: _cuentaController,
                    prefixIcon: Icons.numbers,
                    labelText: 'Cuenta',
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
