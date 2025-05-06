import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/role_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  State<AdminRolePage> createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  final RoleController _roleController = RoleController();
  List<Role> _roles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final roles = await _roleController.listRole();
    setState(() {
      _roles = roles;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.blue.shade900))
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _roles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final role = _roles[index];
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.manage_accounts,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                role.roleNombre ?? 'Rol sin nombre',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            role.roleDescr ?? 'Sin descripción',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildPermissionChip(
                                  'Ver',
                                  role.canView ?? false,
                                  Icons.visibility,
                                  (value) => _updateRole(
                                      role.copyWith(canView: value))),
                              _buildPermissionChip(
                                  'Editar',
                                  role.canEdit ?? false,
                                  Icons.edit,
                                  (value) => _updateRole(
                                      role.copyWith(canEdit: value))),
                              _buildPermissionChip(
                                  'Eliminar',
                                  role.canDelete ?? false,
                                  Icons.delete,
                                  (value) => _updateRole(
                                      role.copyWith(canDelete: value))),
                              _buildPermissionChip(
                                  'Gestionar Usuarios',
                                  role.canManageUsers ?? false,
                                  Icons.people,
                                  (value) => _updateRole(
                                      role.copyWith(canManageUsers: value))),
                              _buildPermissionChip(
                                  'Gestionar Roles',
                                  role.canManageRoles ?? false,
                                  Icons.admin_panel_settings,
                                  (value) => _updateRole(
                                      role.copyWith(canManageRoles: value))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
    return Container(
      decoration: BoxDecoration(
        color: value ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? Colors.blue.shade300 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18, color: value ? Colors.blue.shade900 : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: value ? Colors.blue.shade900 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.blue.shade900,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
