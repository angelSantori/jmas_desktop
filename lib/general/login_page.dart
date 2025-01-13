import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/general/home_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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

  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isAccesVisible = false;

  void _submitForm() async {
    setState(() {
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
                  const SizedBox(height: 30),
                  //Usuario
                  CustomTextFieldAzul(
                    controller: _userNameController,
                    labelText: 'Acceso de Usuario',
                    isPassword: true,
                    isVisible: _isAccesVisible,
                    prefixIcon: Icons.person,
                    onVisibilityToggle: () {
                      setState(() {
                        _isAccesVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el acceso';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  //Contraseña
                  CustomTextFieldAzul(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    prefixIcon: Icons.lock,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la contraseña.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

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
