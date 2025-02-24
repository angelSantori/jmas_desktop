import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmas_desktop/ajustes_minus/add_ajuste_menos_page.dart';
import 'package:jmas_desktop/ajustes_plus/add_ajuste_mas_page.dart';
import 'package:jmas_desktop/almacenes/add_almacen_page.dart';
import 'package:jmas_desktop/almacenes/list_almacenes_page.dart';
import 'package:jmas_desktop/cancelaciones/list_cancelados_page.dart';
import 'package:jmas_desktop/entradas/add_entrada_page.dart';
import 'package:jmas_desktop/entradas/list_entrada_page.dart';
import 'package:jmas_desktop/general/login_page.dart';
import 'package:jmas_desktop/juntas/add_junta_page.dart';
import 'package:jmas_desktop/juntas/list_juntas_page.dart';
import 'package:jmas_desktop/padron/list_padron_page.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  String? userName;
  String? userRole;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: -250, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final decodeToken = await _authService.decodeToken();
    setState(() {
      userName = decodeToken?['User_Name'];
      userRole = decodeToken?[
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
    });
  }

  Widget _currentPage = const Center(
    child: Text('Welcome to home Page!'),
  );

  // Método para obtener el Map de rutas
  Map<String, Widget Function()> _getRoutes() {
    return {
      'addProducto': () => const AddProductoPage(),
      'addUser': () => const AddUserPage(),
      'listProducto': () => ListProductoPage(userRole: userRole),
      'listUser': () => const ListUserPage(),
      'listEntradas': () => ListEntradaPage(userRole: userRole),
      'listProveedores': () => ListProveedorPage(userRole: userRole),
      'addProveedores': () => const AddProveedorPage(),
      'home': () => const Center(child: Text('Welcome to home Page!')),
      'addEntrada': () => AddEntradaPage(userName: userName),
      'addSalida': () => AddSalidaPage(userName: userName),
      'listSalidas': () => const ListSalidaPage(),
      'addAjusteMas': () => const AddAjusteMasPage(),
      'addAjusteMenos': () => const AddAjusteMenosPage(),
      'listAlmacenes': () => ListAlmacenesPage(userRole: userRole),
      'addAlmacenes': () => const AddAlmacenPage(),
      'listJuntas': () => ListJuntasPage(userRole: userRole),
      'addJunta': () => const AddJuntaPage(),
      'listCancelados': () => const ListCanceladosPage(),
      'listPadron': () => ListPadronPage(userRole: userRole),
    };
  }

  void _navigateTo(String routeName) {
    final routes = _getRoutes(); // Obtén el Map de rutas
    if (routes.containsKey(routeName)) {
      setState(() {
        _currentPage = routes[routeName]!();
      });
    } else {
      throw ArgumentError('Invalid route name: $routeName');
    }
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
    final isAdmin = userRole == "Admin";

    return Scaffold(
      body: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0),
                child: child,
              );
            },
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(12, 16),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Encabezado del menú
                  Container(
                    height: 150,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: Image.asset('assets/images/logo_jmas_sf.png'),
                        ),
                        const SizedBox(height: 10),
                        if (userName != null)
                          Text(
                            userName!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
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
                            onTap: () => _navigateTo('home'),
                          ),

                          CustomExpansionTile(
                            title: 'Mantenimiento',
                            icon: SvgPicture.asset(
                              'assets/icons/mantenimiento.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            children: [
                              //Productos
                              SubCustomExpansionTile(
                                title: 'Productos',
                                icon: SvgPicture.asset(
                                  'assets/icons/caja_abierta.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista productos',
                                    icon: SvgPicture.asset(
                                      'assets/icons/listprod.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listProducto'),
                                  ),
                                  if (isAdmin)
                                    CustomListTile(
                                      title: 'Agregar Producto',
                                      icon: SvgPicture.asset(
                                        'assets/icons/addprod.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addProducto'),
                                    ),
                                ],
                              ),

                              //Proveedores
                              SubCustomExpansionTile(
                                title: 'Proveedores',
                                icon: const Icon(Icons.person),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Proveedores',
                                    icon: SvgPicture.asset(
                                      'assets/icons/listprov.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listProveedores'),
                                  ),
                                  if (isAdmin)
                                    CustomListTile(
                                      title: 'Agregar Proveedor',
                                      icon: const Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addProveedores'),
                                    ),
                                ],
                              ),

                              //Almacenes
                              SubCustomExpansionTile(
                                title: 'Almacen',
                                icon: SvgPicture.asset(
                                  'assets/icons/almacen.svg',
                                  height: 20,
                                  width: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista almacenes',
                                    icon: const Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listAlmacenes'),
                                  ),
                                  if (isAdmin)
                                    CustomListTile(
                                      title: 'Agregar almacen',
                                      icon: const Icon(
                                        Icons.add_business_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addAlmacenes'),
                                    ),
                                ],
                              ),

                              //Juntas
                              SubCustomExpansionTile(
                                title: 'Juntas',
                                icon: const Icon(
                                  Icons.location_city_outlined,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista juntas',
                                    icon: SvgPicture.asset(
                                      'assets/icons/listjuntas.svg',
                                      color: Colors.white,
                                      height: 20,
                                      width: 20,
                                    ),
                                    onTap: () => _navigateTo('listJuntas'),
                                  ),
                                  if (isAdmin)
                                    CustomListTile(
                                      title: 'Agregar Junta',
                                      icon: const Icon(
                                        Icons.add_home_work_sharp,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addJunta'),
                                    ),
                                ],
                              ),

                              //Padrones
                              SubCustomExpansionTile(
                                title: 'Padrones',
                                icon: SvgPicture.asset(
                                  'assets/icons/social.svg',
                                  color: Colors.white,
                                  width: 20,
                                  height: 20,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Padrones',
                                    icon: SvgPicture.asset(
                                      'assets/icons/padronlist.svg',
                                      color: Colors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                    onTap: () => _navigateTo('listPadron'),
                                  ),
                                ],
                              ),

                              //Usuarios
                              if (isAdmin)
                                SubCustomExpansionTile(
                                  title: 'Usuarios',
                                  icon: const Icon(
                                    Icons.person_pin,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    CustomListTile(
                                      title: 'Lista Usuarios',
                                      icon: const Icon(
                                        Icons.format_list_numbered_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('listUser'),
                                    ),
                                    CustomListTile(
                                      title: 'Agregar Usuario',
                                      icon: const Icon(
                                        Icons.add_reaction_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addUser'),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Movimientos
                          CustomExpansionTile(
                            title: 'Movimientos',
                            icon: const Icon(Icons.compare_arrows_sharp),
                            children: [
                              SubCustomExpansionTile(
                                title: 'Entradas',
                                icon: const Icon(
                                    Icons.arrow_circle_right_outlined),
                                children: [
                                  CustomListTile(
                                    title: 'Agregar entrada',
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('addEntrada'),
                                  ),
                                  CustomListTile(
                                    title: 'Lista de entradas',
                                    icon: const Icon(
                                      Icons.list,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listEntradas'),
                                  ),
                                  CustomListTile(
                                    title: 'Cancelados',
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listCancelados'),
                                  ),
                                ],
                              ),
                              SubCustomExpansionTile(
                                title: 'Salidas',
                                icon: const Icon(
                                    Icons.arrow_circle_left_outlined),
                                children: [
                                  CustomListTile(
                                    title: 'Agregar salida',
                                    icon: const Icon(
                                      Icons.add_box_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('addSalida'),
                                  ),
                                  CustomListTile(
                                    title: 'Lista de salidas',
                                    icon: const Icon(
                                      Icons.line_style,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listSalidas'),
                                  ),
                                ],
                              ),
                              SubCustomExpansionTile(
                                title: 'Ajustes',
                                icon: Icon(Icons.abc_outlined),
                                children: [
                                  CustomListTile(
                                    title: 'Ajuste +',
                                    icon: Icon(Icons.list_alt_rounded),
                                    onTap: () {},
                                  ),
                                  CustomListTile(
                                    title: 'Ajuste -',
                                    icon: Icon(Icons.list_alt_rounded),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),

                          //REportes
                          const CustomExpansionTile(
                            title: 'Reportes',
                            icon: Icon(
                              Icons.paste_rounded,
                            ),
                            children: [],
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
