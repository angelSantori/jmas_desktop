import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddEntradaPage extends StatefulWidget {
  final String? userName;
  const AddEntradaPage({super.key, this.userName});

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
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final TextEditingController _referenciaController = TextEditingController();

  String? idUserReporte;

  final List<Map<String, dynamic>> _productosAgregados = [];

  Productos? _selectedProducto;

  bool _isLoading = false;

  String? codFolio;

  //Proveedores
  final ProveedoresController _proveedoresController = ProveedoresController();
  List<Proveedores> _proveedores = [];
  Proveedores? _selectedProveedor;

  final AlmacenesController _almacenesController = AlmacenesController();
  List<Almacenes> _almacenes = [];
  Almacenes? _selectedAlmacen;

  @override
  void initState() {
    super.initState();
    _loadCodFolio();
    _loadDataEntrada();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
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
      _proveedores = proveedores;
    });
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      final double nuevaExistencia =
          (_selectedProducto!.prodExistencia!) + cantidad;
      final double totalExceso =
          nuevaExistencia - (_selectedProducto!.prodMax!);
      if (nuevaExistencia > (_selectedProducto!.prodMax!)) {
        showAdvertence(context,
            'La cantidad excede las existencias máximas del producto: ${_selectedProducto!.prodDescripcion}. \nPor: $totalExceso unidades de más.');
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      bool success = true; // Para verificar si al menos una entrada fue exitosa
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
      entrada_Referencia: _referenciaController.text,
      entrada_Fecha: _fechaController.text,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!),
      id_Almacen: _selectedAlmacen!.id_Almacen,
      entrada_Estado: true,
      id_Proveedor: _selectedProveedor!.id_Proveedor,
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    _referenciaController.clear();
    setState(() {
      _selectedProducto = null;
      _selectedAlmacen = null;
      _selectedProveedor = null;
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                        child: buildCabeceraItem('Captura', widget.userName!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _referenciaController,
                          labelText: 'Referencia',
                          validator: (referencia) {
                            if (referencia == null || referencia.isEmpty) {
                              return 'Referencia es obligatoria';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: CustomTextFielFecha(
                          controller: _fechaController,
                          labelText: 'Fecha',
                          onTap: () => _seleccionarFecha(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Debe seleccionar una fecha';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo(
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
                      const SizedBox(width: 30),
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
                              return 'Debe seleccionar un proveedor.';
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
                  ),

                  const SizedBox(height: 20),

                  //Botón para agregar producto a la tabla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _agregarProducto,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        label: const Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Tabla productos agregados
                  buildProductosAgregados(
                    _productosAgregados,
                    eliminarProducto,
                    actualizarCosto,
                  ),

                  const SizedBox(height: 30),

                  //Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //PDF e imprimir
                      ElevatedButton(
                        onPressed: () async {
                          bool datosCompletos =
                              await validarCamposAntesDeImprimirEntrada(
                            context: context,
                            referencia: _referenciaController.text,
                            productosAgregados: _productosAgregados,
                            selectedAlmacen: _selectedAlmacen,
                            proveedor: _selectedProveedor,
                          );

                          if (!datosCompletos) {
                            return;
                          }

                          await generateAndPrintPdfEntrada(
                            movimiento: 'Entrada',
                            fecha: _fechaController.text,
                            folio: codFolio!,
                            almacen: _selectedAlmacen!.almacen_Nombre!,
                            userName: widget.userName!,
                            referencia: _referenciaController.text,
                            productos: _productosAgregados,
                            proveedor: _selectedProveedor!.proveedor_Name!,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 60),

                      //Guardar entrada
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarEntrada,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: _isLoading
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
                                    'Guardando...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Guardar Entrada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
