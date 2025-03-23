import 'package:flutter/material.dart';

class Desktop1 extends StatelessWidget {
  // Controladores para los campos de texto
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(color: const Color(0xFF3051BC)),
        child: Stack(
          children: [
            // Fondo con imagen personas.jpg
            Positioned(
              left: -7,
              top: screenHeight * 0.3, // Ajuste dinámico
              child: Opacity(
                opacity: 0.32,
                child: Container(
                  width: screenWidth * 1.01, // Ajuste dinámico
                  height: screenHeight * 0.7, // Ajuste dinámico
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/personas.jpg"), // Imagen local
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Barra superior
            Positioned(
              left: 0,
              top: screenHeight * 0.2, // Ajuste dinámico
              child: Opacity(
                opacity: 0.75,
                child: Container(
                  width: screenWidth,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF49BCC3)),
                ),
              ),
            ),
            // Contenedor del formulario de login
            Positioned(
              left: screenWidth * 0.2, // Ajuste dinámico
              top: screenHeight * 0.3, // Ajuste dinámico
              child: Container(
                width: screenWidth * 0.6, // Ajuste dinámico
                height: screenHeight * 0.5, // Ajuste dinámico
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Logo
                    Positioned(
                      left: (screenWidth * 0.6 - 100) / 2, // Centrar el logo
                      top: 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/images/logo1.jpg"), // Imagen local
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Título "ALMACEN"
                    Positioned(
                      left: 0,
                      top: 140,
                      child: SizedBox(
                        width: screenWidth * 0.6,
                        child: Text(
                          'ALMACEN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF1F3567),
                            fontSize: 36,
                            fontFamily: 'Consolas',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    // Campo de usuario
                    Positioned(
                      left: 50,
                      top: 200,
                      child: Container(
                        width: screenWidth * 0.5, // Ajuste dinámico
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E2E4),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFF6F2F2),
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _usuarioController,
                            decoration: InputDecoration(
                              hintText: 'USUARIO',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Consolas',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Campo de contraseña
                    Positioned(
                      left: 50,
                      top: 280,
                      child: Container(
                        width: screenWidth * 0.5, // Ajuste dinámico
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E2E4),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFF6F2F2),
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _contrasenaController,
                            obscureText: true, // Ocultar texto de la contraseña
                            decoration: InputDecoration(
                              hintText: 'CONTRASEÑA',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Consolas',
                                fontWeight: FontWeight.w400,
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
          ],
        ),
      ),
    );
  }
}
