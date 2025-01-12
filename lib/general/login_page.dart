import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/general/home_page.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsersController _usersController = UsersController();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isSubmitted = false;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isAccesVisible = false;

  void _submitForm() async {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final success = await _usersController.loginUser(
          _userNameController.text,
          _passwordController.text,
          context,
        );

        if (success) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ));
        } else {
          showAdvertence(
              context, 'Usuario o contraseña incorrectos. Inténtalo de nuevo.');
        }
      } catch (e) {
        showAdvertence(context, 'Error al inicar sesión: $e');
      }
    } else {
      showAdvertence(context, 'Por favor introduce usuario y contraseña.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 200, right: 200),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //Logo
                  SizedBox(
                    height: 300,
                    child: Image.asset('assets/images/logo_jmas_sf.png'),
                  ),
                  const SizedBox(height: 50),
                  //Usuario
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        child: Text(
                          'User Access: ',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: InputDecoration(
                            labelText: 'User Access',
                            suffixIcon: IconButton(
                              icon: Icon(_isAccesVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isAccesVisible = !_isAccesVisible;
                                });
                              },
                            ),
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
                              return 'Por favor ingresa user access.';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          obscureText: !_isAccesVisible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _isSubmitted &&
                                            _passwordController.text.isEmpty
                                        ? Colors.red
                                        : Colors.blue.shade900)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa la contraseña';
                            }
                            return null;
                          },
                          obscureText: !_isPasswordVisible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Botón
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
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
