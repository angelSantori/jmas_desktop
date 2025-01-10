import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/ajuste_mas_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddAjusteMorePage extends StatefulWidget {
  const AddAjusteMorePage({super.key});

  @override
  State<AddAjusteMorePage> createState() => _AddAjusteMorePageState();
}

class _AddAjusteMorePageState extends State<AddAjusteMorePage> {
  final AjusteMasController _ajusteMoreController = AjusteMasController();
  final ProductosController _productosController = ProductosController();
  final EntradasController _entradasController = EntradasController();
  final SalidasController _salidasController = SalidasController();

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _productosAgregados = [];
  List<Entradas> _entradas = [];
  List<Salidas> _salidas = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  int? _idEntrada;
  int? _idSalida;

  Productos? _selectedProducto;

  Future<void> _buscarReferencia() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _idEntrada = null;
      _idSalida = null;
    });

    try {
      final List<Entradas> entradas = await _entradasController
          .getEntradaByFolio(_referenciaController.text);

      final List<Salidas> salidas =
          await _salidasController.getSalidaByFolio(_referenciaController.text);

      setState(() {
        _entradas = entradas;
        _salidas = salidas;
      });

      if (_entradas.isNotEmpty) {
        setState(() {
          _idEntrada = _entradas.first.id_Entradas;
          _idSalida = null;
        });
        buildReferenciaBuscadaEntrada(_entradas);
      } else if (_salidas.isNotEmpty) {
        setState(() {
          _idSalida = _salidas.first.id_Salida;
          _idEntrada = null;
        });
        buildReferenciaBuscadaSalida(_salidas);
      }
    } catch (e) {
      showAdvertence(context, 'Error al buscar la referencia: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      setState(() {
        final double precioUnitario =
            _selectedProducto!.producto_Precio1 ?? 0.0;
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.producto_Descripcion,
          'costo': _selectedProducto!.producto_Precio1,
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

  Future<void> _guardarAjuste() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(context, 'Debe agregar al menos un producto.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      bool success = true;
      for (var producto in _productosAgregados) {
        final nuevoAjuste = _crearAjuste(producto);

        bool result = await _ajusteMoreController.addAjusteMore(nuevoAjuste);

        print('Datos enviados al back: ${nuevoAjuste.toJson()}');

        if (!result) {
          success = false;
          break;
        }

        if (producto['id'] == null) {
          showAdvertence(context,
              'Id nulo: ${producto['id_Producto']}, no se puede continuar.');
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

        if (_idEntrada != null) {
          productoActualizado.producto_Existencia =
              (productoActualizado.producto_Existencia!) + producto['cantidad'];
        } else {
          productoActualizado.producto_Existencia =
              (productoActualizado.producto_Existencia!) - producto['cantidad'];
        }

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
        showOk(context, 'Ajuste + creado exitosamente.');
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar ajuste');
      }

      _limpiarFormulario(); // Limpiar formulario después de guardar
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _referenciaController.clear();
      _cantidadController.clear();
      _idProductoController.clear();
      _productosAgregados.clear();
      _idEntrada = null;
      _idSalida = null;
      _selectedProducto = null;
      _hasSearched = false;
    });
  }

  AjusteMores _crearAjuste(Map<String, dynamic> producto) {
    return AjusteMores(
      id_AjusteMore: 0,
      ajusteMore_Cantidad: double.parse(producto['cantidad'].toString()),
      ajusteMore_Fecha: _fecha,
      id_Producto: producto['id'],
      id_Entradas: _idEntrada ?? null,
      id_Salida: _idSalida ?? null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Más'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  //Fecha
                  Text(
                    _fecha,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Referencia
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildFormRow(
                        label: 'Referencia',
                        child: Row(
                          children: [
                            // Campo de texto para la referencia
                            Expanded(
                              child: TextFormField(
                                controller: _referenciaController,
                                decoration: const InputDecoration(
                                  labelText: 'Referencia',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La referencia no puede estar vacía.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10), // Separador
                            // Botón de búsqueda
                            ElevatedButton(
                              onPressed: _isLoading ? null : _buscarReferencia,
                              child: const Text('Buscar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  //Resultados de busqueda
                  // Resultados de búsqueda
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _hasSearched
                          ? Column(
                              children: [
                                // Resultados basados en las listas
                                _entradas.isNotEmpty
                                    ? buildReferenciaBuscadaEntrada(_entradas)
                                    : _salidas.isNotEmpty
                                        ? buildReferenciaBuscadaSalida(_salidas)
                                        : const Text(
                                            'Referencia no encontrada en la base de datos'),
                              ],
                            )
                          : const SizedBox.shrink(),

                  const SizedBox(height: 50),
                  //Buscar producto
                  BuscarProductoWidget(
                    idProductoController: _idProductoController,
                    cantidadController: _cantidadController,
                    productosController: _productosController,
                    isLoading: _isLoading,
                    selectedProducto: _selectedProducto,
                    onProductoSeleccionado: (producto) {
                      setState(() {
                        _selectedProducto = producto;
                      });
                    },
                    onAdvertencia: (p0) {
                      showAdvertence(context, p0);
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

                  buildProductosAgregados(_productosAgregados),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Guardar entrada
                      ElevatedButton(
                        onPressed: _guardarAjuste,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Guardar Ajuste',
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
