import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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

  final TextEditingController _referenciaController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? idUserReporte;

  final List<Map<String, dynamic>> _productosAgregados = [];

  Productos? _selectedProducto;

  bool _isLoading = false;

  String? codFolio;

  @override
  void initState() {
    super.initState();
    _loadCodFolio();
  }

  Future<void> _loadCodFolio() async {
    final fetchedCodFolio = await _entradasController.getNextCodFolio();
    setState(() {
      codFolio = fetchedCodFolio;
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
          'precio': precioTotal
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
      entrada_Fecha: _fecha,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!),
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    _referenciaController.clear();
    setState(() {
      _selectedProducto = null;
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrada: ${codFolio ?? "Cargando ..."}'),
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
                  const SizedBox(height: 40),
                  //Fecha
                  Text(
                    _fecha,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  buildProductosAgregados(_productosAgregados),

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
                          );

                          if (!datosCompletos) {
                            return;
                          }

                          await generateAndPrintPdfEntrada(
                            movimiento: 'Entrada',
                            fecha: _fecha,
                            folio: codFolio!,
                            userName: widget.userName!,
                            referencia: _referenciaController.text,
                            productos: _productosAgregados,
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
