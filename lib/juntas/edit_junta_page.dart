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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.junta.junta_Name);
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
      final updateJunta = widget.junta.copyWith(
        junta_Name: _nameController.text,
      );

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
