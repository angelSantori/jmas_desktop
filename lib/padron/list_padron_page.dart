import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/padron/edit_padron_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListPadronPage extends StatefulWidget {
  final String? userRole;
  const ListPadronPage({super.key, this.userRole});

  @override
  State<ListPadronPage> createState() => _ListPadronPageState();
}

class _ListPadronPageState extends State<ListPadronPage> {
  final PadronController _padronController = PadronController();

  final TextEditingController _searchController = TextEditingController();

  List<Padron> _allPadron = [];
  List<Padron> _filteredPadron = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPadron);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final padrones = await _padronController.listPadron();

      setState(() {
        _allPadron = padrones;
        _filteredPadron = padrones;

        _isLoading = false;
      });
    } catch (e) {
      print('Error list_padron_pdage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPadron() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPadron = _allPadron.where((padron) {
        final nombre = padron.padronNombre?.toLowerCase() ?? '';
        final direccion = padron.padronDireccion?.toLowerCase() ?? '';
        final id = padron.idPadron.toString();

        return nombre.contains(query) ||
            direccion.contains(query) ||
            id.contains(query);
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
                labelText: 'Buscar padron',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade900,
                      ),
                    )
                  : _filteredPadron.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay algún padron que conicida con la búsqueda.'),
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
                          itemCount: _filteredPadron.length,
                          itemBuilder: (context, index) {
                            final padron = _filteredPadron[index];

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
                                      '${padron.padronNombre}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Id: ${padron.idPadron}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Dirección: ${padron.padronDireccion}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
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
                                                    EditPadronPage(
                                                        padron: padron),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadData();
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
