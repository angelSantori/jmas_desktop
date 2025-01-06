import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';

class ListSalidaPage extends StatefulWidget {
  const ListSalidaPage({super.key});

  @override
  State<ListSalidaPage> createState() => _ListSalidaPageState();
}

class _ListSalidaPageState extends State<ListSalidaPage> {
  final SalidasController _salidasController = SalidasController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  final TextEditingController _searchController = TextEditingController();
  List<Salidas> _allSalidas = [];
  List<Salidas> _filteredSalidas = [];

  @override
  void initState() {
    super.initState();
    _loadSalidas();
    _searchController.addListener(_filterSalidas);
  }

  Future<void> _loadSalidas() async {
    try {
      final salidas = await _salidasController.listSalidas();
      setState(() {
        _allSalidas = salidas;
        _filteredSalidas = salidas;
      });
    } catch (e) {
      print('Error al cargar salidas: $e');
    }
  }

  void _filterSalidas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSalidas = _allSalidas.where((salida) {
        final folio = salida.salida_Folio?.toString() ?? '';
        return folio.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Salidas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por folio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredSalidas.isEmpty
                ? const Center(
                    child: Text('No hay salidas que coincidan con el folio'),
                  )
                : ListView.builder(
                    itemCount: _filteredSalidas.length,
                    itemBuilder: (context, index) {
                      final salida = _filteredSalidas[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: FutureBuilder<Productos?>(
                            future: _productosController
                                .getProductoById(salida.id_Producto!),
                            builder: (context, productoSnapshot) {
                              if (productoSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Cargando producto...');
                              } else if (productoSnapshot.hasError) {
                                return const Text('Error al cargar producto');
                              } else if (productoSnapshot.data == null) {
                                return const Text('Producto no encontrado');
                              } else {
                                return Text(
                                  '${productoSnapshot.data!.producto_Descripcion}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Proveedores?>(
                                future: _proveedoresController
                                    .getProveedorById(salida.id_Proveedor!),
                                builder: (context, proveedorSnapshot) {
                                  if (proveedorSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Cargando proveedor...');
                                  } else if (proveedorSnapshot.hasError) {
                                    return const Text(
                                        'Error al cargar proveedor');
                                  } else if (proveedorSnapshot.data == null) {
                                    return const Text(
                                        'Proveedor no encontrado');
                                  } else {
                                    return Text(
                                      '${proveedorSnapshot.data!.proveedor_Name}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Unidades: ${salida.salida_Unidades ?? 'No disponible'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Costo: \$${salida.salida_Costo}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              )
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Folio: ${salida.salida_Folio ?? "Sin Folio"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                salida.salida_Fecha ?? 'Sin Fecha',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
