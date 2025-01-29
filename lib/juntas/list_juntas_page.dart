import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/juntas/edit_junta_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListJuntasPage extends StatefulWidget {
  final String? userRole;
  const ListJuntasPage({super.key, this.userRole});

  @override
  State<ListJuntasPage> createState() => _ListJuntasPageState();
}

class _ListJuntasPageState extends State<ListJuntasPage> {
  final JuntasController _juntasController = JuntasController();
  final UsersController _usersController = UsersController();
  final TextEditingController _searchController = TextEditingController();

  List<Juntas> _allJuntas = [];
  List<Juntas> _filteredJuntas = [];
  Map<int, Users> _usersCache = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterJuntas);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final juntas = await _juntasController.listJuntas();
      final users = await _usersController.listUsers();

      setState(() {
        _allJuntas = juntas;
        _filteredJuntas = juntas;

        _usersCache = {for (var us in users) us.id_User!: us};

        _isLoading = false;
      });
    } catch (e) {
      print('Error list_juntas_page: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterJuntas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJuntas = _allJuntas.where((junta) {
        final name = junta.junta_Name?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole == "Admin";
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Jutnas'),
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
                labelText: 'Buscar junta',
                prefixIcon: Icons.search,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.blue.shade900,
                    ))
                  : _filteredJuntas.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay juntas que coincidan con la búsqueda.'),
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
                          itemCount: _filteredJuntas.length,
                          itemBuilder: (context, index) {
                            final junta = _filteredJuntas[index];
                            final user = _usersCache[junta.id_User];

                            return Card(
                              color: const Color.fromARGB(255, 201, 230, 242),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${junta.junta_Name}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      user != null
                                          ? 'Encargado: ${user.user_Name}'
                                          : 'Encargado: No disponible',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Teléfono: ${junta.junta_Telefono ?? 'Sin número'}',
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
                                                    EditJuntaPage(junta: junta),
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
