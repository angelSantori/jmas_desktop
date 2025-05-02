import 'package:flutter/material.dart';
import 'package:jmas_desktop/calles/edit_calles_page.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListCallesPage extends StatefulWidget {
  final String? userRole;
  const ListCallesPage({super.key, this.userRole});

  @override
  State<ListCallesPage> createState() => _ListCallesPageState();
}

class _ListCallesPageState extends State<ListCallesPage> {
  final CallesController _callesController = CallesController();
  final TextEditingController _searchText = TextEditingController();

  List<Calles> _allCalles = [];
  List<Calles> _filteredCalles = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchText.addListener(_filterCalles);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final calles = await _callesController.listCalles();

      setState(() {
        _allCalles = calles;
        _filteredCalles = calles;

        _isLoading = false;
      });
    } catch (e) {
      print('Error Calles | loadData | ListPage: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterCalles() {
    final query = _searchText.text.toLowerCase();

    setState(() {
      _filteredCalles = _allCalles.where((calle) {
        final nombreCalle = calle.calleNombre?.toLowerCase() ?? '';

        return nombreCalle.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Calles'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomTextFielTexto(
                controller: _searchText,
                labelText: 'Buscar calle por nombre',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900))
                  : _filteredCalles.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay calles que coincidan con la búsqueda.'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredCalles.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final calles = _filteredCalles[index];

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
                                  ),
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
                                    //Icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                        Icons.straighten_sharp,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    //Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Nombre
                                          Text(
                                            calles.calleNombre ??
                                                'No disponible',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
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
                                                  EditCallesPage(calle: calles),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadData();
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
