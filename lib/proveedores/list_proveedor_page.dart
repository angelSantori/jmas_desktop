import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/proveedores/edit_proveedor_page.dart';

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

            return ListView.builder(
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                final proveedor = proveedores[index];

                return Card(
                  color: Colors.blue.shade900,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Name proveedor
                              Text(
                                '${proveedor.proveedor_Name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //Phone proveedor
                              Text(
                                'Contacto: ${proveedor.proveedor_Phone}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              //Address proveedor
                              Text(
                                'Dirección: ${proveedor.proveedor_Address}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),

                        //Editar
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
                                        EditProveedorPage(proveedor: proveedor),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {});
                                }
                              },
                            ),
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
