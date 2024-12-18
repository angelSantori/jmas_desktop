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

  late Future<List<Salidas>> _futureSalidas;

  @override
  void initState() {
    super.initState();
    _futureSalidas = _salidasController.listSalidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Salidas'),
      ),
      body: FutureBuilder<List<Salidas>>(
        future: _futureSalidas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar entradas: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay entradas disponibles'),
            );
          }

          final salidas = snapshot.data!;

          return ListView.builder(
            itemCount: salidas.length,
            itemBuilder: (context, index) {
              final salida = salidas[index];
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
                            return const Text('Error al cargar proveedor');
                          } else if (proveedorSnapshot.data == null) {
                            return const Text('Proveedor no encontrado');
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
          );
        },
      ),
    );
  }
}
