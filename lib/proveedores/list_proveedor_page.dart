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
  final TextEditingController _searchController = TextEditingController();

  List<Proveedores> _allProveedores = [];
  List<Proveedores> _filteredProveedores = [];

  @override
  void initState() {
    super.initState();
    _loadProveedores();
    _searchController.addListener(_filterProveedores);
  }

  Future<void> _loadProveedores() async {
    try {
      final proveedores = await _proveedoresController.listProveedores();
      setState(() {
        _allProveedores = proveedores;
        _filteredProveedores = proveedores;
      });
    } catch (e) {}
  }

  void _filterProveedores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProveedores = _allProveedores.where((proveedor) {
        final name = proveedor.proveedor_Name?.toLowerCase() ?? '';
        final contact = proveedor.proveedor_Phone?.toLowerCase() ?? '';
        return name.contains(query) || contact.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre o contacto',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _filteredProveedores.isEmpty
                  ? const Center(
                      child: Text(
                          'No hay proveedores que coincidan con la búsqueda'),
                    )
                  : ListView.builder(
                      itemCount: _filteredProveedores.length,
                      itemBuilder: (context, index) {
                        final proveedor = _filteredProveedores[index];

                        return Card(
                          color: Colors.blue.shade900,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                EditProveedorPage(
                                                    proveedor: proveedor),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadProveedores();
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
