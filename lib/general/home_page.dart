import 'package:flutter/material.dart';
import 'package:jmas_desktop/ajustes_minus/add_ajuste_menos_page.dart';
import 'package:jmas_desktop/ajustes_plus/add_ajuste_mas_page.dart';
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
  String? _userName;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final decodeToken = await _authService.decodeToken();
    setState(() {
      _userName = decodeToken?['User_Name'];
      _userRole = decodeToken?[
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
    });
  }

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

  void _navigateToAddAjusteMas() {
    setState(() {
      _currentPage = const AddAjusteMasPage();
    });
  }

  void _navigateToAddAjusteMenos() {
    setState(() {
      _currentPage = const AddAjusteMenosPage();
    });
  }

  void _logOut() {
    showDialog(
      context: context,
      builder: (BuildContext cotext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _authService.deleteToken();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == "Admin";

    return Scaffold(
      body: Row(
        children: [
          // Menú lateral
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              children: [
                // Encabezado del menú
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: Image.asset('assets/images/logo_jmas_sf.png'),
                      ),
                      const SizedBox(height: 10),
                      if (_userName != null)
                        Text(
                          _userName!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        )
                    ],
                  ),
                ),
                // Contenido del menú con scroll
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Elementos del menú
                        ListTile(
                          title: const Row(
                            children: [
                              Icon(Icons.home, color: Colors.white),
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

                        // Productos (siempre accesibles)
                        CustomExpansionTile(
                          title: 'Productos',
                          icon: Icons.store,
                          children: [
                            CustomListTile(
                              title: 'Lista productos',
                              icon: Icons.list_alt_rounded,
                              onTap: _navigateToListProducto,
                            ),
                            if (isAdmin)
                              CustomListTile(
                                title: 'Agregar Producto',
                                icon: Icons.add_shopping_cart_rounded,
                                onTap: _navigateToAddProducto,
                              ),
                          ],
                        ),

                        // Proveedores (siempre accesibles)
                        CustomExpansionTile(
                          title: 'Proveedores',
                          icon: Icons.people,
                          children: [
                            CustomListTile(
                              title: 'Lista Proveedores',
                              icon: Icons.format_align_left_rounded,
                              onTap: _navigateToListProveedores,
                            ),
                            if (isAdmin)
                              CustomListTile(
                                title: 'Agregar Proveedor',
                                icon: Icons.add_box,
                                onTap: _navigateToAddProveedores,
                              ),
                          ],
                        ),

                        // Usuarios
                        CustomExpansionTile(
                          title: 'Usuarios',
                          icon: Icons.person,
                          children: [
                            CustomListTile(
                              title: 'Lista Usuarios',
                              icon: Icons.format_list_bulleted,
                              onTap: _navigateToListUsers,
                            ),
                            if (isAdmin)
                              CustomListTile(
                                title: 'Agregar Usuario',
                                icon: Icons.add_reaction_sharp,
                                onTap: _navigateToAddUsers,
                              ),
                          ],
                        ),

                        // Movimientos (solo accesibles para Admin)

                        CustomExpansionTile(
                          title: 'Movimientos',
                          icon: Icons.folder_copy_rounded,
                          children: [
                            SubCustomExpansionTile(
                              title: 'Entradas',
                              icon: Icons.abc,
                              children: [
                                CustomListTile(
                                  title: 'Agregar entrada',
                                  icon: Icons.move_down_sharp,
                                  onTap: _navigateToAddEntrada,
                                ),
                                CustomListTile(
                                  title: 'Lista de entradas',
                                  icon: Icons.line_style_sharp,
                                  onTap: _navigateToListEntradas,
                                ),
                              ],
                            ),
                            SubCustomExpansionTile(
                              title: 'Salidas',
                              icon: Icons.ac_unit,
                              children: [
                                CustomListTile(
                                  title: 'Agregar salida',
                                  icon: Icons.move_up_sharp,
                                  onTap: _navigateToAddSalida,
                                ),
                                CustomListTile(
                                  title: 'Lista de salidas',
                                  icon: Icons.list_alt_sharp,
                                  onTap: _navigateToListSalidas,
                                ),
                              ],
                            ),
                            SubCustomExpansionTile(
                              title: 'Ajustes',
                              icon: Icons.miscellaneous_services_outlined,
                              children: [
                                CustomListTile(
                                  title: 'Ajuste +',
                                  icon: Icons.add,
                                  onTap: _navigateToAddAjusteMas,
                                ),
                                CustomListTile(
                                  title: 'Ajuste -',
                                  icon: Icons.remove,
                                  onTap: _navigateToAddAjusteMenos,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent.shade400),
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
                  onTap: _logOut,
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Center(
                child: _currentPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
