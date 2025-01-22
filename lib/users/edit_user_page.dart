import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  String? _selectedRole;
  final List<String> _roles = ['Admin', 'Sistemas', 'Gestion', 'Electro'];

  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
    if (_passwordController.text.isNotEmpty ||
        _passwordConfirmController.text.isNotEmpty) {
      if (_passwordController.text != _passwordConfirmController.text) {
        showAdvertence(context, 'Contraseñas no coinciden.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
    if (_formKey.currentState!.validate()) {
      final updateUser = widget.user.copyWith(
        user_Name: _nameController.text,
        user_Contacto: _contactoController.text,
        user_Access: _accessController.text,
        user_Rol: _selectedRole!,
      );

      final result = await _usersController.editUser(
        updateUser,
        context,
        password:
            _passwordController.text.isEmpty ? null : _passwordController.text,
      );

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
                  Row(
                    children: [
                      //Nombre
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _nameController,
                          labelText: 'Nombre',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre no puede estar vacío';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Contacto
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _contactoController,
                          labelText: 'Contacto',
                          prefixIcon: Icons.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El contacto no puede estar vacío';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      //Acceso
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _accessController,
                          labelText: 'Acceso del usuario',
                          prefixIcon: Icons.person_4,
                          validator: (access) {
                            if (access == null || access.isEmpty) {
                              return 'Acceso de usuario obligatorio.';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                        ),
                      ),

                      const SizedBox(width: 30),

                      Expanded(
                        child: CustomListaDesplegable(
                          value: _selectedRole,
                          labelText: 'Rol',
                          items: _roles,
                          onChanged: (rol) {
                            setState(() {
                              _selectedRole = rol;
                            });
                          },
                          validator: (rol) {
                            if (rol == null || rol.isEmpty) {
                              return 'Rol obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  //Contraseña
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFieldAzul(
                          controller: _passwordController,
                          labelText: 'Nueva contraseña',
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          prefixIcon: Icons.lock,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: CustomTextFieldAzul(
                          controller: _passwordConfirmController,
                          labelText: 'Confirmar nueva contraseña',
                          isPassword: true,
                          isVisible: _isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          prefixIcon: Icons.lock,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

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
