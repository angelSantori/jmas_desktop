import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddProductoPage extends StatefulWidget {
  const AddProductoPage({super.key});

  @override
  State<AddProductoPage> createState() => _AddProductoPageState();
}

class _AddProductoPageState extends State<AddProductoPage> {
  final ProductosController _productosController = ProductosController();

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
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
  File? _selectedImage;
  String? _encodedImage;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final producto = Productos(
          id_Producto: 0,
          producto_Descripcion: _descripcionController.text,
          producto_Costo: double.parse(_costoController.text),
          producto_UMedida: _selectedUnidadMedida!,
          producto_Precio1: double.parse(_precio1Controller.text),
          producto_Precio2: double.parse(_precio2Controller.text),
          producto_Precio3: double.parse(_precio3Controller.text),
          producto_Existencia: double.parse(_existenciaController.text),
          producto_ExistenciaInicial:
              double.parse(_existenciaInicialController.text),
          producto_ExistenciaConFis:
              double.parse(_existenciaConFisController.text),
          producto_ImgBase64: _encodedImage,
        );
        final success = await _productosController.addProducto(producto);

        if (success) {
          showOk(context, 'Producto registrado exitosamente');
          _formKey.currentState?.reset();
          _clearForm();
        } else {
          showError(context, "Hubo un problema al registrar el producto.");
        }
      } catch (e) {
        showAdvertence(
            context, "Por favor complete todos los campos correctamente.");
      }
    } else {
      showAdvertence(
          context, "Por favor completa todos los campos obligatorios.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clearForm() {
    _descripcionController.clear();
    _costoController.clear();
    _precio1Controller.clear();
    _precio2Controller.clear();
    _precio3Controller.clear();
    _existenciaController.clear();
    _existenciaInicialController.clear();
    _existenciaConFisController.clear();
    setState(() {
      _selectedUnidadMedida = null;
      _selectedImage = null;
    });
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
                  const SizedBox(height: 10),
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
                              return 'Por favor ingresa una descripción';
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
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
                          decoration: const InputDecoration(
                            labelText: 'Unidad de Medida',
                            border: OutlineInputBorder(),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Precio 3
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  //Seleccionar imagen
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagen: ',
                        style: TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Seleccionar imagen'),
                      ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    Image.file(
                      _selectedImage!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
                  ],

                  TextFormField(
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (_selectedImage == null) {
                        return 'Imagen de producto es obligatoria.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(fontSize: 0, height: 0),
                  ),

                  const SizedBox(height: 50),

                  //Botón para enviar el formulario
                  ElevatedButton(
                    onPressed: _submitForm,
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
