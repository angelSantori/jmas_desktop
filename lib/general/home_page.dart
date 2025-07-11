import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:jmas_desktop/ajustes_minus/add_ajuste_menos_page.dart';
import 'package:jmas_desktop/ajustes_plus/add_ajuste_mas_page.dart';
import 'package:jmas_desktop/ajustes_plus/list_ajuste_mas_page.dart';
import 'package:jmas_desktop/almacenes/add_almacen_page.dart';
import 'package:jmas_desktop/almacenes/list_almacenes_page.dart';
import 'package:jmas_desktop/calles/add_calles_page.dart';
import 'package:jmas_desktop/calles/list_calles_page.dart';
import 'package:jmas_desktop/cancelaciones/list_cancelados_page.dart';
import 'package:jmas_desktop/ccontables/ccontables_generador_page.dart';
import 'package:jmas_desktop/ccontables/list_ccontables_page.dart';
import 'package:jmas_desktop/colonias/add_colonias_page.dart';
import 'package:jmas_desktop/colonias/list_colonias_page.dart';
import 'package:jmas_desktop/conteoinicial/list_conteoinicial_page.dart';
import 'package:jmas_desktop/entradas/add_entrada_page.dart';
import 'package:jmas_desktop/entradas/list_entrada_page.dart';
import 'package:jmas_desktop/general/login_page.dart';
import 'package:jmas_desktop/herramientas/add_herramienta_page.dart';
import 'package:jmas_desktop/herramientas/list_herramientas_page.dart';
import 'package:jmas_desktop/htaPrest/add_htaprest_page.dart';
import 'package:jmas_desktop/htaPrest/list_htaprest_page.dart';
import 'package:jmas_desktop/juntas/add_junta_page.dart';
import 'package:jmas_desktop/juntas/list_juntas_page.dart';
import 'package:jmas_desktop/ordenCompras/add_orden_compra_page.dart';
import 'package:jmas_desktop/ordenCompras/list_orden_compra_page.dart';
import 'package:jmas_desktop/padron/list_padron_page.dart';
import 'package:jmas_desktop/pdfs/pdf_list_page.dart';
import 'package:jmas_desktop/productos/add_producto_page.dart';
import 'package:jmas_desktop/productos/list_producto_page.dart';
import 'package:jmas_desktop/proveedores/add_proveedor_page.dart';
import 'package:jmas_desktop/proveedores/list_proveedor_page.dart';
import 'package:jmas_desktop/roles/add_role_page.dart';
import 'package:jmas_desktop/roles/admin_role_page.dart';
import 'package:jmas_desktop/salidas/add_salida_page.dart';
import 'package:jmas_desktop/salidas/list_cancelacioens_salida_page.dart';
import 'package:jmas_desktop/salidas/list_salida_page.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/universal/consulta_universal_page.dart';
import 'package:jmas_desktop/users/add_user_page.dart';
import 'package:jmas_desktop/users/list_user_page.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';

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
  String? idUser;

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
      idUser = decodeToken?['Id_User'];
    });
  }

  Widget _currentPage = const Center(
    child: Text('Welcome to home Page!'),
  );

  // Método para obtener el Map de rutas
  Map<String, Widget Function()> _getRoutes() {
    return {
      //Productos
      'addProducto': () => const AddProductoPage(),
      'listProducto': () => const ListProductoPage(),
      'listConteo': () => const ListConteoinicialPage(),

      //Ajuste Mas
      'addAjusteMas': () =>
          AddAjusteMasPage(idUser: idUser, userName: userName),
      'listAjusteMas': () => ListAjusteMasPage(userRole: userRole),

      //Users
      'addUser': () => const AddUserPage(),
      'listUser': () => const ListUserPage(),
      'adminRole': () => const AdminRolePage(),
      'addRole': () => const AddRolePage(),

      //Entradas
      'addEntrada': () => AddEntradaPage(userName: userName, idUser: idUser),
      'listEntradas': () => ListEntradaPage(userRole: userRole),
      'listCancelados': () => const ListCanceladosPage(),

      //Proveedores
      'listProveedores': () => const ListProveedorPage(),
      'addProveedores': () => const AddProveedorPage(),

      //Salidas
      'addSalida': () => AddSalidaPage(userName: userName, idUser: idUser),
      'listSalidas': () => ListSalidaPage(userRole: userRole),
      'listCanceladosSalida': () => const ListCancelacioensSalidaPage(),

      //Alamcen
      'listAlmacenes': () => const ListAlmacenesPage(),
      'addAlmacenes': () => const AddAlmacenPage(),

      //Juntas
      'listJuntas': () => const ListJuntasPage(),
      'addJunta': () => const AddJuntaPage(),

      //Colonias
      'listColonias': () => const ListColoniasPage(),
      'addColonia': () => const AddColoniasPage(),

      //Calles
      'listCalles': () => const ListCallesPage(),
      'addCalle': () => const AddCallesPage(),

      //Herramientas
      'listHerramientas': () => const ListHerramientasPage(),
      'addHerramienta': () => const AddHerramientaPage(),

      //HtaPrestamos
      'listHtaPrest': () => const ListHtaprestPage(),
      'addHtaPrest': () => AddHtaprestPage(idUser: idUser, userName: userName),

      //Consulta universal
      'ConsultaU': () => const ConsultaUniversalPage(),
      'listPDF': () => const PdfListPage(),

      //Orden de Compra
      'addOrdenCompra': () =>
          AddOrdenCompraPage(idUser: idUser, userName: userName),
      'listOrdenCompra': () => ListOrdenCompraPage(userRole: userRole),

      //X
      'home': () => const Center(child: Text('Welcome to home Page!')),
      'listPadron': () => const ListPadronPage(),

      //Cuentas contables
      'listCC': () => const ListCcontablesPage(),
      'generadorCC': () => const CcontablesGeneradorPage(),

      //'mapa': () => const MapaLecturasPage(),
      // 'addAjusteMenos': () => const AddAjusteMenosPage(),
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
              onPressed: () async {
                //1. Cerrar el diálogo
                Navigator.of(context).pop();

                //2. Limpiar datos de autenticación
                await _authService.clearAuthData();
                await _authService.deleteToken();

                //3. Navegar al login limpiando toda la pila
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
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
                                    title: 'Conteo Inicial',
                                    icon: const Icon(
                                      Icons.abc_sharp,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listConteo'),
                                  ),
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Producto',
                                      icon: SvgPicture.asset(
                                        'assets/icons/addprod.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addProducto'),
                                    ),
                                  ),
                                ],
                              ),

                              //Herramientas
                              SubCustomExpansionTile(
                                title: 'Herraminetas',
                                icon: SvgPicture.asset(
                                  'assets/icons/worktools.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Herramientas',
                                    icon: SvgPicture.asset(
                                      'assets/icons/worktools.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('listHerramientas'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Herramienta',
                                      icon: SvgPicture.asset(
                                        'assets/icons/worktools.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addHerramienta'),
                                    ),
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Proveedor',
                                      icon: const Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addProveedores'),
                                    ),
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar almacen',
                                      icon: const Icon(
                                        Icons.add_business_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addAlmacenes'),
                                    ),
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Junta',
                                      icon: const Icon(
                                        Icons.add_home_work_sharp,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addJunta'),
                                    ),
                                  ),
                                ],
                              ),

                              //Colonias
                              SubCustomExpansionTile(
                                title: 'Colonias',
                                icon: const Icon(
                                  Icons.map_rounded,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Colonias',
                                    icon: const Icon(
                                      Icons.map_rounded,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listColonias'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Colonia',
                                      icon: const Icon(
                                        Icons.public_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addColonia'),
                                    ),
                                  ),
                                ],
                              ),

                              //Calles
                              SubCustomExpansionTile(
                                title: 'Calles',
                                icon: const Icon(
                                  Icons.stream,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Calles',
                                    icon: const Icon(
                                      Icons.strikethrough_s_sharp,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listCalles'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Calle',
                                      icon: const Icon(
                                        Icons.stacked_line_chart_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addCalle'),
                                    ),
                                  ),
                                ],
                              ),

                              //Padrones
                              SubCustomExpansionTile(
                                title: 'Padron',
                                icon: SvgPicture.asset(
                                  'assets/icons/social.svg',
                                  color: Colors.white,
                                  width: 20,
                                  height: 20,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Padron',
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar entrada',
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addEntrada'),
                                    ),
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
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar salida',
                                      icon: const Icon(
                                        Icons.add_box_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addSalida'),
                                    ),
                                  ),
                                  CustomListTile(
                                    title: 'Lista de salidas',
                                    icon: const Icon(
                                      Icons.line_style,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listSalidas'),
                                  ),
                                  CustomListTile(
                                    title: 'Cancelados',
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('listCanceladosSalida'),
                                  ),
                                ],
                              ),

                              //HtaPrestamo
                              SubCustomExpansionTile(
                                title: 'Prestamos',
                                icon: SvgPicture.asset(
                                  'assets/icons/worktools.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Prestamos',
                                    icon: SvgPicture.asset(
                                      'assets/icons/worktools.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listHtaPrest'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Add Prestamos',
                                      icon: SvgPicture.asset(
                                        'assets/icons/worktools.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addHtaPrest'),
                                    ),
                                  ),
                                ],
                              ),

                              //Orden de compra
                              SubCustomExpansionTile(
                                  title: 'Compras',
                                  icon: const Icon(Icons.bedroom_baby_rounded),
                                  children: [
                                    CustomListTile(
                                      title: 'Orden Compra',
                                      icon: const Icon(
                                        Icons.stroller_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addOrdenCompra'),
                                    ),
                                    CustomListTile(
                                      title: 'Lista Compras',
                                      icon: const Icon(
                                        Icons.stroller,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo(
                                        'listOrdenCompra',
                                      ),
                                    )
                                  ]),

                              PermissionWidget(
                                permission: 'add',
                                child: SubCustomExpansionTile(
                                  title: 'Ajustes',
                                  icon: const Icon(Icons.abc_outlined),
                                  children: [
                                    CustomListTile(
                                      title: 'Ajuste +',
                                      icon: const Icon(
                                        Icons.list_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addAjusteMas'),
                                    ),
                                    CustomListTile(
                                      title: 'Lista Ajuste +',
                                      icon: const Icon(
                                        Icons.list_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('listAjusteMas'),
                                    ),
                                    // CustomListTile(
                                    //   title: 'Ajuste -',
                                    //   icon: Icon(Icons.list_alt_rounded),
                                    //   onTap: () {},
                                    // ),
                                  ],
                                ),
                              ),

                              CustomListTile(
                                title: 'Consulta Universal',
                                icon: const Icon(
                                  Icons.webhook_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('ConsultaU'),
                              ),
                            ],
                          ),

                          //REportes
                          CustomExpansionTile(
                            title: 'Reportes',
                            icon: const Icon(
                              Icons.paste_rounded,
                            ),
                            children: [
                              CustomListTile(
                                title: 'CContable',
                                icon: const Icon(
                                  Icons.list,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listCC'),
                              ),
                              CustomListTile(
                                title: 'Generador',
                                icon: const Icon(
                                  Icons.add_chart,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('generadorCC'),
                              ),
                              CustomListTile(
                                title: 'PDF',
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listPDF'),
                              )
                            ],
                          ),

                          PermissionWidget(
                            permission: 'manage_users',
                            child: CustomExpansionTile(
                              title: 'Configuración',
                              icon: const Icon(Icons.settings),
                              children: [
                                //Usuarios
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
                                    PermissionWidget(
                                      permission: 'manage_roles',
                                      child: CustomListTile(
                                        title: 'Admin Roles',
                                        icon: const Icon(
                                          Icons.rocket_launch_sharp,
                                          color: Colors.white,
                                        ),
                                        onTap: () => _navigateTo('adminRole'),
                                      ),
                                    ),
                                    PermissionWidget(
                                      permission: 'manage_roles',
                                      child: CustomListTile(
                                        title: 'Agregar Rol',
                                        icon: const Icon(
                                          Icons.plus_one,
                                          color: Colors.white,
                                        ),
                                        onTap: () => _navigateTo('addRole'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
