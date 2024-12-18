import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entidades_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddSalidaPage extends StatefulWidget {
  const AddSalidaPage({super.key});

  @override
  State<AddSalidaPage> createState() => _AddSalidaPageState();
}

class _AddSalidaPageState extends State<AddSalidaPage> {
  final EntradasController _entradasController = EntradasController();
  final UsersController _usersController = UsersController();
  final JuntasController _juntasController = JuntasController();
  final EntidadesController _entidadesController = EntidadesController();
  final ProductosController _productosController = ProductosController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  List<Users> _users = [];
  List<Entidades> _entidades = [];
  List<Juntas> _juntas = [];
  List<Map<String, dynamic>> _productosAgregados = [];

  Users? _selectedUser;
  Entidades? _selectedEntidad;
  Juntas? _selectedJunta;
  Productos? _selectedProducto;

  String? _errorMesage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntidades();
    _loadJuntas();
    _loadUsers();
  }

  Future<void> _loadEntidades() async {
    List<Entidades> entidades = await _entidadesController.listEntidades();
    setState(() {
      _entidades = entidades;
    });
  }

  Future<void> _loadJuntas() async {
    List<Juntas> juntas = await _juntasController.listJuntas();
    setState(() {
      _juntas = juntas;
    });
  }

  Future<void> _loadUsers() async {
    List<Users> users = await _usersController.listUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _buscarProducto() async {
    final idProducto = int.tryParse(_idProductoController.text);
    if (idProducto == null) {
      setState(() {
        _errorMesage = "El ID del producto debe ser un número válido.";
        _selectedProducto = null;
      });
      return;
    }

    final producto = await _productosController.getProductoById(idProducto);
    setState(() {
      if (producto != null) {
        _selectedProducto = producto;
        _errorMesage = null;
      } else {
        _selectedProducto = null;
        _errorMesage = "Producto con id no encontrado.";
      }
    });
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      if (cantidad > (_selectedProducto!.producto_Existencia ?? 0)) {
        showAdvertence(context,
            'La cantidad no puede ser mayor a la existencia del producto.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Salida'),
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
                  buildFormRow(
                    label: 'Referencia:',
                    child: TextFormField(
                      controller: _referenciaController,
                      decoration:
                          const InputDecoration(labelText: 'Referencia'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La referencia no puede estat vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Entidad
                  buildFormRow(
                    label: 'Entidad:',
                    child: DropdownButtonFormField<Entidades>(
                      value: _selectedEntidad,
                      items: _entidades
                          .map((entidad) => DropdownMenuItem(
                                value: entidad,
                                child: Text(
                                    entidad.entidad_Nombre ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEntidad = value;
                        });
                      },
                      decoration: const InputDecoration(label: Text('Entidad')),
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar una entidad.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Junta
                  buildFormRow(
                    label: 'Junta:',
                    child: DropdownButtonFormField<Juntas>(
                      value: _selectedJunta,
                      items: _juntas
                          .map((junta) => DropdownMenuItem(
                                value: junta,
                                child: Text(junta.junta_Name ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJunta = value;
                        });
                      },
                      decoration: const InputDecoration(label: Text('Junta')),
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar una junta.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Users
                  buildFormRow(
                    label: 'Usuario:',
                    child: DropdownButtonFormField<Users>(
                      value: _selectedUser,
                      items: _users
                          .map((user) => DropdownMenuItem(
                                value: user,
                                child: Text(user.user_Name ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value;
                        });
                      },
                      decoration: const InputDecoration(label: Text('Usuario')),
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar un usuario.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Buscar Producto
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Campo para ID del Producto
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _idProductoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'ID del Producto',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isLoading &&
                                        _idProductoController.text.isEmpty
                                    ? Colors.red
                                    : Colors.blue.shade900,
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un ID';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Botón para buscar producto
                      ElevatedButton(
                        onPressed: () async {
                          final id = _idProductoController.text;
                          if (id.isNotEmpty) {
                            setState(() {
                              _isLoading = true; // Indicador de carga
                            });

                            final producto = await _productosController
                                .getProductoById(int.parse(id));

                            setState(() {
                              _isLoading = false;
                              _selectedProducto =
                                  producto; // Actualiza el producto actual
                            });

                            if (producto == null) {
                              showAdvertence(context,
                                  'Producto con ID: ${_idProductoController.text}, no encontrado');
                            }
                          }
                        },
                        child: const Text('Buscar producto'),
                      ),
                      const SizedBox(width: 15),

                      // Información del Producto
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_selectedProducto != null)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del Producto:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Descripción: ${_selectedProducto!.producto_Descripcion ?? 'No disponible'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Precio: \$${_selectedProducto!.producto_Precio1?.toStringAsFixed(2) ?? 'No disponible'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Existencia: ${_selectedProducto!.producto_Existencia ?? 'No disponible'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'No se ha buscado un producto.',
                            style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                      const SizedBox(width: 15),

                      // Campo para la cantidad
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cantidad:',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _cantidadController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cantidad',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _isLoading &&
                                            _cantidadController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900,
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese una cantidad';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  //Botón para agregar producto a la tabla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _agregarProducto,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Tabla productos agregados
                  _productosAgregados.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Productos Agregados:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Table(
                              border: TableBorder.all(),
                              columnWidths: const {
                                0: FlexColumnWidth(1), //ID
                                1: FlexColumnWidth(3), //Descripción
                                2: FlexColumnWidth(1), //Precio
                                3: FlexColumnWidth(1), //Cantidad
                                4: FlexColumnWidth(1), //Precio Total
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900,
                                  ),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Clave',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Descripción',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Costo',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Cantidad',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Precio',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                ..._productosAgregados.map((producto) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(producto['id'].toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(producto['descripcion'] ??
                                            'Sin descripción'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            '\$${producto['costo'].toString()}'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            producto['cantidad'].toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            '\$${producto['precio'].toStringAsFixed(2)}'),
                                      ),
                                    ],
                                  );
                                }),
                                //Fial para el total
                                TableRow(children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(''),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(''),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(''),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '\$${_productosAgregados.fold<double>(
                                            0.0,
                                            (previousValue, producto) =>
                                                previousValue +
                                                (producto['precio'] ?? 0.0),
                                          ).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ])
                              ],
                            ),
                          ],
                        )
                      : const Text(
                          'No hay productos agregados.',
                          style: TextStyle(fontStyle: FontStyle.italic),
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
