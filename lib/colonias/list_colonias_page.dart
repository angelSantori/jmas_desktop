import 'package:flutter/material.dart';
import 'package:jmas_desktop/colonias/edit_colonias_page.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListColoniasPage extends StatefulWidget {
  final String? userRole;
  const ListColoniasPage({super.key, this.userRole});

  @override
  State<ListColoniasPage> createState() => _ListColoniasPageState();
}

class _ListColoniasPageState extends State<ListColoniasPage> {
  final ColoniasController _coloniasController = ColoniasController();
  final TextEditingController _searchController = TextEditingController();

  List<Colonias> _allColonias = [];
  List<Colonias> _filteredColonias = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterColonias);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final colonias = await _coloniasController.listColonias();

      setState(() {
        _allColonias = colonias;
        _filteredColonias = colonias;

        _isLoading = false;
      });
    } catch (e) {
      print('Error loadData | ListPage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterColonias() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredColonias = _allColonias.where((colonia) {
        final nombreColonia = colonia.nombreColonia?.toLowerCase() ?? '';

        return nombreColonia.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Colonias'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Buscar colonia por nombre',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900))
                  : _filteredColonias.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay colonias que coincidan con la búsqueda'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredColonias.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final colonias = _filteredColonias[index];

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
                                        Icons.map_rounded,
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
                                          //Nombre
                                          Text(
                                            colonias.nombreColonia ??
                                                'No disponible',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
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
                                                  EditColoniasPage(
                                                      colonia: colonias),
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
