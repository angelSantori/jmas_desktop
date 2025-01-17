import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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

  final List<String> _unidadMedida = [
    'Pza',
    'Mto',
    'Mtrs',
    'Saco',
    'Kg',
    'Cilin',
    'Lts',
    'Caja',
    'Gfon'
  ];

  final _formKey = GlobalKey<FormState>();

  // ignore: unused_field
  bool _isSubmitted = false;
  // ignore: unused_field
  bool _isLoading = false;

  String? _selectedUnidadMedida;
  XFile? _selectedImage;
  String? _encodedImage;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _encodedImage = base64Encode(bytes);
      });
    }
  }

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImage == null) {
        showAdvertence(context, 'Imagen es obligatoria');
        setState(() {
          _isSubmitted = false;
          _isLoading = false;
        });
        return;
      }
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
      _isSubmitted = false;
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
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Descripción
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _descripcionController,
                          labelText: 'Descripción',
                          prefixIcon: Icons.arrow_forward_ios_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Descripción obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Costo
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _costoController,
                          labelText: 'Costo',
                          prefixIcon: Icons.monetization_on_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Costo obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 30),

                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedUnidadMedida,
                          labelText: 'Unidad de Medida',
                          items: _unidadMedida,
                          onChanged: (value) {
                            setState(() {
                              _selectedUnidadMedida = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unidad de medida obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  //Precios
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Precio 1
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _precio1Controller,
                          labelText: 'Precio 1',
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Precio 1 obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Precio 2
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _precio2Controller,
                          labelText: 'Precio 2',
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Precio 2 obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Precio 3
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _precio3Controller,
                          labelText: 'Precio 3',
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Precio 3 obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  //Existencia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Existencia
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _existenciaController,
                          labelText: 'Existencias',
                          prefixIcon: Icons.numbers_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Existencias obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Existencia inicial
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _existenciaInicialController,
                          labelText: 'Existencias iniciales',
                          prefixIcon: Icons.numbers_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Existencias iniciales obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Existencia conteo fisico
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _existenciaConFisController,
                          labelText: 'Existencias conteo físico',
                          prefixIcon: Icons.numbers_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Existencias conteo físico obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  //Seleccionar imagen
                  CustomImagePicker(
                    onPickImage: _pickImage,
                    selectedImage: _selectedImage,
                  ),

                  const SizedBox(height: 50),

                  //Botón para enviar el formulario
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isLoading ? Colors.grey : Colors.blue.shade900,
                        textStyle: const TextStyle(
                          fontSize: 20,
                        )),
                    child: _isLoading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Cargando...'),
                            ],
                          )
                        : const Text(
                            'Registrar Producto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
