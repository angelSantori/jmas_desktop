import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/productos/edit_producto_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListProductoPage extends StatefulWidget {
  final String? userRole;
  const ListProductoPage({super.key, required this.userRole});

  @override
  State<ListProductoPage> createState() => _ListProductoPageState();
}

class _ListProductoPageState extends State<ListProductoPage> {
  final ProductosController _productosController = ProductosController();
  final TextEditingController _searchController = TextEditingController();

  List<Productos> _allProductos = [];
  List<Productos> _filteredProductos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
  }

  Future<void> _loadProductos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final productos = await _productosController.listProductos();
      setState(() {
        _allProductos = productos;
        _filteredProductos = productos;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductos = _allProductos.where((producto) {
        final descripcion = producto.prodDescripcion?.toLowerCase() ?? '';
        final clave = producto.id_Producto.toString();
        return descripcion.contains(query) || clave.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: Column(
          children: [
            const SizedBox(height: 5),
            CustomTextFielTexto(
              controller: _searchController,
              labelText: 'Buscar por descrición o clave',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900),
                    )
                  : _filteredProductos.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay productos que coincidan con la búsqueda'),
                        )
                      : ListView.builder(
                          itemCount: _filteredProductos.length,
                          itemBuilder: (context, index) {
                            final producto = _filteredProductos[index];
                            return Card(
                              color: const Color.fromARGB(255, 201, 230, 242),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: producto.prodImgB64 != null &&
                                              producto.prodImgB64!.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(
                                                  producto.prodImgB64!),
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/sinFoto.jpg',
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${producto.prodDescripcion}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Clave: ${producto.id_Producto}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Costo: \$${producto.prodCosto}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Existencias: ${producto.prodExistencia} ${producto.prodUMedSalida}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isAdmin)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProductoPage(
                                                          producto: producto),
                                                ),
                                              );
                                              if (result == true) {
                                                _loadProductos();
                                              }
                                            },
                                          ),
                                        ],
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
