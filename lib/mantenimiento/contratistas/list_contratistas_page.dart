import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/contratistas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListContratistasPage extends StatefulWidget {
  const ListContratistasPage({super.key});

  @override
  State<ListContratistasPage> createState() => _ListContratistasPageState();
}

class _ListContratistasPageState extends State<ListContratistasPage> {
  final ContratistasController _contratistasController =
      ContratistasController();
  final TextEditingController _searchController = TextEditingController();

  List<Contratistas> _allContratistas = [];
  List<Contratistas> _filteredContratistas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContratistas();
    _searchController.addListener(_filterContratistas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContratistas() async {
    setState(() => _isLoading = true);
    try {
      final contratistas = await _contratistasController.listContratistas();
      setState(() {
        _allContratistas = contratistas;
        _filteredContratistas = contratistas;
      });
    } catch (e) {
      print('Error _loadContratistas | listContratistasPage: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterContratistas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContratistas = _allContratistas.where(
        (contratista) {
          final nombre = contratista.contratistaNombre.toLowerCase();
          final telefono = contratista.contratistaTelefono.toLowerCase();
          final direccion = contratista.contratistaDireccion.toLowerCase();
          final numCuenta = contratista.contratistaNumeroCuenta.toLowerCase();

          return nombre.contains(query) ||
              telefono.contains(query) ||
              direccion.contains(query) ||
              numCuenta.contains(query);
        },
      ).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final direccionController = TextEditingController();
    final cuentaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Contratista',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del contratista',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del contratista obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Teléfono obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: direccionController,
                labelText: 'Dirección',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dirección obligatoria';
                  }
                  return null;
                },
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: cuentaController,
                labelText: 'Número de cuenta',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de cuenta obligatorio';
                  }
                  return null;
                },
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
      final nuevoContratista = Contratistas(
        idContratista: 0,
        contratistaNombre: nombreController.text,
        contratistaTelefono: telefonoController.text,
        contratistaDireccion: direccionController.text,
        contratistaNumeroCuenta: cuentaController.text,
      );

      final success =
          await _contratistasController.addContratista(nuevoContratista);
      if (success) {
        showOk(context, 'Nuevo contratista agregado correctamente');
        _loadContratistas();
      } else {
        showError(context, 'Error al agregar el nuevo contratista');
      }
    }
  }

  Future<void> _showEditDialog(Contratistas contratista) async {
    final formKey = GlobalKey<FormState>();
    final nombreController =
        TextEditingController(text: contratista.contratistaNombre);
    final telefonoController =
        TextEditingController(text: contratista.contratistaTelefono);
    final direccionController =
        TextEditingController(text: contratista.contratistaDireccion);
    final cuentaController =
        TextEditingController(text: contratista.contratistaNumeroCuenta);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Contratista',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del contratista',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del contratista obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Teléfono obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: direccionController,
                labelText: 'Dirección',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dirección obligatoria';
                  }
                  return null;
                },
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: cuentaController,
                labelText: 'Número de cuenta',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Número de cuenta obligatorio';
                  }
                  return null;
                },
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
      final contratistaEditado = contratista.copyWith(
        idContratista: contratista.idContratista,
        contratistaNombre: nombreController.text,
        contratistaTelefono: telefonoController.text,
        contratistaDireccion: direccionController.text,
        contratistaNumeroCuenta: cuentaController.text,
      );

      final success =
          await _contratistasController.editContratista(contratistaEditado);

      if (success) {
        showOk(context, 'Contratista actualizado correctamente');
        _loadContratistas();
      } else {
        showError(context, 'Error al actualizar el contratista');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Contratistas',
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
                        'Buscar por Nombre, Teléfono, Dirección o Cuenta',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageContratista',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Contratista Nuevo',
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
                  : _filteredContratistas.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay contratistas que coincidan con la búsqueda',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredContratistas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final contratista = _filteredContratistas[index];

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
                                    // Icono
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.engineering,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nombre
                                          Text(
                                            '${contratista.idContratista} - ${contratista.contratistaNombre}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Teléfono
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                contratista.contratistaTelefono,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // Dirección
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  contratista
                                                      .contratistaDireccion,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // Número de cuenta
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
                                                  contratista
                                                      .contratistaNumeroCuenta,
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
                                      permission: 'manageContratista',
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
                                            _showEditDialog(contratista),
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
