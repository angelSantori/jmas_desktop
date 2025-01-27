import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entidades_controller.dart';
import 'package:jmas_desktop/enitdades/edit_entidad_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListEntidadesPage extends StatefulWidget {
  final String? userRole;
  const ListEntidadesPage({super.key, this.userRole});

  @override
  State<ListEntidadesPage> createState() => _ListEntidadesPageState();
}

class _ListEntidadesPageState extends State<ListEntidadesPage> {
  final EntidadesController _entidadesController = EntidadesController();
  final TextEditingController _searchController = TextEditingController();

  List<Entidades> _allEntidades = [];
  List<Entidades> _filteredEntidades = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntidades();
    _searchController.addListener(_filterEntidades);
  }

  Future<void> _loadEntidades() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final entidades = await _entidadesController.listEntidades();
      setState(() {
        _allEntidades = entidades;
        _filteredEntidades = entidades;
      });
    } catch (e) {
      print('Error list_entidades_page.dart: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterEntidades() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntidades = _allEntidades.where((entidad) {
        final name = entidad.entidad_Nombre?.toLowerCase() ?? '';
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar entidad',
                prefixIcon: Icons.search,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.blue.shade900,
                    ))
                  : _filteredEntidades.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay entidades que coincidan con la búsqueda'),
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
                          itemCount: _filteredEntidades.length,
                          itemBuilder: (context, index) {
                            final entidad = _filteredEntidades[index];

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
                                      '${entidad.entidad_Nombre}',
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
                                                    EditEntidadPage(
                                                        entidad: entidad),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadEntidades();
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
