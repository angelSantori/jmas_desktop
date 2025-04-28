import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/almacenes/edit_almacen_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListAlmacenesPage extends StatefulWidget {
  final String? userRole;
  const ListAlmacenesPage({super.key, this.userRole});

  @override
  State<ListAlmacenesPage> createState() => _ListAlmacenesPageState();
}

class _ListAlmacenesPageState extends State<ListAlmacenesPage> {
  final AlmacenesController _almacenesController = AlmacenesController();
  final TextEditingController _searchController = TextEditingController();

  List<Almacenes> _allAlmacenes = [];
  List<Almacenes> _filteredAlmacenes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlmacenes();
    _searchController.addListener(_filterAlmacenes);
  }

  Future<void> _loadAlmacenes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final almacenes = await _almacenesController.listAlmacenes();
      setState(() {
        _allAlmacenes = almacenes;
        _filteredAlmacenes = almacenes;
      });
    } catch (e) {
      print('Error list_almacenes_page.dart: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAlmacenes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAlmacenes = _allAlmacenes.where((almacen) {
        final name = almacen.almacen_Nombre?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Almacenes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar Almacén',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.blue.shade900,
                    ))
                  : _filteredAlmacenes.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay almacenes que coincidan con la búsqueda'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredAlmacenes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final almacen = _filteredAlmacenes[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Icono de almacen
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.store_mall_directory,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    //Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            almacen.almacen_Nombre ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Espacio para editar
                                    if (isAdmin || isGestion)
                                      IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditAlmacenPage(
                                                      almacen: almacen),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadAlmacenes();
                                          }
                                        },
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
}
