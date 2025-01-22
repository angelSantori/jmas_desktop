import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditProductoPage extends StatefulWidget {
  final Productos producto;
  const EditProductoPage({super.key, required this.producto});

  @override
  State<EditProductoPage> createState() => _EditProductoPageState();
}

class _EditProductoPageState extends State<EditProductoPage> {
  final ProductosController _productosController = ProductosController();

  late TextEditingController _descripcionController;
  late TextEditingController _costoController;
  late TextEditingController _precioController;
  late TextEditingController _existenciaController;
  late TextEditingController _maxController = TextEditingController();
  late TextEditingController _minController = TextEditingController();

  final ProveedoresController _proveedoresController = ProveedoresController();
  List<Proveedores> _proveedores = [];
  Proveedores? _selectedProveedor;

  String? _selectedUnMedSalida;
  String? _selectedUnMedEntrada;
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

  final _formkey = GlobalKey<FormState>();

  XFile? _selectedImage;
  String? _encodedImage;
  late ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _descripcionController =
        TextEditingController(text: widget.producto.prodDescripcion);
    _existenciaController = TextEditingController(
        text: (widget.producto.prodExistencia ?? 0.0).toString());
    _maxController = TextEditingController(
        text: (widget.producto.prodMax ?? 0.0).toString());
    _minController = TextEditingController(
        text: (widget.producto.prodMin ?? 0.0).toString());
    _costoController = TextEditingController(
        text: (widget.producto.prodCosto ?? 0.0).toString());
    _selectedUnMedSalida =
        widget.producto.prodUMedSalida ?? _unMedEntrada.first;
    _selectedUnMedEntrada =
        widget.producto.prodUMedEntrada ?? _unMedSalida.first;
    _precioController = TextEditingController(
        text: (widget.producto.prodPrecio ?? 0.0).toString());

    _loadProveedores();

    if (widget.producto.prodImgB64 != null &&
        widget.producto.prodImgB64!.isNotEmpty) {
      _encodedImage = widget.producto.prodImgB64;
      _selectedImage = XFile.fromData(
        base64Decode(widget.producto.prodImgB64!),
      );
    }
  }

  Future<void> _loadProveedores() async {
    List<Proveedores> proveedores =
        await _proveedoresController.listProveedores();
    setState(() {
      _proveedores = proveedores;
      _selectedProveedor = proveedores.firstWhere(
        (prov) => prov.id_Proveedor == widget.producto.idProveedor,
      );
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

  @override
  void dispose() {
    _descripcionController.dispose();
    _existenciaController.dispose();
    _maxController.dispose();
    _minController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      final updateProducto = widget.producto.copyWith(
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

      final result = await _productosController.editProducto(updateProducto);
      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Producto editado correctamente.');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al editar el producto.');
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
        title: const Text('Editar Producto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
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

                  //Botón
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChange,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
