import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListColoniasPage extends StatefulWidget {
  const ListColoniasPage({super.key});

  @override
  State<ListColoniasPage> createState() => _ListColoniasPageState();
}

class _ListColoniasPageState extends State<ListColoniasPage> {
  final ColoniasController _coloniasController = ColoniasController();
  final TextEditingController _searchController = TextEditingController();

  List<Colonias> _allColonias = [];
  List<Colonias> _filteredColonias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterColonias);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Colonia',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la colonia',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la colonia obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.map_rounded,
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
      final nuevaColonia = Colonias(
        idColonia: 0,
        nombreColonia: nombreController.text,
      );

      final success = await _coloniasController.addColonia(nuevaColonia);
      if (success) {
        showOk(context, 'Nueva colonia agregada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al agregar la nueva colonia');
      }
    }
  }

  Future<void> _showEditDialog(Colonias colonia) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: colonia.nombreColonia);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Colonia',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la colonia',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la colonia obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.map_rounded,
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
      final coloniaEditada = colonia.copyWith(
        idColonia: colonia.idColonia,
        nombreColonia: nombreController.text,
      );

      final success = await _coloniasController.editColonia(coloniaEditada);

      if (success) {
        showOk(context, 'Colonia actualizada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al actualizar la colonia');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Colonias',
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
                    controller: _searchController,
                    labelText: 'Buscar colonia por nombre',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageColonia',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Colonia Nueva',
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
                  : _filteredColonias.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay colonias que coincidan con la búsqueda',
                          ),
                        )
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
                                            '${colonias.idColonia} - ${colonias.nombreColonia ?? 'Sin Nombre'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ID: ${colonias.idColonia ?? 'No disponible'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PermissionWidget(
                                      permission: 'manageColonia',
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
                                            _showEditDialog(colonias),
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
