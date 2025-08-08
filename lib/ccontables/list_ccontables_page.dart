// En list_ccontables_page.dart
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';

class ListCcontablesPage extends StatefulWidget {
  const ListCcontablesPage({super.key});

  @override
  State<ListCcontablesPage> createState() => _ListCcontablesPageState();
}

class _ListCcontablesPageState extends State<ListCcontablesPage> {
  final CcontablesController _ccontablesController = CcontablesController();
  final ProductosController _productosController = ProductosController();
  late Future<Map<int, Productos>> _productosFuture;

  List<CContables> _filteredCuentas = [];
  List<CContables> _allCuentas = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _productosFuture = _loadProductos();
  }

  Future<Map<int, Productos>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      return {for (var prod in productos) prod.id_Producto!: prod};
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      List<CContables> ccuentas = await _ccontablesController.listCcontables();
      setState(() {
        _allCuentas = ccuentas;
        _filteredCuentas = ccuentas;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCuentas(String query, Map<int, Productos> productosCache) {
    setState(() {
      if (query.isEmpty) {
        _filteredCuentas = _allCuentas;
      } else {
        _filteredCuentas = _allCuentas.where((cuenta) {
          final nombreProducto =
              productosCache[cuenta.idProducto]?.prodDescripcion ?? '';
          return cuenta.cC_Cuenta.toString().contains(query) ||
              cuenta.cC_SCTA.toString().contains(query) ||
              cuenta.cC_Detalle!.toLowerCase().contains(query.toLowerCase()) ||
              cuenta.cC_CVEPROD.toString().contains(query) ||
              cuenta.idProducto.toString().contains(query) ||
              nombreProducto.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _showEditDialog(
      CContables cuenta, Map<int, Productos> productosCache) async {
    final formKey = GlobalKey<FormState>();
    final cuentaController =
        TextEditingController(text: cuenta.cC_Cuenta?.toString());
    final sctaController =
        TextEditingController(text: cuenta.cC_SCTA?.toString());
    final detalleController = TextEditingController(text: cuenta.cC_Detalle);
    final cveprodController =
        TextEditingController(text: cuenta.cC_CVEPROD?.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${productosCache[cuenta.idProducto]?.id_Producto ?? 'Desconocido'} ${productosCache[cuenta.idProducto]?.prodDescripcion ?? 'Desconocido'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFieldNumero(
                    controller: cuentaController,
                    labelText: 'Cuenta',
                    prefixIcon: Icons.numbers,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese un número de cuenta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFieldNumero(
                    controller: sctaController,
                    labelText: 'Subcuenta',
                    prefixIcon: Icons.numbers,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFielTexto(
                    controller: detalleController,
                    labelText: 'Detalle',
                    prefixIcon: Icons.description,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFieldNumero(
                    controller: cveprodController,
                    labelText: 'CVEPROD',
                    prefixIcon: Icons.code,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedCuenta = cuenta.copyWith(
                    cC_Cuenta: int.tryParse(cuentaController.text),
                    cC_SCTA: int.tryParse(sctaController.text),
                    cC_Detalle: detalleController.text,
                    cC_CVEPROD: BigInt.tryParse(cveprodController.text),
                  );

                  final success = await _ccontablesController
                      .updateCcontable(updatedCuenta);
                  if (success) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    _loadData(); // Recargar datos
                    showOk(context, 'Cuenta actualizada correctamente');
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al actualizar la cuenta')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog(Map<int, Productos> productosCache) async {
    final formKey = GlobalKey<FormState>();
    final cuentaController = TextEditingController();
    final sctaController = TextEditingController();
    final detalleController = TextEditingController();
    final cveprodController = TextEditingController();
    Productos? selectedProduct;

    // Obtener productos sin cuenta
    final productosSinCuenta =
        await _ccontablesController.getProductosSinCuenta();
    final productosDisponibles = productosSinCuenta
        .map((id) => productosCache[id])
        .where((producto) => producto != null)
        .cast<Productos>()
        .toList();

    if (productosDisponibles.isEmpty) {
      // ignore: use_build_context_synchronously
      showError(context, 'Todos los productos ya tienen cuenta asociada');
      return;
    }

    // Seleccionar el primer producto por defecto
    selectedProduct = productosDisponibles.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Agregar Nueva Cuenta',
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomListaDesplegableTipo<Productos>(
                        value: selectedProduct,
                        labelText: 'Producto',
                        items: productosDisponibles,
                        onChanged: (producto) {
                          setState(() {
                            selectedProduct = producto;
                          });
                        },
                        itemLabelBuilder: (producto) =>
                            '${producto.id_Producto ?? 'Sin ID'} ${producto.prodDescripcion ?? 'Sin nombre'}',
                      ),
                      const SizedBox(height: 20),
                      CustomTextFieldNumero(
                        controller: cuentaController,
                        labelText: 'Cuenta*',
                        prefixIcon: Icons.numbers,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Debe ser un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFieldNumero(
                        controller: sctaController,
                        labelText: 'Subcuenta',
                        prefixIcon: Icons.numbers,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFielTexto(
                        controller: detalleController,
                        labelText: 'Detalle',
                        prefixIcon: Icons.description,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFieldNumero(
                        controller: cveprodController,
                        labelText: 'CVEPROD',
                        prefixIcon: Icons.code,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (selectedProduct == null) {
                        showError(context, 'Seleccione un producto');
                        return;
                      }

                      final nuevaCuenta = CContables(
                        id_CConTable: 0,
                        cC_Cuenta: int.tryParse(cuentaController.text),
                        cC_SCTA: int.tryParse(sctaController.text),
                        cC_Detalle: detalleController.text,
                        cC_CVEPROD: BigInt.tryParse(cveprodController.text),
                        idProducto: selectedProduct!.id_Producto,
                      );

                      try {
                        final success = await _ccontablesController
                            .addCcontable(nuevaCuenta);
                        if (success) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          _loadData();
                          showOk(context, 'Cuenta agregada correctamente');
                        } else {
                          // ignore: use_build_context_synchronously
                          showError(context, 'Error al agregar la cuenta');
                        }
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        showError(context, 'Error: ${e.toString()}');
                      }
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Cuentas Contables'),
        actions: [
          PermissionWidget(
            permission: 'ccontable',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final productosCache = await _productosFuture;
                _showAddDialog(productosCache);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomTextFielTexto(
              controller: _searchController,
              labelText:
                  'Buscar por Cuenta, SCTA, Detalle, CVEPROD, ID Producto o Nombre del Producto',
              prefixIcon: Icons.search,
              onChanged: (query) {
                // ignore: unnecessary_null_comparison
                if (_productosFuture != null) {
                  _productosFuture.then((productosCache) {
                    _filterCuentas(query, productosCache);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _filteredCuentas.isEmpty
                ? Center(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.blue.shade900)
                        : const Text('No se encontraron resultados'),
                  )
                : FutureBuilder<Map<int, Productos>>(
                    future: _productosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar productos: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final productosCache = snapshot.data ?? {};

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: _filteredCuentas.length,
                        itemBuilder: (context, index) {
                          final cuenta = _filteredCuentas[index];
                          final nombreProducto =
                              productosCache[cuenta.idProducto]
                                      ?.prodDescripcion ??
                                  'Desconocido';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            color: const Color.fromARGB(255, 155, 224, 253),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Cuenta: ${cuenta.cC_Cuenta}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        PermissionWidget(
                                          permission: 'ccontable',
                                          child: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showEditDialog(
                                                  cuenta, productosCache);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.black),
                                    Text(
                                        'Id del Producto: ${cuenta.idProducto}'),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Nombre: $nombreProducto',
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('SCTA: ${cuenta.cC_SCTA}'),
                                    const SizedBox(height: 10),
                                    Text(
                                        'CVEPROD: ${cuenta.cC_CVEPROD ?? 'Sin CVEPROD'}'),
                                    const SizedBox(height: 10),
                                    Text('Detalle: ${cuenta.cC_Detalle}'),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
