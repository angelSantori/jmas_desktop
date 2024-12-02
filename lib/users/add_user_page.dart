import 'package:flutter/material.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userContactoController = TextEditingController();
  final TextEditingController _userAccessController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();

  final TextEditingController _passwordConfirmController =
      TextEditingController();

  String? _selectedRol;

  final List<String> _roles = ['Rol1', 'Rol2', 'Rol3', 'Rol4'];

  bool _isPasswordVisibles = false;
  bool _isConfirmPasswordVisible = false;

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
                                borderSide:
                                    BorderSide(color: Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
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
                                borderSide:
                                    BorderSide(color: Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
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
                                borderSide:
                                    BorderSide(color: Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
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
                                borderSide:
                                    BorderSide(color: Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
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
                                borderSide:
                                    BorderSide(color: Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: !_isConfirmPasswordVisible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  //Botón para enviar formulario
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
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
