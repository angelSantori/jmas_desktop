import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListCallesPage extends StatefulWidget {
  const ListCallesPage({super.key});

  @override
  State<ListCallesPage> createState() => _ListCallesPageState();
}

class _ListCallesPageState extends State<ListCallesPage> {
  final CallesController _callesController = CallesController();
  final TextEditingController _searchText = TextEditingController();

  List<Calles> _allCalles = [];
  List<Calles> _filteredCalles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchText.addListener(_filterCalles);
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
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

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Calle',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la calle',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la calle obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.straighten_sharp,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade900,
              elevation: 2,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final nuevaCalle = Calles(
        idCalle: 0,
        calleNombre: nombreController.text,
      );

      final success = await _callesController.addCalles(nuevaCalle);
      if (success) {
        showOk(context, 'Nueva calle agregada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al agregar la nueva calle');
      }
    }
  }

  Future<void> _showEditDialog(Calles calle) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: calle.calleNombre);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Calle',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la calle',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la calle obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.straighten_sharp,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade900,
              elevation: 2,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final calleEditada = calle.copyWith(
        idCalle: calle.idCalle,
        calleNombre: nombreController.text,
      );

      final success = await _callesController.editCalles(calleEditada);

      if (success) {
        showOk(context, 'Calle actualizada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al actualizar la calle');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Calles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextFielTexto(
                    controller: _searchText,
                    labelText: 'Buscar calle por nombre',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageCalle',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Calle Nueva',
                        iconSize: 30,
                        icon: Icon(
                          Icons.add_box,
                          color: Colors.blue.shade900,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.indigo.shade900,
                      ),
                    )
                  : _filteredCalles.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay calles que coincidan con la búsqueda',
                          ),
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
                                    const SizedBox(width: 16),
                                    //Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Nombre
                                          Text(
                                            '${calles.idCalle} - ${calles.calleNombre ?? 'Sin Nombre'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ID: ${calles.idCalle ?? 'No disponible'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    PermissionWidget(
                                      permission: 'manageCalle',
                                      child: IconButton(
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
                                        onPressed: () =>
                                            _showEditDialog(calles),
                                      ),
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
