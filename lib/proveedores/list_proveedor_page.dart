import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';

class ListProveedorPage extends StatefulWidget {
  const ListProveedorPage({super.key});

  @override
  State<ListProveedorPage> createState() => _ListProveedorPageState();
}

class _ListProveedorPageState extends State<ListProveedorPage> {
  final ProveedoresController _proveedoresController = ProveedoresController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lisa de Proveedores'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: FutureBuilder<List<Proveedores>>(
          future: _proveedoresController.listProveedores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay proveedores registrados'),
              );
            }

            final proveedores = snapshot.data!;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de tarjetas por fila
                crossAxisSpacing: 20, // Espacio horizontal entre tarjetas
                mainAxisSpacing: 20, // Espacio vertical entre tarjetas
                childAspectRatio:
                    6 / 2, // Proporción de ancho/alto de las tarjetas
              ),
              itemCount: proveedores.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final proveedor = proveedores[index];
                return Card(
                  color: Colors.blue.shade900,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${proveedor.proveedor_Name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Contacto: ${proveedor.proveedor_Phone}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Dirección: ${proveedor.proveedor_Address}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
