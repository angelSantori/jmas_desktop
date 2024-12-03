import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
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
                  //Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Nombre: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del usuario',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _userNameController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Contacto
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Contacto: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _userContactoController,
                          decoration: InputDecoration(
                            labelText: 'Contacto del usuario',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _userAccessController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un contacto.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Acceso
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Acceso: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _userAccessController,
                          decoration: InputDecoration(
                            labelText: 'Acceso del usuario',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _userAccessController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una clave de acceso.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Rol
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Rol del usuario: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRol,
                          decoration: const InputDecoration(
                              labelText: 'Rol del usuario',
                              border: OutlineInputBorder()),
                          items: _roles.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRol = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor selecciona un rol de usuario.';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Contraseña
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Contraseña: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _userPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña del usuario',
                            suffix: IconButton(
                              icon: Icon(
                                _isPasswordVisibles
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisibles = !_isPasswordVisibles;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _userPasswordController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña.';
                            }
                            return null;
                          },
                          obscureText: !_isPasswordVisibles,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Confirmar Contraseña
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'Confirmar contraseña: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordConfirmController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña del usuario',
                            suffix: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _passwordConfirmController
                                                .text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma la contraseña.';
                            }
                            return null;
                          },
                          obscureText: !_isConfirmPasswordVisible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

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
