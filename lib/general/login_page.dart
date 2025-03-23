import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/general/home_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  final UsersController _usersController = UsersController();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isAccesVisible = false;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation = Tween<Offset>(
      begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
      end: Offset.zero, // Termina en su posición original
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // Curva suave
      ),
    );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

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
    // Obtener el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(color: Color(0xFF3051BC)),
        child: Stack(
          children: [
            // Fondo con imagen personas.jpg
            Positioned(
              left: 0,
              top: screenHeight * 0.45, // Ajuste dinámico
              child: Opacity(
                opacity: 0.32,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.7,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/personas.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Barra superior
            Positioned(
              left: 0,
              top: screenHeight * 0.2,
              child: Opacity(
                opacity: 0.75,
                child: Container(
                  width: screenWidth,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF49BCC3)),
                ),
              ),
            ),
            // Barra inferior
            Positioned(
              left: 0,
              top: screenHeight * 0.41,
              child: Opacity(
                opacity: 0.75,
                child: Container(
                  width: screenWidth,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 84, 84, 85),
                  ),
                ),
              ),
            ),
            // Contenido principal centrado
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo y título "ALMACEN"
                        SlideTransition(
                          position: _animation,
                          child: Container(
                            width: screenWidth * 0.23, // Caja menos ancha
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                // Logo
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image:
                                          AssetImage("assets/images/logo1.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 3,
                                        offset: Offset(6, 9),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Título "ALMACEN"
                                const Text(
                                  'ALMACEN',
                                  style: TextStyle(
                                    color: Color(0xFF1F3567),
                                    fontSize: 35,
                                    fontFamily: 'Consolas',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Formulario de login
                        SlideTransition(
                          position: _animation,
                          child: Container(
                            width: screenWidth * 0.3,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Campo de usuario
                                CustomTextFieldAzul(
                                  controller: _userNameController,
                                  labelText: 'Acceso de Usuario',
                                  isPassword: false,
                                  isVisible: _isAccesVisible,
                                  prefixIcon: Icons.person,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isAccesVisible = !_isAccesVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa el acceso';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Campo de contraseña
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
                                const SizedBox(height: 20),
                                // Botón de inicio de sesión
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.blue.shade900,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
