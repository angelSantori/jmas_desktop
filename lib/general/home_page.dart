import 'package:flutter/material.dart';
import 'package:jmas_desktop/entradas/list_entrada_page.dart';
import 'package:jmas_desktop/general/login_page.dart';
import 'package:jmas_desktop/productos/add_producto_page.dart';
import 'package:jmas_desktop/productos/list_producto_page.dart';
import 'package:jmas_desktop/proveedores/add_proveedor_page.dart';
import 'package:jmas_desktop/proveedores/list_proveedor_page.dart';
import 'package:jmas_desktop/users/add_user_page.dart';
import 'package:jmas_desktop/users/list_user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                Theme(
                  data: Theme.of(context).copyWith(
                      expansionTileTheme: const ExpansionTileThemeData(
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    collapsedIconColor: Colors.white,
                  )),
                  child: ExpansionTile(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.maps_home_work_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Productos',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      //List Productos
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lista Productos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToListProducto,
                        ),
                      ),

                      //Add Producto
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Agregar Producto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToAddProducto,
                        ),
                      ),
                    ],
                  ),
                ),

                //Proveedores
                Theme(
                  data: Theme.of(context).copyWith(
                      expansionTileTheme: const ExpansionTileThemeData(
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white)),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cliente.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Proveedores',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      //List proveedores
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.format_align_center,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lista Proveedores',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToListProveedores,
                        ),
                      ),

                      //Add Proveedor
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Agregar Proveedor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToAddProveedores,
                        ),
                      ),
                    ],
                  ),
                ),
                //Usuarios
                Theme(
                  data: Theme.of(context).copyWith(
                      expansionTileTheme: const ExpansionTileThemeData(
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    collapsedIconColor: Colors.white,
                  )),
                  child: ExpansionTile(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Usuarios',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    children: [
                      //List User
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lista Usuarios',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToListUsers,
                        ),
                      ),

                      //Add User
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.add_reaction_sharp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Agregar Usuario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToAddUsers,
                        ),
                      )
                    ],
                  ),
                ),

                Theme(
                  data: Theme.of(context).copyWith(
                      expansionTileTheme: const ExpansionTileThemeData(
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    collapsedIconColor: Colors.white,
                  )),
                  child: ExpansionTile(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Entradas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: ListTile(
                          title: const Row(
                            children: [
                              Icon(
                                Icons.line_style_sharp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lista Entradas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: _navigateToListEntradas,
                        ),
                      )
                    ],
                  ),
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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
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
