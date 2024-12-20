import 'package:flutter/material.dart';
import 'package:jmas_desktop/entradas/add_entrada_page.dart';
import 'package:jmas_desktop/entradas/list_entrada_page.dart';
import 'package:jmas_desktop/general/login_page.dart';
import 'package:jmas_desktop/productos/add_producto_page.dart';
import 'package:jmas_desktop/productos/list_producto_page.dart';
import 'package:jmas_desktop/proveedores/add_proveedor_page.dart';
import 'package:jmas_desktop/proveedores/list_proveedor_page.dart';
import 'package:jmas_desktop/salidas/add_salida_page.dart';
import 'package:jmas_desktop/salidas/list_salida_page.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/users/add_user_page.dart';
import 'package:jmas_desktop/users/list_user_page.dart';
import 'package:jmas_desktop/widgets/componentes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  Widget _currentPage = const Center(
    child: Text('Welcome to home Page!'),
  );

  void _navigateToAddProducto() {
    setState(() {
      _currentPage = const AddProductoPage();
    });
  }

  void _navigateToAddUsers() {
    setState(() {
      _currentPage = const AddUserPage();
    });
  }

  void _navigateToListProducto() {
    setState(() {
      _currentPage = const ListProductoPage();
    });
  }

  void _navigateToListUsers() {
    setState(() {
      _currentPage = const ListUserPage();
    });
  }

  void _navigateToListEntradas() {
    setState(() {
      _currentPage = const ListEntradaPage();
    });
  }

  void _navigateToListProveedores() {
    setState(() {
      _currentPage = const ListProveedorPage();
    });
  }

  void _navigateToAddProveedores() {
    setState(() {
      _currentPage = const AddProveedorPage();
    });
  }

  void _navigateToHome() {
    setState(() {
      _currentPage = const Center(
        child: Text('Welcome to home Page!'),
      );
    });
  }

  void _navigateToAddEntrada() {
    setState(() {
      _currentPage = const AddEntradaPage();
    });
  }

  void _navigateToAddSalida() {
    setState(() {
      _currentPage = const AddSalidaPage();
    });
  }

  void _navigateToListSalidas() {
    setState(() {
      _currentPage = const ListSalidaPage();
    });
  }

  void _logOut() {
    _authService.deleteToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                ListTile(
                  title: const Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: _navigateToHome,
                ),

                //Productos
                CustomExpansionTile(
                  title: 'Productos',
                  icon: Icons.maps_home_work_outlined,
                  children: [
                    CustomListTile(
                      title: 'Lista productos',
                      icon: Icons.list_alt_rounded,
                      onTap: _navigateToListProducto,
                    ),
                    CustomListTile(
                      title: 'Agregar Producto',
                      icon: Icons.add_shopping_cart_rounded,
                      onTap: _navigateToAddProducto,
                    ),
                  ],
                ),

                //Proveedores
                CustomExpansionTile(
                  title: 'Proveedores',
                  icon: Icons.people,
                  children: [
                    CustomListTile(
                      title: 'Lista Proveedores',
                      icon: Icons.format_align_left_rounded,
                      onTap: _navigateToListProveedores,
                    ),
                    CustomListTile(
                      title: 'Agragar Proveedor',
                      icon: Icons.add_box,
                      onTap: _navigateToAddProveedores,
                    ),
                  ],
                ),

                //Usuarios
                CustomExpansionTile(
                  title: 'Usuarios',
                  icon: Icons.person,
                  children: [
                    CustomListTile(
                      title: 'Lista Usuarios',
                      icon: Icons.format_list_bulleted,
                      onTap: _navigateToListUsers,
                    ),
                    CustomListTile(
                      title: 'Agregar Usuario',
                      icon: Icons.add_reaction_sharp,
                      onTap: _navigateToAddUsers,
                    ),
                  ],
                ),

                //Movimientos
                CustomExpansionTile(
                  title: 'Movimientos',
                  icon: Icons.folder_copy_rounded,
                  children: [
                    CustomListTile(
                      title: 'Entradas',
                      icon: Icons.move_down_sharp,
                      onTap: _navigateToAddEntrada,
                    ),
                    CustomListTile(
                      title: 'Lista Entradas',
                      icon: Icons.line_style_sharp,
                      onTap: _navigateToListEntradas,
                    ),
                    CustomListTile(
                      title: 'Salidas',
                      icon: Icons.move_up_sharp,
                      onTap: _navigateToAddSalida,
                    ),
                    CustomListTile(
                      title: 'Lista Salidas',
                      icon: Icons.list_alt_sharp,
                      onTap: _navigateToListSalidas,
                    ),
                  ],
                ),

                //Salir Logout
                const Spacer(),
                ListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.redAccent.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Salir',
                        style: TextStyle(
                          color: Colors.redAccent.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar cierre de seisón.'),
                          content: const Text(
                              '¿Estás seguro de que deseas cerrar sesión?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Salir'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      _logOut();
                    }
                  },
                ),
              ],
            ),
          ),

          //Sección principal con el contenido
          Expanded(
            child: Center(
              child: _currentPage,
            ),
          )
        ],
      ),
    );
  }
}
