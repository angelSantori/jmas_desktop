import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/role_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  State<AdminRolePage> createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  final RoleController _roleController = RoleController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _roleNombreContr = TextEditingController();
  final TextEditingController _roleDescContr = TextEditingController();

  List<Role> _allRoles = [];
  List<Role> _filteredRoles = [];
  bool _isLoading = true;
  bool _isAdding = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterRoles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _roleNombreContr.dispose();
    _roleDescContr.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _roleController.listRole();
      setState(() {
        _allRoles = roles;
        _filteredRoles = roles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loadData | AdminRolePage: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterRoles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRoles = _allRoles.where((role) {
        final nombre = role.roleNombre?.toLowerCase() ?? '';
        final descripcion = role.roleDescr?.toLowerCase() ?? '';
        return nombre.contains(query) || descripcion.contains(query);
      }).toList();
    });
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
      _roleNombreContr.clear();
      _roleDescContr.clear();
    });
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final newRol = Role(
          idRole: 0,
          roleNombre: _roleNombreContr.text,
          roleDescr: _roleDescContr.text,
          canView: false,
          canAdd: false,
          canEdit: false,
          canDelete: false,
          canManageUsers: false,
          canManageRoles: false,
          canEvaluar: false,
          canCContables: false,
          canManageJuntas: false,
          canManageProveedores: false,
          canManageContratistas: false,
          canManageCalles: false,
          canManageColonias: false,
          canManageAlmacenes: false,
        );

        final success = await _roleController.addRol(newRol);
        if (success) {
          showOk(context, 'Rol registrado correctamente.');
          _cancelAdding();
          _loadData();
        } else {
          showError(context, 'Hubo un problema al registrar el rol.');
        }
      } catch (e) {
        showAdvertence(context, 'Error al registrar el rol: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(Role role) async {
    final success = await _roleController.editRole(role);
    if (success) {
      showOk(context, 'Rol actualizado correctamente');
      _loadData();
    } else {
      showError(context, 'Error al actualizar el rol');
    }
  }

  Widget _buildPermissionSection(
      String title, List<PermissionItem> permissions) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: permissions
                  .map((permission) => _buildPermissionChip(
                        permission.label,
                        permission.value,
                        permission.icon,
                        permission.onChanged,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionChip(
    String label,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16, color: value ? Colors.blue.shade900 : Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: value ? Colors.blue.shade900 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: value,
      onSelected: onChanged,
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: value ? Colors.blue.shade300 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildRolePermissions(Role role) {
    final basicPermissions = [
      PermissionItem('Ver', role.canView ?? false, Icons.visibility,
          (value) => _updateRole(role.copyWith(canView: value))),
      PermissionItem('Agregar', role.canAdd ?? false, Icons.add,
          (value) => _updateRole(role.copyWith(canAdd: value))),
      PermissionItem('Editar', role.canEdit ?? false, Icons.edit,
          (value) => _updateRole(role.copyWith(canEdit: value))),
      PermissionItem('Eliminar', role.canDelete ?? false, Icons.delete,
          (value) => _updateRole(role.copyWith(canDelete: value))),
    ];

    final managementPermissions = [
      PermissionItem(
          'Gestionar Usuarios',
          role.canManageUsers ?? false,
          Icons.people,
          (value) => _updateRole(role.copyWith(canManageUsers: value))),
      PermissionItem(
          'Gestionar Roles',
          role.canManageRoles ?? false,
          Icons.admin_panel_settings,
          (value) => _updateRole(role.copyWith(canManageRoles: value))),
      PermissionItem(
          'Ver Desarrollo',
          role.canSeeDesarrollo ?? false,
          Icons.developer_board,
          (value) => _updateRole(role.copyWith(canSeeDesarrollo: value)))
    ];

    final systemPermissions = [
      PermissionItem('Evaluar', role.canEvaluar ?? false, Icons.assessment,
          (value) => _updateRole(role.copyWith(canEvaluar: value))),
      PermissionItem(
          'Contabilidad',
          role.canCContables ?? false,
          Icons.account_balance,
          (value) => _updateRole(role.copyWith(canCContables: value))),
    ];

    final mantenimientoPermissions = [
      PermissionItem(
          'Gestionar Almacenes',
          role.canManageAlmacenes ?? false,
          Icons.warehouse,
          (value) => _updateRole(role.copyWith(canManageAlmacenes: value))),
      PermissionItem(
          'Gestionar Calles',
          role.canManageCalles ?? false,
          Icons.stream,
          (value) => _updateRole(role.copyWith(canManageCalles: value))),
      PermissionItem(
          'Gestionar Colonias',
          role.canManageColonias ?? false,
          Icons.map,
          (value) => _updateRole(role.copyWith(canManageColonias: value))),
      PermissionItem(
          'Gestionar Contratistas',
          role.canManageContratistas ?? false,
          Icons.engineering,
          (value) => _updateRole(role.copyWith(canManageContratistas: value))),
      PermissionItem(
          'Gestionar Juntas',
          role.canManageJuntas ?? false,
          Icons.groups,
          (value) => _updateRole(role.copyWith(canManageJuntas: value))),
      PermissionItem(
          'Gestionar Proveedores',
          role.canManageProveedores ?? false,
          Icons.local_shipping,
          (value) => _updateRole(role.copyWith(canManageProveedores: value))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildPermissionSection('Permisos Básicos', basicPermissions),
            const SizedBox(width: 20),
            _buildPermissionSection(
                'Gestión de Usuarios y Sistema', managementPermissions),
            const SizedBox(width: 20),
            _buildPermissionSection('Funciones del Sistema', systemPermissions),
          ],
        ),
        Row(
          children: [
            _buildPermissionSection(
                'Gestión de Mantenimiento', mantenimientoPermissions),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Barra de búsqueda y botón agregar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextFielTexto(
                    controller: _searchController,
                    labelText: 'Buscar rol por nombre o descripción',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _isAdding ? _cancelAdding : _startAdding,
                    tooltip: _isAdding ? 'Cancelar' : 'Agregar Nuevo Rol',
                    iconSize: 30,
                    icon: Icon(
                      _isAdding ? Icons.cancel : Icons.add_box,
                      color: _isAdding ? Colors.red : Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Formulario para agregar nuevo rol
            if (_isAdding) ...[
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Agregar Nuevo Rol',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFielTexto(
                          controller: _roleNombreContr,
                          labelText: 'Nombre del Rol',
                          validator: (nomRol) {
                            if (nomRol == null || nomRol.isEmpty) {
                              return 'Nombre es obligatorio.';
                            }
                            return null;
                          },
                          prefixIcon: Icons.manage_accounts,
                        ),
                        const SizedBox(height: 16),
                        CustomTextFielTexto(
                          controller: _roleDescContr,
                          labelText: 'Descripción del rol',
                          validator: (descRol) {
                            if (descRol == null || descRol.isEmpty) {
                              return 'Descripción es obligatoria.';
                            }
                            return null;
                          },
                          prefixIcon: Icons.description,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _cancelAdding,
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Registrar Rol',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Lista de roles
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900),
                    )
                  : _filteredRoles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.manage_accounts,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _allRoles.isEmpty
                                    ? 'No hay roles registrados'
                                    : 'No se encontraron roles que coincidan con la búsqueda',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredRoles.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final role = _filteredRoles[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header del rol
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.manage_accounts,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                role.roleNombre ??
                                                    'Rol sin nombre',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                              Text(
                                                role.roleDescr ??
                                                    'Sin descripción',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            'ID: ${role.idRole}',
                                            style: TextStyle(
                                              color: Colors.blue.shade800,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Permisos organizados en secciones
                                    _buildRolePermissions(role),
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

class PermissionItem {
  final String label;
  final bool value;
  final IconData icon;
  final Function(bool) onChanged;

  PermissionItem(this.label, this.value, this.icon, this.onChanged);
}
