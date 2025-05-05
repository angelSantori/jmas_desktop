import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/herramientas_controller.dart';
import 'package:jmas_desktop/herramientas/edit_herramienta_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class LsitHerrameintasPage extends StatefulWidget {
  final String? userRole;
  const LsitHerrameintasPage({super.key, this.userRole});

  @override
  State<LsitHerrameintasPage> createState() => _LsitHerrameintasPageState();
}

class _LsitHerrameintasPageState extends State<LsitHerrameintasPage> {
  final HerramientasController _herramientasController =
      HerramientasController();
  final TextEditingController _searchController = TextEditingController();

  List<Herramientas> _allHtas = [];
  List<Herramientas> _filteredHtas = [];
  String? _selectedEstado;
  final List<String> _estados = [
    'Todos',
    'Disponible',
    'Prestada',
    'Mantenimiento'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterHtas);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final herramientas = await _herramientasController.lsitHtas();

      setState(() {
        _allHtas = herramientas;
        _filteredHtas = herramientas;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loadData | ListHtas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterHtas() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredHtas = _allHtas.where((herramientas) {
        final nombreHtas = herramientas.htaNombre?.toLowerCase() ?? '';
        final estadoHtas = herramientas.htaEstado?.toLowerCase() ?? '';

        final nombreMatch = nombreHtas.contains(query);
        final estadoMatch = _selectedEstado == null ||
            _selectedEstado == 'Todos' ||
            estadoHtas == _selectedEstado?.toLowerCase();

        return nombreMatch && estadoMatch;
      }).toList();
    });
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return Colors.grey;

    switch (estado.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'prestada':
        return Colors.red;
      case 'mantenimiento':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Herramientas'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFielTexto(
                      controller: _searchController,
                      labelText: 'Buscar herramienta por nombre',
                      prefixIcon: Icons.search,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomListaDesplegable(
                      value: _selectedEstado,
                      labelText: 'Filtrar por Estado',
                      items: _estados,
                      onChanged: (newVallue) {
                        setState(() {
                          _selectedEstado = newVallue;
                          _filterHtas();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900))
                  : _filteredHtas.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay herramientas que coincidan con los filtros'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredHtas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final herramientas = _filteredHtas[index];

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
                                        Icons.sports_cricket_outlined,
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
                                            herramientas.htaNombre ??
                                                'No disponible',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ID: ${herramientas.idHerramienta ?? 'No disponible'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Text(
                                                'Estado: ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Chip(
                                                label: Text(
                                                  herramientas.htaEstado ??
                                                      'No disponible',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    _getEstadoColor(
                                                        herramientas.htaEstado),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                              ),
                                            ],
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
                                                  EditHerramientaPage(
                                                      herramienta:
                                                          herramientas),
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
            )
          ],
        ),
      ),
    );
  }
}
