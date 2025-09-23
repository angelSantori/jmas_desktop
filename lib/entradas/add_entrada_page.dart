import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/formularios/custom_autocomplete_field.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddEntradaPage extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddEntradaPage({super.key, this.userName, this.idUser});

  @override
  State<AddEntradaPage> createState() => _AddEntradaPageState();
}

class _AddEntradaPageState extends State<AddEntradaPage> {
  final AuthService _authService = AuthService();
  final EntradasController _entradasController = EntradasController();
  final ProductosController _productosController = ProductosController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  //final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _numFacturaController = TextEditingController();

  final _showFecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final TextEditingController _busquedaProveedorController =
      TextEditingController();
  List<Proveedores> _listProveedores = [];
  Proveedores? _selectedProveedor;

  String? idUserReporte;

  final List<Map<String, dynamic>> _productosAgregados = [];

  Productos? _selectedProducto;

  bool _isLoading = false;
  bool _isGeneratingPDF = false;

  String? codFolio;

  //Proveedores
  final ProveedoresController _proveedoresController = ProveedoresController();

  //Almacen
  final AlmacenesController _almacenesController = AlmacenesController();
  List<Almacenes> _almacenes = [];
  Almacenes? _selectedAlmacen;

  //Factura / Imagen
  Uint8List? _imagenFactura;

