import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

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
      // ignore: avoid_print
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCuentas(String query, Map<int, Productos> productosCache) {
    setState(() {
      if (query.isEmpty) {
        _filteredCuentas = _allCuentas; // Si no hay búsqueda, mostrar todas
      } else {
        _filteredCuentas = _allCuentas.where((cuenta) {
          final nombreProducto =
              productosCache[cuenta.idProducto]?.prodDescripcion ?? '';

          // Buscar en todos los campos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Cuentas Contables'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomTextFielTexto(
              controller: _searchController,
              labelText:
                  'Buscar por Cuenta, SCTA, Detalle, CVEPROD, ID Producto o Nombre del Producto',
              prefixIcon: Icons.search, // Ícono de búsqueda
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
                            color: const Color.fromARGB(255, 201, 230, 242),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text('Cuenta: ${cuenta.cC_Cuenta}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: Colors.black),
                                  Text('Id del Producto: ${cuenta.idProducto}'),
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
