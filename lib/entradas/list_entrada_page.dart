import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';

class ListEntradaPage extends StatefulWidget {
  const ListEntradaPage({super.key});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final EntradasController _entradasController = EntradasController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  late Future<List<Entradas>> _futureEntradas;

  @override
  void initState() {
    super.initState();
    _futureEntradas = _entradasController.listEntradas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Entradas'),
      ),
      body: FutureBuilder<List<Entradas>>(
        future: _futureEntradas,
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
          final entradas = snapshot.data!;
          return ListView.builder(
            itemCount: entradas.length,
            itemBuilder: (context, index) {
              final entrada = entradas[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: FutureBuilder<Productos?>(
                    future: _productosController
                        .getProductoById(entrada.id_Producto!),
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
                            .getProveedorById(entrada.id_Proveedor!),
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
                        'Unidades: ${entrada.entrada_Unidades ?? "No disponible"}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Costo: \$${entrada.entrada_Costo}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  trailing: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Folio: ${entrada.entrada_Folio ?? "Sin Folio"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entrada.entrada_Fecha ?? 'Sin Fecha',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
