import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/productos/widgets/listas_caracteristicas.dart';
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
  final CapturainviniController _capturainviniController =
      CapturainviniController();

  late TextEditingController _descripcionController;
  late TextEditingController _costoController;
  late TextEditingController _precioController;
  TextEditingController? _existenciaController;
  late TextEditingController _maxController = TextEditingController();
  late TextEditingController _minController = TextEditingController();

  // Nuevos controladores para ubicación física
  late TextEditingController _rackController = TextEditingController();
  late TextEditingController _nivelController = TextEditingController();
  late TextEditingController _letraController = TextEditingController();

  final ProveedoresController _proveedoresController = ProveedoresController();
  List<Proveedores> _proveedores = [];
  Proveedores? _selectedProveedor;

  //  Almacenes
  final AlmacenesController _almacenesController = AlmacenesController();
  List<Almacenes> _allAlmacenes = [];
  Almacenes? _selectedAlamacen;

  String? _selectedUnMedSalida;
  String? _selectedUnMedEntrada;
  String? _selectedEstado;

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
    _maxController = TextEditingController(
        text: (widget.producto.prodMax ?? 0.0).toString());
    _minController = TextEditingController(
        text: (widget.producto.prodMin ?? 0.0).toString());
    _costoController = TextEditingController(
        text: (widget.producto.prodCosto ?? 0.0).toString());
    _selectedUnMedSalida = widget.producto.prodUMedSalida ?? unMedEntrada.first;
    _selectedUnMedEntrada =
        widget.producto.prodUMedEntrada ?? unMedSalida.first;
    _selectedEstado = widget.producto.prodEstado ?? estadoLista.first;
    _precioController = TextEditingController(
        text: (widget.producto.prodPrecio ?? 0.0).toString());

    _existenciaController = TextEditingController(text: '0.0');

    // Parsear la ubicación física existente
    if (widget.producto.prodUbFisica != null &&
        widget.producto.prodUbFisica!.isNotEmpty) {
      _parseUbicacionFisica(widget.producto.prodUbFisica!);
    }

    _loadProveedores();
    _loadAlmacen();
    _loadInvIniConteo();

    if (widget.producto.prodImgB64 != null &&
        widget.producto.prodImgB64!.isNotEmpty) {
      _encodedImage = widget.producto.prodImgB64;
      _selectedImage = XFile.fromData(
        base64Decode(widget.producto.prodImgB64!),
      );
    }
  }

  // Método para parsear la ubicación física existente
  void _parseUbicacionFisica(String ubicacion) {
    try {
      // Buscar los índices de 'R', 'N' y 'A'
      int indexR = ubicacion.indexOf('R');
      int indexN = ubicacion.indexOf('N');
      int indexA = ubicacion.indexOf('A');

      if (indexR != -1 && indexN != -1 && indexA != -1) {
        // Extraer rack (después de 'R' hasta antes de 'N')
        String rackValue = ubicacion.substring(indexR + 1, indexN);
        // Extraer nivel (después de 'N' hasta antes de 'A')
        String nivelValue = ubicacion.substring(indexN + 1, indexA);
        // Extraer letra (después de 'A')
        String letraValue = ubicacion.substring(indexA + 1);

        _rackController = TextEditingController(text: rackValue);
        _nivelController = TextEditingController(text: nivelValue);
        _letraController = TextEditingController(text: letraValue);
      }
    } catch (e) {
      print('Error al parsear ubicación física: $e');
      // Si hay error, inicializar con valores vacíos
      _rackController = TextEditingController();
      _nivelController = TextEditingController();
      _letraController = TextEditingController();
    }
  }

  Future<void> _loadInvIniConteo() async {
    try {
      final capturaList = await _capturainviniController.listCapturaI();
      final captura = capturaList.firstWhere(
        (captura) => captura.id_Producto == widget.producto.id_Producto,
        orElse: () => Capturainvini(invIniConteo: 0.0),
      );
      setState(() {
        _existenciaController = TextEditingController(
          text: (captura.invIniConteo ?? '0.0').toString(),
        );
      });
    } catch (e) {
      print('Error al cargar invIniConteo: $e');
      setState(() {
        _existenciaController = TextEditingController(text: '0.0');
      });
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

  Future<void> _loadAlmacen() async {
    List<Almacenes> almacenes = await _almacenesController.listAlmacenes();
    setState(() {
      _allAlmacenes = almacenes;
      _selectedAlamacen = almacenes.firstWhere(
          (almacen) => almacen.id_Almacen == widget.producto.id_Almacen);
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
    _existenciaController!.dispose();
    _maxController.dispose();
    _minController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    _rackController.dispose(); // Nuevo
    _nivelController.dispose(); // Nuevo
    _letraController.dispose(); // Nuevo
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      // Construir la ubicación física con el nuevo formato
      final ubicacionFisica =
          'R${_rackController.text}N${_nivelController.text}A${_letraController.text}';

      final updateProducto = widget.producto.copyWith(
        prodDescripcion: _descripcionController.text,
        prodExistencia: double.parse(_existenciaController!.text),
        prodMax: double.parse(_maxController.text),
        prodMin: double.parse(_minController.text),
        prodCosto: double.parse(_costoController.text),
        prodUbFisica: ubicacionFisica, // Usar la nueva ubicación
        prodUMedSalida: _selectedUnMedSalida,
        prodUMedEntrada: _selectedUnMedEntrada,
        prodEstado: _selectedEstado,
        prodPrecio: double.parse(_precioController.text),
        prodImgB64: _encodedImage,
        idProveedor: _selectedProveedor?.id_Proveedor ?? 0,
        id_Almacen: _selectedAlamacen?.id_Almacen,
      );

      final result = await _productosController.editProducto(updateProducto);
      setState(() {
        _isLoading = false;
      });

      if (result) {
        await _updateCapturaIni();
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

  Future<void> _updateCapturaIni() async {
    try {
      double newInvIniConteo = double.parse(_existenciaController!.text);

      final capturaList = await _capturainviniController.listCapturaI();
      final captura = capturaList.firstWhere(
        (captura) => captura.id_Producto == widget.producto.id_Producto,
        orElse: () => Capturainvini(
          id_Producto: widget.producto.id_Producto,
          invIniConteo: 0.0,
        ),
      );
      final updateCaptura = captura.copyWith(invIniConteo: newInvIniConteo);

      final result = await _capturainviniController.editCapturaI(updateCaptura);
      if (!result) {
        print('Error al actualizar Capturainini | If');
      }
    } catch (e) {
      print('Error en _updateCapturaIni | TryCatch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto: ${widget.producto.prodDescripcion}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
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
                          controller: _existenciaController!,
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

                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedEstado,
                          labelText: 'Estado',
                          items: estadoLista,
                          onChanged: (estado) {
                            setState(() {
                              _selectedEstado = estado;
                            });
                          },
                          validator: (estado) {
                            if (estado == null || estado.isEmpty) {
                              return 'Estado de producto obligatorio';
                            }
                            return null;
                          },
                        ),
                      )
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
                          items: unMedEntrada,
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
                          items: unMedSalida,
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
                      const SizedBox(width: 30),

                      //  Almacenes
                      Expanded(
                        child: CustomListaDesplegableTipo<Almacenes>(
                          value: _selectedAlamacen,
                          labelText: 'Almacen',
                          items: _allAlmacenes,
                          onChanged: (almacen) {
                            setState(() {
                              _selectedAlamacen = almacen;
                            });
                          },
                          validator: (almacen) {
                            if (almacen == null) {
                              return 'Almacen obligatorio';
                            }
                            return null;
                          },
                          itemLabelBuilder: (almacen) =>
                              '${almacen.almacen_Nombre ?? 'Sin nombre'} - (${almacen.id_Almacen})',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  // Ubicación física con campos de texto
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // Rack
                        Expanded(
                          child: CustomTextFieldNumero(
                            controller: _rackController,
                            labelText: 'Rack (Número)',
                            prefixIcon: Icons.shelves,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Rack obligatorio.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 30),

                        // Nivel
                        Expanded(
                          child: CustomTextFieldNumero(
                            controller: _nivelController,
                            labelText: 'Nivel (Número)',
                            prefixIcon: Icons.layers,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nivel obligatorio.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 30),

                        // Letra
                        Expanded(
                          child: CustomTextFielTexto(
                            controller: _letraController,
                            labelText: 'Anaquel (A-Z)',
                            prefixIcon: Icons.abc,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-z]')),
                              LengthLimitingTextInputFormatter(1),
                            ],
                            onChanged: (letra) {
                              if (letra.isNotEmpty) {
                                _letraController.text = letra.toUpperCase();
                                _letraController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _letraController.text.length));
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Letra obligatoria';
                              }
                              if (value.length > 1) {
                                return 'Solo una letra';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
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
