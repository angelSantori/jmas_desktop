import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/general/home_page.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>
    with SingleTickerProviderStateMixin {
  final UsersController _usersController = UsersController();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isAccesVisible = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(
          -1.0, 0.0), // Comienza fuera de la pantalla a la izquierda
      end: Offset.zero, // Termina en su posición normal
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    // Iniciar la animación después de un breve delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        top: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 8,
              child: Container(
                width: 100,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1900FF), Color(0xFFECFDFB)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0, -1),
                    end: AlignmentDirectional(0, 1),
                  ),
                ),
                alignment: const AlignmentDirectional(0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SlideTransition(
                              position: _slideAnimation,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeIn,
                                width: 386.53,
                                height: 200,
                                decoration: const BoxDecoration(
                                  color: Colors.white, // Reemplazo de .info
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    alignment: AlignmentDirectional(-1.2, 0),
                                    image: AssetImage(
                                      'assets/images/logo_jmas_sf.png',
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                      spreadRadius: 10,
                                    )
                                  ],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(50),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                  ),
                                ),
                                child: const Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        60, 0, 0, 0),
                                    child: Text(
                                      'ALMACEN',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: 'InterTight',
                                        fontSize: 50,
                                        color: Color(0xFF0E0097),
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 9,
                                  color: Colors.grey.shade700,
                                  offset: const Offset(5, 6),
                                  spreadRadius: 5,
                                )
                              ],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, 10),
                                      child: Text(
                                        'Bienvenido de Vuelta',
                                        style: TextStyle(
                                          fontFamily: 'InterTight',
                                          fontSize: 25,
                                          color: Color(0xFF0100FF),
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          shadows: [
                                            Shadow(
                                              color: Colors.grey,
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 3.0,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 16),
                                      child: SizedBox(
                                        width: 370,
                                        child: CustomTextFieldAzul(
                                          controller: _userNameController,
                                          labelText: 'Acceso de Usuario',
                                          isPassword: false,
                                          isVisible: _isAccesVisible,
                                          prefixIcon: Icons.person,
                                          onVisibilityToggle: () {
                                            setState(() {
                                              _isAccesVisible =
                                                  !_isAccesVisible;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor ingresa el acceso';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 16),
                                      child: SizedBox(
                                        width: 370,
                                        child: CustomTextFieldAzul(
                                          controller: _passwordController,
                                          labelText: 'Contraseña',
                                          isPassword: true,
                                          isVisible: _isPasswordVisible,
                                          prefixIcon: Icons.lock,
                                          onVisibilityToggle: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor ingresa la contraseña.';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      width: 356.87,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _submitForm,
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
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  alignment: AlignmentDirectional(-0.1, 0),
                  image: AssetImage('assets/images/personas.jpg'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
