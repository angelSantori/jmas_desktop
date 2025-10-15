import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListJuntasPage extends StatefulWidget {
  const ListJuntasPage({super.key});

  @override
  State<ListJuntasPage> createState() => _ListJuntasPageState();
}

class _ListJuntasPageState extends State<ListJuntasPage> {
  final JuntasController _juntasController = JuntasController();
  final TextEditingController _searchController = TextEditingController();

  List<Juntas> _allJuntas = [];
  List<Juntas> _filteredJuntas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterJuntas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final juntas = await _juntasController.listJuntas();

      setState(() {
        _allJuntas = juntas;
        _filteredJuntas = juntas;
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
        final contacto = junta.junta_Telefono?.toLowerCase() ?? '';
        final encargado = junta.junta_Encargado?.toLowerCase() ?? '';
        final cuenta = junta.junta_Cuenta?.toLowerCase() ?? '';

        return name.contains(query) ||
            contacto.contains(query) ||
            encargado.contains(query) ||
            cuenta.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final encargadoController = TextEditingController();
    final cuentaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Junta',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la junta',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la junta obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.factory,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: encargadoController,
                labelText: 'Encargado',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: cuentaController,
                labelText: 'Cuenta',
                prefixIcon: Icons.numbers,
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
      final nuevaJunta = Juntas(
        id_Junta: 0,
        junta_Name: nombreController.text,
        junta_Telefono: telefonoController.text,
        junta_Encargado: encargadoController.text,
        junta_Cuenta: cuentaController.text,
      );

      final success = await _juntasController.addJunta(nuevaJunta);
      if (success) {
        showOk(context, 'Nueva junta agregada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al agregar la nueva junta');
      }
    }
  }

  Future<void> _showEditDialog(Juntas junta) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: junta.junta_Name);
    final telefonoController =
        TextEditingController(text: junta.junta_Telefono);
    final encargadoController =
        TextEditingController(text: junta.junta_Encargado);
    final cuentaController = TextEditingController(text: junta.junta_Cuenta);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Junta',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre de la junta',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre de la junta obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.factory,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: encargadoController,
                labelText: 'Encargado',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: cuentaController,
                labelText: 'Cuenta',
                prefixIcon: Icons.numbers,
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
      final juntaEditada = junta.copyWith(
        id_Junta: junta.id_Junta,
        junta_Name: nombreController.text,
        junta_Telefono: telefonoController.text,
        junta_Encargado: encargadoController.text,
        junta_Cuenta: cuentaController.text,
      );

      final success = await _juntasController.editJunta(juntaEditada);

      if (success) {
        showOk(context, 'Junta actualizada correctamente');
        _loadData();
      } else {
        showError(context, 'Error al actualizar la junta');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Juntas',
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
                    labelText:
                        'Buscar por Nombre, Contacto, Encargado o Cuenta',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageJunta',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Junta Nueva',
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
                  : _filteredJuntas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay juntas que coincidan con la búsqueda',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredJuntas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final junta = _filteredJuntas[index];

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
                                        Icons.factory,
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
                                            '${junta.id_Junta} - ${junta.junta_Name ?? 'Sin Nombre'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          //Contacto
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                (junta.junta_Telefono == null ||
                                                        junta.junta_Telefono!
                                                            .isEmpty)
                                                    ? 'Sin contacto'
                                                    : junta.junta_Telefono!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //Encargado
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  (junta.junta_Encargado ==
                                                              null ||
                                                          junta.junta_Encargado!
                                                              .isEmpty)
                                                      ? 'Sin encargado'
                                                      : junta.junta_Encargado!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //Cuenta
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.numbers,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  (junta.junta_Cuenta == null ||
                                                          junta.junta_Cuenta!
                                                              .isEmpty)
                                                      ? 'Sin cuenta'
                                                      : junta.junta_Cuenta!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PermissionWidget(
                                      permission: 'manageJunta',
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
                                        onPressed: () => _showEditDialog(junta),
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
