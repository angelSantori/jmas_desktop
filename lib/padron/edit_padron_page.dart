import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditPadronPage extends StatefulWidget {
  final Padron padron;
  const EditPadronPage({super.key, required this.padron});

  @override
  State<EditPadronPage> createState() => _EditPadronPageState();
}

class _EditPadronPageState extends State<EditPadronPage> {
  final PadronController _padronController = PadronController();
  final _formkey = GlobalKey<FormState>();

  late TextEditingController _padronNombre;
  late TextEditingController _padronDireccion;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _padronNombre = TextEditingController(text: widget.padron.padronNombre);
    _padronDireccion =
        TextEditingController(text: widget.padron.padronDireccion);
  }

  @override
  void dispose() {
    _padronNombre.dispose();
    _padronDireccion.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      final updatePadron = widget.padron.copyWith(
        padronNombre: _padronNombre.text,
        padronDireccion: _padronDireccion.text,
      );

      final result = await _padronController.editPadron(updatePadron);
      setState(() {
        _isLoading = false;
      });
      if (result) {
        await showOk(context, 'Padron editado correctamente.');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al editar el padron');
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
        title: const Text('Editar Padron'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Nombre
                  CustomTextFielTexto(
                    controller: _padronNombre,
                    labelText: 'Nombre',
                    validator: (padNam) {
                      if (padNam == null || padNam.isEmpty) {
                        return 'Nombre padron obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Dirección
                  CustomTextFielTexto(
                    controller: _padronDireccion,
                    labelText: 'Dirección',
                    validator: (padDir) {
                      if (padDir == null || padDir.isEmpty) {
                        return 'Dirección padron obligatorio';
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
                        elevation: 8,
                        shadowColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.blue.shade900)
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                ],
              )),
        ),
      ),
    );
  }
}
