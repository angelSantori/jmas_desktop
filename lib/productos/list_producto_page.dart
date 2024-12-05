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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: FutureBuilder<List<Productos>>(
          future: _productosController.listProductos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay productos registrados'),
              );
            }

            final productos = snapshot.data!;

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return Card(
                  color: Colors.blue.shade900,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Imagen del producto
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/sinFoto.jpg',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${producto.producto_Descripcion}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //Costo
                              Text(
                                'Costo: \$${producto.producto_Costo}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //Existencias & Unidad de Medida
                              Text(
                                'Existencias: ${producto.producto_Existencia} ${producto.producto_UMedida}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //Existencia Inicial $ Unidad de Medida
                              Text(
                                'Existencias iniciales: ${producto.producto_ExistenciaInicial} ${producto.producto_UMedida}',
                                style: const TextStyle(
                                  color: Colors.white,
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
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProductoPage(producto: producto),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {});
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
