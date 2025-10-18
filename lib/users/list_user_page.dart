import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/contollers/role_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  final TextEditingController _searchController = TextEditingController();
  final UsersController _usersController = UsersController();
  final RoleController _roleController = RoleController();

  List<Users> _allUsers = [];
  List<Users> _filteredUsers = [];
  List<Role> _roles = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _usersController.listUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      print('Error LISTUSERS: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleController.listRole();
      setState(() {
        _roles = roles;
      });
    } catch (e) {
      print('Error loading roles: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = user.user_Name?.toLowerCase() ?? '';
        final contacto = user.user_Contacto?.toLowerCase() ?? '';

        return name.contains(query) || contacto.contains(query);
      }).toList();
    });
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final contactoController = TextEditingController();
    final accesoController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Role? selectedRole;
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Agregar Usuario',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreController,
                    labelText: 'Nombre',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nombre obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldNumero(
                    controller: contactoController,
                    labelText: 'Contacto',
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contacto obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFielTexto(
                    controller: accesoController,
                    labelText: 'Acceso del usuario',
                    prefixIcon: Icons.person_4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Acceso obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo<Role>(
                          value: selectedRole,
                          labelText: 'Rol',
                          items: _roles,
                          onChanged: (valueRol) {
                            setDialogState(() {
                              selectedRole = valueRol;
                            });
                          },
                          validator: (valueRol) {
                            if (valueRol == null) {
                              return 'Debe seleccionar un rol';
                            }
                            return null;
                          },
                          itemLabelBuilder: (rol) =>
                              rol.roleNombre ?? 'Sin nombre',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldAzul(
                    controller: passwordController,
                    labelText: 'Contraseña',
                    isPassword: true,
                    isVisible: isPasswordVisible,
                    prefixIcon: Icons.lock,
                    onVisibilityToggle: () {
                      setDialogState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contraseña obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldAzul(
                    controller: confirmPasswordController,
                    labelText: 'Confirmar contraseña',
                    isPassword: true,
                    isVisible: isConfirmPasswordVisible,
                    prefixIcon: Icons.lock,
                    onVisibilityToggle: () {
                      setDialogState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirmar contraseña obligatorio';
                      }
                      if (value != passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    showAdvertence(context, 'Las contraseñas no coinciden');
                    return;
                  }
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                elevation: 2,
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final nuevoUsuario = Users(
        id_User: 0,
        user_Name: nombreController.text,
        user_Contacto: contactoController.text,
        user_Access: accesoController.text,
        user_Password: passwordController.text,
        user_Rol: selectedRole!.roleNombre,
        idRole: selectedRole!.idRole,
      );

      final success = await _usersController.addUser(nuevoUsuario, context);
      if (success) {
        showOk(context, 'Usuario agregado correctamente');
        _loadUsers();
      } else {
        showError(context, 'Error al agregar el usuario');
      }
    }
  }

  Future<void> _showEditDialog(Users user) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: user.user_Name);
    final contactoController = TextEditingController(text: user.user_Contacto);
    final accesoController = TextEditingController(text: user.user_Access);
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Role? selectedRole = _roles.firstWhere(
      (rol) => rol.idRole == user.idRole,
      orElse: () => _roles.first,
    );

    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Editar Usuario',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFielTexto(
                    controller: nombreController,
                    labelText: 'Nombre',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nombre obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldNumero(
                    controller: contactoController,
                    labelText: 'Contacto',
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contacto obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFielTexto(
                    controller: accesoController,
                    labelText: 'Acceso del usuario',
                    prefixIcon: Icons.person_4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Acceso obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo<Role>(
                          value: selectedRole,
                          labelText: 'Rol',
                          items: _roles,
                          onChanged: (valueRol) {
                            setDialogState(() {
                              selectedRole = valueRol;
                            });
                          },
                          validator: (valueRol) {
                            if (valueRol == null) {
                              return 'Debe seleccionar un rol';
                            }
                            return null;
                          },
                          itemLabelBuilder: (rol) =>
                              rol.roleNombre ?? 'Sin nombre',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldAzul(
                    controller: passwordController,
                    labelText: 'Nueva contraseña (opcional)',
                    isPassword: true,
                    isVisible: isPasswordVisible,
                    prefixIcon: Icons.lock,
                    onVisibilityToggle: () {
                      setDialogState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextFieldAzul(
                    controller: confirmPasswordController,
                    labelText: 'Confirmar nueva contraseña',
                    isPassword: true,
                    isVisible: isConfirmPasswordVisible,
                    prefixIcon: Icons.lock,
                    onVisibilityToggle: () {
                      setDialogState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (passwordController.text.isNotEmpty &&
                          value != passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                  if (passwordController.text.isNotEmpty &&
                      passwordController.text !=
                          confirmPasswordController.text) {
                    showAdvertence(context, 'Las contraseñas no coinciden');
                    return;
                  }
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                elevation: 2,
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final usuarioEditado = user.copyWith(
        user_Name: nombreController.text,
        user_Contacto: contactoController.text,
        user_Access: accesoController.text,
        user_Rol: selectedRole!.roleNombre,
        idRole: selectedRole!.idRole,
      );

      final success = await _usersController.editUser(
        usuarioEditado,
        context,
        password:
            passwordController.text.isEmpty ? null : passwordController.text,
      );

      if (success) {
        showOk(context, 'Usuario actualizado correctamente');
        _loadUsers();
      } else {
        showError(context, 'Error al actualizar el usuario');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de usuarios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextFielTexto(
                    controller: _searchController,
                    labelText: 'Buscar Usuario por Nombre o Contacto',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _showAddDialog,
                    tooltip: 'Agregar Usuario Nuevo',
                    iconSize: 30,
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900),
                    )
                  : _filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay usuarios que coincidan con la búsqueda'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];

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
                                    //Icono
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.contact_mail_outlined,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    //Info de Usuario
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Nombre
                                          Text(
                                            user.user_Name ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
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
                                                user.user_Contacto ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //User acceso
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.lock_open_outlined,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Acceso: ${user.user_Access}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                          //Rol
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.people,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Rol: ${user.user_Rol ?? "Sin rol"}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    //Editar
                                    IconButton(
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
                                      onPressed: () => _showEditDialog(user),
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
