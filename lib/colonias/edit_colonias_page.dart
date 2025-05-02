import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditColoniasPage extends StatefulWidget {
  final Colonias colonia;
  const EditColoniasPage({super.key, required this.colonia});

  @override
  State<EditColoniasPage> createState() => _EditColoniasPageState();
}

class _EditColoniasPageState extends State<EditColoniasPage> {
  final ColoniasController _coloniasController = ColoniasController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreColoniaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreColoniaController =
        TextEditingController(text: widget.colonia.nombreColonia);
  }

  @override
  void dispose() {
    _nombreColoniaController.dispose();
    super.dispose();
  }

  Future<void> _saveColonia() async {
    setState(() => _isLoading = true);

    if (_formKey.currentState!.validate()) {
      final updateColonia =
          widget.colonia.copyWith(nombreColonia: _nombreColoniaController.text);

      final result = await _coloniasController.editColonia(updateColonia);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Colonia editada correctamente');
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
        title: Text('Editar colonia: ${widget.colonia.nombreColonia}'),
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
                    controller: _nombreColoniaController,
                    labelText: 'Nombre de Colonia',
                    validator: (colName) {
                      if (colName == null || colName.isEmpty) {
                        return 'Nombre de colonia obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Bootón Guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveColonia,
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
