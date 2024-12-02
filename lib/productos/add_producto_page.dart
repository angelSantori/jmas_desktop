import 'package:flutter/material.dart';

class AddProductoPage extends StatefulWidget {
  const AddProductoPage({super.key});

  @override
  State<AddProductoPage> createState() => _AddProductoPageState();
}

class _AddProductoPageState extends State<AddProductoPage> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  //final TextEditingController _unidadMedidaController = TextEditingController();
  final TextEditingController _precio1Controller = TextEditingController();
  final TextEditingController _precio2Controller = TextEditingController();
  final TextEditingController _precio3Controller = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _existenciaInicialController =
      TextEditingController();
  final TextEditingController _existenciaConFisController =
      TextEditingController();

  final List<String> _unidadMedida = ['Mts', 'Kg', 'Gr', 'Lts', 'Cm'];

  final _formKey = GlobalKey<FormState>();

  bool _isSubmitted = false;
  // ignore: unused_field
  bool _isLoading = false;

  String? _selectedUnidadMedida;

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    try {
      if (_descripcionController.text.isEmpty ||
          _costoController.text.isEmpty ||
          _existenciaController.text.isEmpty ||
          _existenciaInicialController.text.isEmpty ||
          _existenciaConFisController.text.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showError('Por favor complete todos los campos.');
      }

      if (_formKey.currentState?.validate() ?? false) {}
    } catch (e) {}
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade900),
              const SizedBox(width: 5),
              const Text(
                "Error",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showOk(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.beenhere,
                color: Colors.green.shade900,
              ),
              const SizedBox(width: 5),
              const Text(
                "Éxito",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar producto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 100, right: 100),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Descripción
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Descripción: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción del producto',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _descripcionController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por facor ingresa una descripción';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Costo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Costo: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _costoController,
                          decoration: InputDecoration(
                            labelText: 'Costo del producto',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _costoController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un costo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Unidad Medida
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Unidad de Medida: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnidadMedida,
                          decoration: InputDecoration(
                            labelText: 'Unidad de Medida',
                            border: const OutlineInputBorder(),
                          ),
                          items: _unidadMedida.map((unidad) {
                            return DropdownMenuItem(
                              value: unidad,
                              child: Text(unidad),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnidadMedida = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona una unidad de medida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Precio 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Precio 1: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _precio1Controller,
                          decoration: InputDecoration(
                            labelText: 'Precio 1',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _precio1Controller.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un precio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Precio 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Precio 2: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _precio2Controller,
                          decoration: InputDecoration(
                            labelText: 'Precio 2',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _precio2Controller.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un precio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Precio 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Precio 3: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _precio3Controller,
                          decoration: InputDecoration(
                            labelText: 'Precio 3',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _precio3Controller.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un precio';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Existencia
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Existencia: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _existenciaController,
                          decoration: InputDecoration(
                            labelText: 'Existencia',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _existenciaController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa las existencias del producto';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Existencia Inicial
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Existencia inicial: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _existenciaInicialController,
                          decoration: InputDecoration(
                            labelText: 'Existencia inicial',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _existenciaInicialController
                                                .text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa las existencias inicial del producto';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Existencia Conteo Físico
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Existencia conteo físico: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _existenciaConFisController,
                          decoration: InputDecoration(
                            labelText: 'Existencia',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _existenciaConFisController
                                                .text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa las existencias de conteo físico del producto';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Botón para enviar el formulario
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        textStyle: const TextStyle(
                          fontSize: 15,
                        )),
                    child: const Text(
                      'Registrar Producto',
                      style: TextStyle(
                        color: Colors.white,
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
