import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListAlmacenesPage extends StatefulWidget {
  const ListAlmacenesPage({super.key});

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Almacén',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del almacén',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del almacén obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.store_mall_directory,
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
      final nuevoAlmacen = Almacenes(
        id_Almacen: 0,
        almacen_Nombre: nombreController.text,
      );

      final success = await _almacenesController.addAlmacen(nuevoAlmacen);
      if (success) {
        showOk(context, 'Nuevo almacén agregado correctamente');
        _loadAlmacenes();
      } else {
        showError(context, 'Error al agregar el nuevo almacén');
      }
    }
  }

  Future<void> _showEditDialog(Almacenes almacen) async {
    final formKey = GlobalKey<FormState>();
    final nombreController =
        TextEditingController(text: almacen.almacen_Nombre);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Almacén',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del almacén',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del almacén obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.store_mall_directory,
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
      final almacenEditado = almacen.copyWith(
        id_Almacen: almacen.id_Almacen,
        almacen_Nombre: nombreController.text,
      );

      final success = await _almacenesController.editAlmacen(almacenEditado);

      if (success) {
        showOk(context, 'Almacén actualizado correctamente');
        _loadAlmacenes();
      } else {
        showError(context, 'Error al actualizar el almacén');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Almacenes',
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
                    labelText: 'Buscar Almacén',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageAlmacen',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Almacén Nuevo',
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
                  : _filteredAlmacenes.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay almacenes que coincidan con la búsqueda',
                          ),
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
                                            '${almacen.id_Almacen} - ${almacen.almacen_Nombre ?? 'Sin Nombre'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ID: ${almacen.id_Almacen ?? 'No disponible'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Espacio para editar
                                    PermissionWidget(
                                      permission: 'manageAlmacen',
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
                                            _showEditDialog(almacen),
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
