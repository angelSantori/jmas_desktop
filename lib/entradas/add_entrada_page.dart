import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddEntradaPage extends StatefulWidget {
  const AddEntradaPage({super.key});

  @override
  State<AddEntradaPage> createState() => _AddEntradaPageState();
}

class _AddEntradaPageState extends State<AddEntradaPage> {
  final AuthService _authService = AuthService();
  final EntradasController _entradasController = EntradasController();
  final UsersController _usersController = UsersController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? idUserReporte;

  List<Users> _users = [];
  List<Proveedores> _proveedores = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Users? _selectedUser;
  Productos? _selectedProducto;
  Proveedores? _selectedProveedor;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadProveedores();
  }

  Future<void> _loadUsers() async {
    List<Users> users = await _usersController.listUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _loadProveedores() async {
    List<Proveedores> proveedores =
        await _proveedoresController.listProveedores();
    setState(() {
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

        productoActualizado.producto_Existencia =
            (productoActualizado.producto_Existencia!) + producto['cantidad'];

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
        entrada_Folio: _referenciaController.text,
        entrada_Unidades: double.tryParse(producto['cantidad'].toString()),
        entrada_Costo: double.tryParse(producto['precio'].toString()),
        entrada_Fecha: _fecha,
        id_Producto: producto['id'] ?? 0, // Toma el id del producto de la lista
        id_Proveedor: _selectedProveedor?.id_Proveedor ?? 0, // Proveedor
        id_User: _selectedUser?.id_User ?? 0, // Usuario
        user_Reporte: int.parse(idUserReporte ?? '0'));
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedUser = null;
      _selectedProducto = null;
      _selectedProveedor = null;
      _referenciaController.clear();
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Entrada'),
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

                  //Referencia
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _referenciaController,
                          labelText: 'Referencia',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Refetencia obligatoria';
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
                        //Proveedores
                        child: CustomListaDesplegableTipo(
                          value: _selectedProveedor,
                          labelText: 'Proveedor',
                          items: _proveedores,
                          onChanged: (value) {
                            setState(() {
                              _selectedProveedor = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Debe seleccionar un proveedor.';
                            }
                            return null;
                          },
                          itemLabelBuilder: (proveedor) =>
                              proveedor.proveedor_Name ?? 'Sin nombre',
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Users
                      Expanded(
                        child: CustomListaDesplegableTipo(
                          value: _selectedUser,
                          labelText: 'Usuario',
                          items: _users,
                          onChanged: (value) {
                            setState(() {
                              _selectedUser = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Debe seleccionar un usuario.';
                            }
                            return null;
                          },
                          itemLabelBuilder: (user) =>
                              user.user_Name ?? 'Sin nombre',
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
                            productosAgregados: _productosAgregados,
                            referenciaController: _referenciaController,
                            selectedProveedor: _selectedProveedor,
                            selectedUser: _selectedUser,
                          );

                          if (!datosCompletos) {
                            return;
                          }

                          await generateAndPrintPdfEntrada(
                            context: context,
                            movimiento: 'Entrada',
                            fecha: _fecha,
                            referencia: _referenciaController.text,
                            proveedor: _selectedProveedor?.proveedor_Name ??
                                'Sin Proveedor',
                            usuario: _selectedUser?.user_Name ?? 'Sin Usuario',
                            productos: _productosAgregados,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Imprimir',
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
