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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar almacen',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),
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
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 1200
                                ? 4
                                : screenWidth > 800
                                    ? 3
                                    : screenWidth > 600
                                        ? 2
                                        : 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 30,
                            childAspectRatio: screenWidth > 1200
                                ? 1.8
                                : screenWidth > 800
                                    ? 1
                                    : screenWidth > 600
                                        ? 1
                                        : 1.5,
                          ),
                          itemCount: _filteredAlmacenes.length,
                          itemBuilder: (context, index) {
                            final almacen = _filteredAlmacenes[index];

                            return Card(
                              color: const Color.fromARGB(255, 201, 230, 242),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${almacen.almacen_Nombre}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    //Espacio para editar
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
                                                    EditAlmacenPage(
                                                        almacen: almacen),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadAlmacenes();
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
          ],
        ),
      ),
    );
  }
}
