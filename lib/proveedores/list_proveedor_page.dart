import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/proveedores/edit_proveedor_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListProveedorPage extends StatefulWidget {
  final String? userRole;
  const ListProveedorPage({super.key, this.userRole});

  @override
  State<ListProveedorPage> createState() => _ListProveedorPageState();
}

class _ListProveedorPageState extends State<ListProveedorPage> {
  final ProveedoresController _proveedoresController = ProveedoresController();
  final TextEditingController _searchController = TextEditingController();

  List<Proveedores> _allProveedores = [];
  List<Proveedores> _filteredProveedores = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProveedores();
    _searchController.addListener(_filterProveedores);
  }

  Future<void> _loadProveedores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final proveedores = await _proveedoresController.listProveedores();
      setState(() {
        _allProveedores = proveedores;
        _filteredProveedores = proveedores;
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    final isAdmin = widget.userRole == "Admin";
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar por nombre o contacto',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900),
                    )
                  : _filteredProveedores.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay proveedores que coincidan con la búsqueda'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 800
                                ? 4
                                : screenWidth > 600
                                    ? 3
                                    : 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 30,
                            childAspectRatio: screenWidth > 800
                                ? 1
                                : screenWidth > 600
                                    ? 2.5
                                    : 2,
                          ),
                          itemCount: _filteredProveedores.length,
                          itemBuilder: (context, index) {
                            final proveedor = _filteredProveedores[index];

                            return Card(
                              color: const Color.fromARGB(255, 201, 230, 242),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${proveedor.proveedor_Name}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    //Phone proveedor
                                    Text(
                                      'Contacto: ${proveedor.proveedor_Phone}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    //Address proveedor
                                    Text(
                                      'Dirección: ${proveedor.proveedor_Address}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),

                                    //Editar
                                    if (isAdmin)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                            size: 20,
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
                                      )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 30),
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