  @override
  void initState() {
    super.initState();
    _loadCodFolio();
    _loadDataEntrada();
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      final Uint8List bytes = await imagen.readAsBytes();

      setState(() {
        _imagenFactura = bytes;
      });
    }
  }

  Future<void> _loadCodFolio() async {
    final fetchedCodFolio = await _entradasController.getNextCodFolio();
    setState(() {
      codFolio = fetchedCodFolio;
    });
  }

  Future<void> _loadDataEntrada() async {
    List<Almacenes> almacenes = await _almacenesController.listAlmacenes();
    List<Proveedores> proveedores =
        await _proveedoresController.listProveedores();

    setState(() {
      _almacenes = almacenes;
      _listProveedores = proveedores;
    });
  }

  void _agregarProducto() async {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final double cantidad = double.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      // Usar directamente la existencia del producto
      final double existenciaActual = _selectedProducto!.prodExistencia ?? 0.0;
      final double nuevaExistencia = existenciaActual + cantidad;
      final double totalExceso =
          nuevaExistencia - (_selectedProducto!.prodMax!);

      if (nuevaExistencia > (_selectedProducto!.prodMax!)) {
        showAdvertence(context,
            'La cantidad excede las existencias máximas del producto: ${_selectedProducto!.prodDescripcion}. \nCantidad máxima: ${_selectedProducto!.prodMax} \nTotal unidades tras entrada: $nuevaExistencia \nExceso: $totalExceso unidades de más.');
      }

      setState(() {
        final double precioUnitario = _selectedProducto!.prodPrecio ?? 0.0;
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': _selectedProducto!.prodPrecio,
          'cantidad': cantidad,
          'precio': precioTotal,
          'idProveedor': _selectedProveedor?.id_Proveedor
        });

        //Limpiar campos despuués de agregar
        _idProductoController.clear();
        _cantidadController.clear();
        _selectedProducto = null;
      });
    } else {
      showAdvertence(
          context, 'Debe seleccionar un producto y definir la cantidad.');
    }
  }

  void eliminarProducto(int index) {
    setState(() {
      _productosAgregados.removeAt(index);
    });
  }

  void actualizarCosto(int index, double nuevoCosto) {
    setState(() {
      _productosAgregados[index]['costo'] = nuevoCosto;
      _productosAgregados[index]['precio'] =
          nuevoCosto * (_productosAgregados[index]['cantidad'] ?? 1);
    });
  }

  Future<void> _guardarEntrada() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(
          context, 'Debe agregar productos antes de guardar la entrada.');
      return;
    }

    if (_imagenFactura == null) {
      showAdvertence(context, 'Factura obligatoria');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      bool success = true;
      for (var producto in _productosAgregados) {
        await _getUserId();
        final nuevaEntrada = _crearEntrada(producto);
        bool result = await _entradasController.addEntrada(nuevaEntrada);

        if (!result) {
          success = false;
          break; // Si hay error, no procesamos más productos y mostramos el error
        }

        if (producto['id'] == null) {
          showAdvertence(context,
              'Id nulo: ${producto['id_Producto']}, no se puede continuar');
          success = false;
          break;
        }

        final productoActualizado =
            await _productosController.getProductoById(producto['id']);

        if (productoActualizado == null) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Producto con ID ${producto['id']} no encontrado en la base de datos.');
          success = false;
          break;
        }

        productoActualizado.prodExistencia =
            (productoActualizado.prodExistencia!) + producto['cantidad'];

        //Asignar el Id del proveedor al producto
        productoActualizado.idProveedor = _selectedProveedor?.id_Proveedor;

        bool editResult =
            await _productosController.editProducto(productoActualizado);

        if (!editResult) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Error al actualizar las existencias del producto con ID ${producto['id_Producto']}');
          success = false;
          break;
        }
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Entrada creada exitosamente.');
        setState(() {
          _isLoading = false;
          _loadCodFolio();
        });
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar entradas');
        setState(() {
          _isLoading = false;
        });
      }

      _limpiarFormulario();
    }
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserReporte = decodeToken?['Id_User'] ?? '0';
  }

  Entradas _crearEntrada(Map<String, dynamic> producto) {
    return Entradas(
      id_Entradas: 0,
      entrada_CodFolio: codFolio,
      entrada_Unidades: double.tryParse(producto['cantidad'].toString()),
      entrada_Costo: double.tryParse(producto['precio'].toString()),
      //entrada_Referencia: _referenciaController.text,
      entrada_Fecha: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      entrada_Comentario: _comentarioController.text,
      entrada_NumeroFactura: int.tryParse(_numFacturaController.text),
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!),
      id_Almacen: _selectedAlmacen!.id_Almacen,
      entrada_Estado: true,
      id_Proveedor: _selectedProveedor!.id_Proveedor,
      id_Junta: 1,
      entrada_ImgB64Factura:
          _imagenFactura != null ? base64Encode(_imagenFactura!) : null,
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    //_referenciaController.clear();
    _comentarioController.clear();
    _numFacturaController.clear();
    setState(() {
      _selectedProducto = null;
      _selectedAlmacen = null;
      _selectedProveedor = null;
      _imagenFactura = null;
      _idProductoController.clear();
      _busquedaProveedorController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: buildCabeceraItem(
                              'Movimiento',
                              codFolio ?? 'Cargando...',
                            ),
                          ),
                          Expanded(
                            child:
                                buildCabeceraItem('Captura', widget.userName!),
                          ),
                          Expanded(child: buildCabeceraItem('Junta', 'Meoqui')),
                          Expanded(
                              child: buildCabeceraItem('Fecha', _showFecha))
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          //  Número de Factura
                          Expanded(
                            child: CustomTextFieldNumero(
                              prefixIcon: Icons.numbers,
                              controller: _numFacturaController,
                              labelText: 'Número de Factura',
                              validator: (factura) {
                                if (factura == null || factura.isEmpty) {
                                  return 'Número de factura es obligatoria';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          //  Almacen
                          Expanded(
                            child: CustomListaDesplegableTipo<Almacenes>(
                              value: _selectedAlmacen,
                              labelText: 'Almacen',
                              items: _almacenes,
                              onChanged: (ent) {
                                setState(() {
                                  _selectedAlmacen = ent;
                                });
                              },
                              validator: (ent) {
                                if (ent == null) {
                                  return 'Debe seleccionar una almacen.';
                                }
                                return null;
                              },
                              itemLabelBuilder: (ent) =>
                                  ent.almacen_Nombre ?? 'Sin nombre',
                            ),
                          ),
                          const SizedBox(width: 20),

                          //  Proveedor
                          Expanded(
                            child: CustomAutocompleteField<Proveedores>(
                              value: _selectedProveedor,
                              labelText: 'Buscar Proveedor',
                              items: _listProveedores,
                              prefixIcon: Icons.search,
                              onChanged: (proveedores) {
                                setState(() {
                                  _selectedProveedor = proveedores;
                                });
                              },
                              itemLabelBuilder: (proveedor) =>
                                  '${proveedor.id_Proveedor} - ${proveedor.proveedor_Name}',
                              itemValueBuilder: (proveedor) =>
                                  proveedor.id_Proveedor.toString(),
                              validator: (value) {
                                if (_selectedProveedor == null) {
                                  return 'Seleccione un proveedor válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          //  Comentario
                          Expanded(
                            child: CustomTextFielTexto(
                              controller: _comentarioController,
                              labelText: 'Comentario*',
                              prefixIcon: Icons.remove_red_eye,
                            ),
                          ),
                          const SizedBox(width: 10),

                          //  Factura
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _imagenFactura != null
                                    ? Image.memory(
                                        _imagenFactura!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : const Text(
                                        "No se ha seleccionado ninguna imagen",
                                        textAlign: TextAlign.center,
                                      ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _seleccionarImagen,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade900),
                                  icon: const Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                  label: const Text("Seleccionar factura",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      //Productos
                      BuscarProductoWidget(
                        idProductoController: _idProductoController,
                        cantidadController: _cantidadController,
                        productosController: _productosController,
                        selectedProducto: _selectedProducto,
                        onProductoSeleccionado: (producto) {
                          setState(() {
                            _selectedProducto = producto;
                          });
                        },
                        onAdvertencia: (message) {
                          showAdvertence(context, message);
                        },
                        onEnterPressed: _agregarProducto,
                      ),
                      const SizedBox(height: 20),

                      //Tabla productos agregados
                      buildProductosAgregados(
                        _productosAgregados,
                        eliminarProducto,
                        actualizarCosto,
                      ),
                      const SizedBox(height: 30),

                      //Botón
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: (_isGeneratingPDF || _isLoading)
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isGeneratingPDF = true;
                                        _isLoading = true;
                                      });

                                      try {
                                        //1. Validar campos
                                        bool datosCompletos =
                                            await validarCamposAntesDeImprimirEntrada(
                                          context: context,
                                          //referencia: _referenciaController.text,
                                          numFactura:
                                              _numFacturaController.text,
                                          productosAgregados:
                                              _productosAgregados,
                                          selectedAlmacen: _selectedAlmacen,
                                          proveedor: _selectedProveedor,
                                          factura: _imagenFactura,
                                        );

                                        if (!datosCompletos) {
                                          return;
                                        }

                                        //2. Generar PDF
                                        await generarPdfEntrada(
                                          movimiento: 'Entrada',
                                          fecha: _showFecha,
                                          folio: codFolio!,
                                          idUser: widget.idUser!,
                                          alamcenA: _selectedAlmacen!,
                                          userName: widget.userName!,
                                          //referencia: _referenciaController.text,
                                          productos: _productosAgregados,
                                          proveedorP: _selectedProveedor!,
                                          numFactura:
                                              _numFacturaController.text,
                                          comentario:
                                              _comentarioController.text,
                                        );

                                        //3. Guardar registro
                                        await _guardarEntrada();
                                      } catch (e) {
                                        showError(
                                            context, 'Error al guardar datos');
                                        print('Error al guardar datos: $e');
                                      } finally {
                                        setState(() {
                                          _isGeneratingPDF = false;
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                elevation: 8,
                                shadowColor: Colors.blue.shade900,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              child: (_isGeneratingPDF || _isLoading)
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Procesando...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Guardar y Generar PDF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isGeneratingPDF)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
          // Indicador de carga centrado
          if (_isGeneratingPDF)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Generando PDF...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
