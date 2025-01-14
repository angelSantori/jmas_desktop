import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final UsersController _usersController = UsersController();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userContactoController = TextEditingController();
  final TextEditingController _userAccessController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ignore: unused_field
  bool _isSubmitted = false;
  bool _isLoading = false;

  String? _selectedRol;

  final List<String> _roles = ['Admin', 'Sistemas', 'Gestion', 'Electro'];

  bool _isPasswordVisibles = false;
  bool _isConfirmPasswordVisible = false;

  void _clearFOrm() {
    _userNameController.clear();
    _userContactoController.clear();
    _userAccessController.clear();
    _userPasswordController.clear();
    _passwordConfirmController.clear();
    setState(() {
      _selectedRol = null;
    });
  }

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (_userPasswordController.text != _passwordConfirmController.text) {
        showAdvertence(context, 'Contraseñas no coinciden');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final user = Users(
          id_User: 0,
          user_Name: _userNameController.text,
          user_Contacto: _userContactoController.text,
          user_Access: _userAccessController.text,
          user_Password: _userPasswordController.text,
          user_Rol: _selectedRol,
        );

        final success = await _usersController.addUser(user, context);

        if (success) {
          showOk(context, 'Usuario registrado exitosamente.');
          _formKey.currentState?.reset();
          _clearFOrm();
        } else {
          showError(context, 'Hubo un problema al registrar al usuario.');
        }
      } catch (e) {
        showAdvertence(
            context, 'Por favor complete todos los campos correctamente.');
      }
    } else {
      showAdvertence(
          context, 'Por favor completa todos los campos obligatorios.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar usuario'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 100, right: 100),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        //Nombre
                        child: CustomTextFielTexto(
                          controller: _userNameController,
                          labelText: 'Nombre',
                          prefixIcon: Icons.person,
                          validator: (name) {
                            if (name == null || name.isEmpty) {
                              return 'Nombre obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Contacto
                      Expanded(
                        child: CustomTextFieldNumero(
                          controller: _userContactoController,
                          labelText: 'Contacto',
                          prefixIcon: Icons.phone,
                          validator: (numero) {
                            if (numero == null || numero.isEmpty) {
                              return 'Contacto obligatorio.';
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
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _userAccessController,
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
                          value: _selectedRol,
                          labelText: 'Rol',
                          items: _roles,
                          onChanged: (value) {
                            setState(() {
                              _selectedRol = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      //Contraseña
                      Expanded(
                        child: CustomTextFieldAzul(
                          controller: _userPasswordController,
                          labelText: 'Contraseña',
                          isPassword: true,
                          isVisible: _isPasswordVisibles,
                          prefixIcon: Icons.lock,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisibles = !_isPasswordVisibles;
                            });
                          },
                          validator: (pass) {
                            if (pass == null || pass.isEmpty) {
                              return 'Contraseña obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 30),

                      //Confirm contraseña
                      Expanded(
                        child: CustomTextFieldAzul(
                          controller: _passwordConfirmController,
                          labelText: 'Confirmar contraseña',
                          isPassword: true,
                          isVisible: _isConfirmPasswordVisible,
                          prefixIcon: Icons.lock,
                          onVisibilityToggle: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (pass) {
                            if (pass == null || pass.isEmpty) {
                              return 'Confirmar contraseña obligatorio.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  //Botón para enviar formulario
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Guardar usuario',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
