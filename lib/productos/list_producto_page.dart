import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/productos/edit_producto_page.dart';

class ListProductoPage extends StatefulWidget {
  const ListProductoPage({super.key});

  @override
  State<ListProductoPage> createState() => _ListProductoPageState();
}

class _ListProductoPageState extends State<ListProductoPage> {
  final ProductosController _productosController = ProductosController();
  final TextEditingController _searchController = TextEditingController();

  List<Productos> _allProductos = [];
  List<Productos> _filteredProductos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
  }

  Future<void> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      setState(() {
        _allProductos = productos;
        _filteredProductos = productos;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductos = _allProductos.where((producto) {
        final descripcion = producto.producto_Descripcion?.toLowerCase() ?? '';
        final clave = producto.id_Producto.toString();
        return descripcion.contains(query) || clave.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: Column(
          children: [
            const SizedBox(height: 5),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por descripción o clave',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredProductos.isEmpty
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
                                  child: producto.producto_ImgBase64 != null &&
                                          producto
                                              .producto_ImgBase64!.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(
                                              producto.producto_ImgBase64!),
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
                                        '${producto.producto_Descripcion}',
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
                                        'Costo: \$${producto.producto_Costo}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Existencias: ${producto.producto_Existencia} ${producto.producto_UMedida}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Existencias iniciales: ${producto.producto_ExistenciaInicial} ${producto.producto_UMedida}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                        final result = await Navigator.push(
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
