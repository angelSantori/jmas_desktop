import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditUserPage extends StatefulWidget {
  final Users user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final UsersController _usersController = UsersController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _contactoController;
  late TextEditingController _accessController;
  late TextEditingController _passwordController;

  String? _selectedRole;
  final List<String> _roles = ['Admin', 'Sistemas', 'Gestion', 'Electro'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.user_Name);
    _contactoController =
        TextEditingController(text: widget.user.user_Contacto);
    _accessController = TextEditingController(text: widget.user.user_Access);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.user_Rol;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactoController.dispose();
    _accessController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      final updateUser = widget.user.copyWith(
        user_Name: _nameController.text,
        user_Contacto: _contactoController.text,
        user_Access: _accessController.text,
        user_Rol: _selectedRole!,
      );

      final result = await _usersController.editUser(updateUser, context);
      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Usuario editado correctamente.');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al editar el usuario.');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Nombre
                  buildFormRow(
                    label: 'Nombre:',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Contacto
                  buildFormRow(
                    label: 'Contacto:',
                    child: TextFormField(
                      controller: _contactoController,
                      decoration: const InputDecoration(labelText: 'Contacto'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El contacto no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Access
                  buildFormRow(
                    label: 'Acceso:',
                    child: TextFormField(
                      controller: _accessController,
                      decoration:
                          const InputDecoration(labelText: 'Palabra de acceso'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La palabra de acceso no puede estar vacía';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Rol
                  buildFormRow(
                    label: 'Rol:',
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: _roles
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Rol'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe seleccionar un rol';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Contraseña
                  buildFormRow(
                    label: 'Nueva contraseña:',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Nueva contraseña'),
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Botón
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
