import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:jmas_desktop/widgets/mensajes.dart'; // Asegúrate de importar esto

class ListProveedorPage extends StatefulWidget {
  const ListProveedorPage({super.key});

  @override
  State<ListProveedorPage> createState() => _ListProveedorPageState();
}

class _ListProveedorPageState extends State<ListProveedorPage> {
  final ProveedoresController _proveedoresController = ProveedoresController();
  final TextEditingController _searchController = TextEditingController();

  List<Proveedores> _allProveedores = [];
  List<Proveedores> _filteredProveedores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProveedores();
    _searchController.addListener(_filterProveedores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProveedores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final proveedores = await _proveedoresController.listProveedores();
      setState(() {
        _allProveedores = proveedores;
        _filteredProveedores = proveedores;
      });
    } catch (e) {
      print('Error list_proveedor_page.dart: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProveedores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProveedores = _allProveedores.where((proveedor) {
        final name = proveedor.proveedor_Name?.toLowerCase() ?? '';
        final contact = proveedor.proveedor_Phone?.toLowerCase() ?? '';
        final direccion = proveedor.proveedor_Address?.toLowerCase() ?? '';
        final numCuenta = proveedor.proveedor_NumeroCuenta?.toLowerCase() ?? '';

        return name.contains(query) ||
            contact.contains(query) ||
            direccion.contains(query) ||
            numCuenta.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final direccionController = TextEditingController();
    final numCuentaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Proveedor',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del proveedor',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del proveedor obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: direccionController,
                labelText: 'Dirección',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: numCuentaController,
                labelText: 'Número de cuenta',
                prefixIcon: Icons.content_paste,
              )
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
      final nuevoProveedor = Proveedores(
        id_Proveedor: 0,
        proveedor_Name: nombreController.text,
        proveedor_Phone: telefonoController.text,
        proveedor_Address: direccionController.text,
        proveedor_NumeroCuenta: numCuentaController.text,
      );

      final success = await _proveedoresController.addProveedor(nuevoProveedor);
      if (success) {
        showOk(context, 'Nuevo proveedor agregado correctamente');
        _loadProveedores();
      } else {
        showError(context, 'Error al agregar el nuevo proveedor');
      }
    }
  }

  Future<void> _showEditDialog(Proveedores proveedor) async {
    final formKey = GlobalKey<FormState>();
    final nombreController =
        TextEditingController(text: proveedor.proveedor_Name);
    final telefonoController =
        TextEditingController(text: proveedor.proveedor_Phone);
    final direccionController =
        TextEditingController(text: proveedor.proveedor_Address);
    final numCuentaController =
        TextEditingController(text: proveedor.proveedor_NumeroCuenta);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Editar Proveedor',
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFielTexto(
                controller: nombreController,
                labelText: 'Nombre del proveedor',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre del proveedor obligatorio';
                  }
                  return null;
                },
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: telefonoController,
                labelText: 'Teléfono',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: direccionController,
                labelText: 'Dirección',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              CustomTextFielTexto(
                controller: numCuentaController,
                labelText: 'Número de cuenta',
                prefixIcon: Icons.content_paste,
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
      final proveedorEditado = proveedor.copyWith(
          id_Proveedor: proveedor.id_Proveedor,
          proveedor_Name: nombreController.text,
          proveedor_Phone: telefonoController.text,
          proveedor_Address: direccionController.text,
          proveedor_NumeroCuenta: numCuentaController.text);

      final success =
          await _proveedoresController.editProveedor(proveedorEditado);

      if (success) {
        showOk(context, 'Proveedor actualizado correctamente');
        _loadProveedores();
      } else {
        showError(context, 'Error al actualizar el proveedor');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Proveedores',
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
                        'Buscar Proveedor por Nombre, Contacto, Dirección o Número de Cuenta',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  PermissionWidget(
                    permission: 'manageProveedor',
                    child: IconButton(
                        onPressed: _showAddDialog,
                        tooltip: 'Agregar Proveedor Nuevo',
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
                  : _filteredProveedores.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay proveedores que coincidan con la búsqueda',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredProveedores.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final proveedor = _filteredProveedores[index];

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
                                    // Icono de proveedor
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.business,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Información del proveedor
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nombre
                                          Text(
                                            '${proveedor.id_Proveedor} - ${proveedor.proveedor_Name ?? 'Sin Nombre'}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Contacto
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                proveedor.proveedor_Phone
                                                            ?.isEmpty ??
                                                        true
                                                    ? 'Sin teléfono'
                                                    : proveedor
                                                        .proveedor_Phone!,
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
                                                  proveedor.proveedor_Address
                                                              ?.isEmpty ??
                                                          true
                                                      ? 'Sin dirección'
                                                      : proveedor
                                                          .proveedor_Address!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //Número cuenta
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.content_paste_rounded,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  proveedor.proveedor_NumeroCuenta
                                                              ?.isEmpty ??
                                                          true
                                                      ? 'Sin número de cuenta'
                                                      : proveedor
                                                          .proveedor_NumeroCuenta!,
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
                                    // Botón de editar (solo para admin)
                                    PermissionWidget(
                                      permission: 'manageProveedor',
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
                                            _showEditDialog(proveedor),
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
