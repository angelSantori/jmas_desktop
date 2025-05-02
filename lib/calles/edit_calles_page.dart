import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditCallesPage extends StatefulWidget {
  final Calles calle;
  const EditCallesPage({super.key, required this.calle});

  @override
  State<EditCallesPage> createState() => _EditCallesPageState();
}

class _EditCallesPageState extends State<EditCallesPage> {
  final CallesController _callesController = CallesController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCalleText;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCalleText = TextEditingController(text: widget.calle.calleNombre);
  }

  @override
  void dispose() {
    _nombreCalleText.dispose();
    super.dispose();
  }

  Future<void> _saveCalle() async {
    setState(() => _isLoading = true);

    if (_formKey.currentState!.validate()) {
      final updateCalle =
          widget.calle.copyWith(calleNombre: _nombreCalleText.text);

      final result = await _callesController.editCalles(updateCalle);

      setState(() => _isLoading = false);

      if (result) {
        await showOk(context, 'Calle editada correctamente');
        Navigator.pop(context, true);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar calle: ${widget.calle.calleNombre}'),
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
                  //Nombre
                  CustomTextFielTexto(
                    controller: _nombreCalleText,
                    labelText: 'Nombre de Calle',
                    validator: (callName) {
                      if (callName == null || callName.isEmpty) {
                        return 'Nombre de calle obligatoria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Botón Guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveCalle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
