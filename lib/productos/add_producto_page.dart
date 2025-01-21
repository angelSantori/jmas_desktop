import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
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
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _minController = TextEditingController();

  final ProveedoresController _proveedoresController = ProveedoresController();
  List<Proveedores> _proveedores = [];
  Proveedores? _selectedProveedor;

  final List<String> _unMedEntrada = [
    'Caja',
    'Paquete',
    'Saco',
    'Tarima',
    'Contenedor',
    'Bolsa',
    'Tambor',
    'Rollo',
    'Pallet',
    'Barril',
  ];

  final List<String> _unMedSalida = [
    'Pza (Pieza)',
    'Kg (Kilogramo)',
    'Lts (Litros)',
    'Mto (Metro)',
    'Cilin (Cilindro)',
    'Gfon (Galón)',
    'Gr (Gramos)',
    'Ml (Mililitros)',
    'Un (Unidad)'
  ];

  final _formKey = GlobalKey<FormState>();

  // ignore: unused_field
  bool _isSubmitted = false;
  // ignore: unused_field
  bool _isLoading = false;

  String? _selectedUnMedSalida;
  String? _selectedUnMedEntrada;
  XFile? _selectedImage;
  String? _encodedImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProveedores();
  }

  Future<void> _loadProveedores() async {
    List<Proveedores> proveedores =
        await _proveedoresController.listProveedores();
    setState(() {
      _proveedores = proveedores;
    });
  }

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
          prodDescripcion: _descripcionController.text,
          prodExistencia: double.parse(_existenciaController.text),
          prodMax: double.parse(_maxController.text),
          prodMin: double.parse(_minController.text),
          prodCosto: double.parse(_costoController.text),
          prodUMedSalida: _selectedUnMedSalida,
          prodUMedEntrada: _selectedUnMedEntrada,
          prodPrecio: double.parse(_precioController.text),
          prodImgB64: _encodedImage,
          idProveedor: _selectedProveedor?.id_Proveedor ?? 0,
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
    _formKey.currentState!.reset();
    _descripcionController.clear();
    _costoController.clear();
    _precioController.clear();
    _existenciaController.clear();
    _maxController.clear();
    _minController.clear();
    setState(() {
      _selectedUnMedEntrada = null;
      _selectedUnMedSalida = null;
      _selectedProveedor = null;
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
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Precio
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _precioController,
                          labelText: 'Precio',
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Precio obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Max
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _maxController,
                          labelText: 'Máximas unidades',
                          prefixIcon: Icons.numbers_rounded,
                          validator: (max) {
                            if (max == null || max.isEmpty) {
                              return 'Máximas unidades obligatorias.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Min
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _minController,
                          labelText: 'Mínimas unidades',
                          prefixIcon: Icons.numbers_rounded,
                          validator: (min) {
                            if (min == null || min.isEmpty) {
                              return 'Mínimas unidades obligatorias.';
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
                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedUnMedEntrada,
                          labelText: 'Unidad de Medida Entrada',
                          items: _unMedEntrada,
                          onChanged: (value) {
                            setState(() {
                              _selectedUnMedEntrada = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unidad de medida entrada obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //UnMedSalida
                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedUnMedSalida,
                          labelText: 'Unidad de Medida Salida',
                          items: _unMedSalida,
                          onChanged: (value) {
                            setState(() {
                              _selectedUnMedSalida = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Unidad de medida salida obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Proveedor
                      Expanded(
                        child: CustomListaDesplegableTipo(
                          value: _selectedProveedor,
                          labelText: 'Proveedor',
                          items: _proveedores,
                          onChanged: (prov) {
                            setState(() {
                              _selectedProveedor = prov;
                            });
                          },
                          validator: (prov) {
                            if (prov == null) {
                              return 'Proveedor obligatorio.';
                            }
                            return null;
                          },
                          itemLabelBuilder: (prov) =>
                              prov.proveedor_Name ?? 'Sin nombre',
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
