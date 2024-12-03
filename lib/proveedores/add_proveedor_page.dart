import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddProveedorPage extends StatefulWidget {
  const AddProveedorPage({super.key});

  @override
  State<AddProveedorPage> createState() => _AddProveedorPageState();
}

class _AddProveedorPageState extends State<AddProveedorPage> {
  final ProveedoresController _proveedoresController = ProveedoresController();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isSubmitted = false;
  bool _isLoading = false;

  void _clearForm() {
    _nombreController.clear();
    _direccionController.clear();
    _telefonoController.clear();
  }

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final proveedor = Proveedores(
          id_Proveedor: 0,
          proveedor_Name: _nombreController.text,
          proveedor_Address: _direccionController.text,
          proveedor_Phone: _telefonoController.text,
        );

        final success = await _proveedoresController.addProveedor(proveedor);

        if (success) {
          showOk(context, 'Proveedor registrado exitosamente.');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, 'Hubo un problema al registrar al proveedor.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Proveedor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 100, right: 100),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Nombre
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Nombre: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del proveedor',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _nombreController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Dirección
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Dirección: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _direccionController,
                          decoration: InputDecoration(
                            labelText: 'Dirección del proveedor',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _direccionController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una dirección';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Telefono
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Telefóno: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _telefonoController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del proveedor',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _telefonoController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        textStyle: const TextStyle(
                          fontSize: 15,
                        )),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Registrar Proveedor',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
