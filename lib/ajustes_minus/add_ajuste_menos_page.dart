import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/ajuste_menos_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddAjusteMenosPage extends StatefulWidget {
  const AddAjusteMenosPage({super.key});

  @override
  State<AddAjusteMenosPage> createState() => _AddAjusteMenosPageState();
}

class _AddAjusteMenosPageState extends State<AddAjusteMenosPage> {
  final AuthService _authService = AuthService();
  final AjusteMenosController _ajusteMenosController = AjusteMenosController();
  final ProductosController _productosController = ProductosController();

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _productosAgregados = [];

  bool _isLoading = false;

  String? idUserReporte;

  Productos? _selectedProducto;

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

  Future<void> _guardarAjusteMenos() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(context, 'Debe agregar al menos un producto');
      return;
    }

    if (_formKey.currentState!.validate()) {
      bool success = true;
      for (var producto in _productosAgregados) {
        await _getUserId();
        final nuevoAjusteMenos = _crearAjusteMenos(producto);
        bool result =
            await _ajusteMenosController.addAjusteMenos(nuevoAjusteMenos);

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
          showAdvertence(context,
              'Producto con ID: ${producto['id']} no encontrado en la base de datos.');
          success = false;
          break;
        }

        productoActualizado.producto_Existencia =
            (productoActualizado.producto_Existencia!) - producto['cantidad'];

        bool editResult =
            await _productosController.editProducto(productoActualizado);

        if (!editResult) {
          showAdvertence(context,
              'Error al actualizar las existencias del producto con ID: ${producto['id_Producto']}');
          success = false;
          break;
        }
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Ajuste Más creado exitosamente.');
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar ajuste más');
      }

      _limpiarFormulario();
    }
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserReporte = decodeToken?['Id_User'] ?? '0';
  }

  AjusteMenos _crearAjusteMenos(Map<String, dynamic> producto) {
    return AjusteMenos(
        id_AjusteMenos: 0,
        ajusteMenos_Descripcion: _descriptionController.text,
        ajusteMenos_Cantidad: double.parse(producto['cantidad'].toString()),
        ajusteMenos_Fecha: _fecha,
        id_Producto: producto['id'],
        id_User: int.parse(idUserReporte ?? '0'));
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _descriptionController.clear();
      _cantidadController.clear();
      _idProductoController.clear();
      _productosAgregados.clear();
      _selectedProducto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Menos'),
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
                  //Fecha
                  Text(
                    _fecha,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _descriptionController,
                          labelText: 'Descripción',
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Descripción obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

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

                  //Botón
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

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _guardarAjusteMenos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Guardar Ajuste -',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
