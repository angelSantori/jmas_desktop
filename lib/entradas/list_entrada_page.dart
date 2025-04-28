import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
//import 'package:jmas_desktop/contollers/cancelado_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
//import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/entradas/details_entrada_page.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
//import 'package:jmas_desktop/widgets/mensajes.dart';

class ListEntradaPage extends StatefulWidget {
  final String? userRole;
  const ListEntradaPage({super.key, required this.userRole});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final AuthService _authService = AuthService();
  final EntradasController _entradasController = EntradasController();
  //final ProductosController _productosController = ProductosController();
  final UsersController _usersController = UsersController();
  final AlmacenesController _almacenesController = AlmacenesController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final JuntasController _juntasController = JuntasController();

  final TextEditingController _searchController = TextEditingController();
  //final TextEditingController _motivoController = TextEditingController();
  //final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  List<Entradas> _allEntradas = [];
  List<Entradas> _filteredEntradas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  //Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};
  // ignore: unused_field
  Map<int, Almacenes> _almacenCache = {};

  List<Almacenes> _almacen = [];
  List<Proveedores> _proveedor = [];
  List<Juntas> _junta = [];

  String? _selectedAlmacen;
  String? _selectedProveedor;

  bool _isLoading = true;
  bool _isLoadingCancel = false;

  String? idUserDelete;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserId();
    _searchController.addListener(_filterEntradas);
  }

  Future<void> _loadData() async {
    try {
      final entradas = await _entradasController.listEntradas();
      //final productos = await _productosController.listProductos();
      final almacenes = await _almacenesController.listAlmacenes();
      final proveedores = await _proveedoresController.listProveedores();
      final juntas = await _juntasController.listJuntas();
      final users = await _usersController.listUsers();

      setState(() {
        _allEntradas = entradas;
        _filteredEntradas = entradas;

        //_productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};
        _almacenCache = {for (var alm in almacenes) alm.id_Almacen!: alm};

        _almacen = almacenes;
        _proveedor = proveedores;
        _junta = juntas;

        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterEntradas() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredEntradas = _allEntradas.where((entrada) {
        final folio = (entrada.entrada_CodFolio ?? '').toString().toLowerCase();
        final referencia =
            (entrada.entrada_Referencia ?? '').toString().toLowerCase();
        final fechaString = entrada.entrada_Fecha;

        //Parsear la fecha del string
        final fecha = fechaString != null ? parseDate(fechaString) : null;

        if (fecha == null && (_startDate != null || _endDate != null)) {
          return false;
        }

        //Validar folio
        final matchesFolio = folio.contains(query);

        //Validar referencia
        final matchesReferencia = referencia.contains(query);

        final matchesText = query.isEmpty || matchesFolio || matchesReferencia;

        //Validar por almacen
        final matchesAlmacen = _selectedAlmacen == null ||
            entrada.id_Almacen.toString() == _selectedAlmacen;

        //Validar por proveedor
        final matchesProveedor = _selectedProveedor == null ||
            entrada.id_Proveedor.toString() == _selectedProveedor;

        //Validar rango de fechas
        final matchesDate = fecha != null &&
            (_startDate == null || !fecha.isBefore(_startDate!)) &&
            (_endDate == null || !fecha.isAfter(_endDate!));

        return matchesText && matchesDate && matchesAlmacen && matchesProveedor;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterEntradas();
    }
  }

  void _clearAlamacenFilter() {
    setState(() {
      _selectedAlmacen = null;
      _filterEntradas();
    });
  }

  void _clearProveedorFilter() {
    setState(() {
      _selectedProveedor = null;
      _filterEntradas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por Folio o Referencia',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.blue.shade900, // Color de la sombra
                                blurRadius: 8, // Difuminado de la sombra
                                offset: const Offset(
                                    0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDateRange(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 201, 230, 242),
                            ),
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            label: Text(
                              _startDate != null && _endDate != null
                                  ? 'Desde: ${DateFormat('yyyy-MM-dd').format(_startDate!)} Hasta: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                                  : 'Seleccionar rango de fechas',
                              style: const TextStyle(
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _filterEntradas();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo<Almacenes>(
                          value: _selectedAlmacen != null
                              ? _almacen.firstWhere((almacen) =>
                                  almacen.id_Almacen.toString() ==
                                  _selectedAlmacen)
                              : null,
                          labelText: 'Filtrar por Almacen',
                          items: _almacen,
                          onChanged: (Almacenes? newAlmacen) {
                            setState(() {
                              _selectedAlmacen =
                                  newAlmacen?.id_Almacen.toString();
                            });
                            _filterEntradas();
                          },
                          itemLabelBuilder: (almcen) =>
                              almcen.almacen_Nombre ?? 'N/A',
                        ),
                      ),
                      if (_selectedAlmacen != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearAlamacenFilter,
                        ),
                      const SizedBox(width: 30),

                      //Proveedores
                      Expanded(
                        child: CustomListaDesplegableTipo<Proveedores>(
                          value: _selectedProveedor != null
                              ? _proveedor.firstWhere((proveedor) =>
                                  proveedor.id_Proveedor.toString() ==
                                  _selectedProveedor)
                              : null,
                          labelText: 'Filtrar por Proveedor',
                          items: _proveedor,
                          onChanged: (Proveedores? newProveedor) {
                            setState(() {
                              _selectedProveedor =
                                  newProveedor?.id_Proveedor.toString();
                            });
                            _filterEntradas();
                          },
                          itemLabelBuilder: (proveedor) =>
                              proveedor.proveedor_Name ?? 'N/A',
                        ),
                      ),
                      if (_selectedProveedor != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearProveedorFilter,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: _isLoadingCancel
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Colors.blue.shade900),
                        )
                      : _buildListView(),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildListView() {
    if (_filteredEntradas.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No hay entradas que coincidan con el folio o referencia'
              : (_startDate != null || _endDate != null)
                  ? 'No hay entradas que coincidan con el rango de fechas'
                  : 'No hay entradas disponibles',
        ),
      );
    }

    //Agrupar entradas por CodFolio
    Map<String, List<Entradas>> groupEntradas = {};
    for (var entrada in _filteredEntradas) {
      groupEntradas.putIfAbsent(
        entrada.entrada_CodFolio!,
        () => [],
      );
      groupEntradas[entrada.entrada_CodFolio]!.add(entrada);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: groupEntradas.keys.length,
      itemBuilder: (context, index) {
        if (index >= groupEntradas.keys.length) {
          return const SizedBox
              .shrink(); // Evita acceder a un índice fuera de rango
        }
        String codFolio = groupEntradas.keys.elementAt(index);
        List<Entradas> entradas = groupEntradas[codFolio]!;

        //Calcular total de unidades y cisti
        double totalUnidades =
            entradas.fold(0, (sum, item) => sum + (item.entrada_Unidades ?? 0));
        double totalCosto =
            entradas.fold(0, (sum, item) => sum + (item.entrada_Costo ?? 0));

        //Tomar la primera entrada para extrar datos generales
        final entradaPrincipal = entradas.first;

        final entrada = entradaPrincipal;
        //final producto = _productosCache[entrada.idProducto];
        final user = _usersCache[entrada.id_User];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: entradaPrincipal.entrada_Estado == false
              ? const Color.fromARGB(255, 201, 230, 242)
              : const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              final proveedor = _proveedor.firstWhere(
                (prov) => prov.id_Proveedor == entrada.id_Proveedor,
                orElse: () =>
                    Proveedores(id_Proveedor: 0, proveedor_Name: "Desconocido"),
              );

              final almacen = _almacen.firstWhere(
                (alm) => alm.id_Almacen == entrada.id_Almacen,
                orElse: () =>
                    Almacenes(id_Almacen: 0, almacen_Nombre: 'Desconocido'),
              );

              final junta = _junta.firstWhere(
                (jnt) => jnt.id_Junta == entrada.id_Junta,
                orElse: () => Juntas(id_Junta: 0, junta_Name: 'Desconocido'),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsEntradaPage(
                    entradas: entradas,
                    proveedor: proveedor,
                    almacen: almacen,
                    junta: junta,
                    user: user!.user_Name!,
                    userRole: widget.userRole!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Folio: $codFolio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        user != null
                            ? Text(
                                'Realizado por: ${user.user_Name}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : const Text(
                                'Realizado por: Usuario no encontrado'),
                        const SizedBox(height: 10),
                        Text(
                          'Total Unidades: $totalUnidades',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total Costo: \$${totalCosto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Referencia: ${entrada.entrada_Referencia}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        entrada.entrada_Fecha ?? 'Sin Fecha',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // if (widget.userRole == "Admin" &&
                      //     entrada.entrada_Estado == true)
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const SizedBox(height: 30),
                      //       IconButton(
                      //         icon: Icon(
                      //           size: 40,
                      //           Icons.delete_forever,
                      //           color: Colors.red.shade900,
                      //         ),
                      //         onPressed: () => _confirmarCancelacion(entrada),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserDelete = decodeToken?['Id_User'] ?? '0';
  }

  // void _confirmarCancelacion(Entradas entrada) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirmar Cancelación'),
  //       content: Text(
  //           '¿Estás seguro de que deseas cancelar esta entrada? \nFolio entrada: ${entrada.entrada_CodFolio} \nIdEntrada: ${entrada.id_Entradas}'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'No',
  //             style: TextStyle(
  //               color: Colors.blue.shade900,
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _mostrarMotivoDialog(entrada);
  //           },
  //           child: Text(
  //             'Sí, cancelar',
  //             style: TextStyle(
  //               color: Colors.red.shade900,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _mostrarMotivoDialog(Entradas entrada) {
  //   // Limpiar el controlador de motivo
  //   _motivoController.clear();

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Motivo de Cancelación', textAlign: TextAlign.center),
  //       content: CustomTextFielTexto(
  //         labelText: 'Motivo',
  //         controller: _motivoController,
  //         validator: (motivo) {
  //           if (motivo == null || motivo.isEmpty) {
  //             return 'Motivo obligaorio';
  //           }
  //           return null;
  //         },
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancelar',
  //             style: TextStyle(
  //               color: Colors.blue.shade900,
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _cancelarEntrada(entrada);
  //           },
  //           child: Text(
  //             'Registrar Cancelación',
  //             style: TextStyle(
  //               color: Colors.red.shade900,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _cancelarEntrada(Entradas entrada) async {
  //   final CanceladoController canceladoController = CanceladoController();

  //   if (_motivoController.text.isEmpty) {
  //     showAdvertence(context, 'Motivo obligatorio');
  //     return;
  //   }

  //   setState(() {
  //     _isLoadingCancel = true;
  //   });

  //   try {
  //     // Obtener todas las entradas con el mismo CodFolio
  //     final List<Entradas> entradasACancelar = _allEntradas
  //         .where((e) => e.entrada_CodFolio == entrada.entrada_CodFolio)
  //         .toList();

  //     // Mapa para agrupar productos y sus cantidades a restar
  //     final Map<int, double> productosARestar = {};

  //     // Primero registrar todas las cancelaciones y preparar productos
  //     for (var entradaItem in entradasACancelar) {
  //       // Registrar cancelación
  //       final Cancelados cancelacion = Cancelados(
  //         idCancelacion: 0,
  //         cancelMotivo: _motivoController.text,
  //         cancelFecha: _fecha,
  //         id_Entrada: entradaItem.id_Entradas,
  //         id_User: int.tryParse(idUserDelete!),
  //       );

  //       final bool success =
  //           await canceladoController.addCancelacion(cancelacion);
  //       if (!success) throw Exception('Error al registrar cancelación');

  //       // Actualizar estado de la entrada
  //       final Entradas entradaEdit =
  //           entradaItem.copyWith(entrada_Estado: false);
  //       final bool entradaUpdated =
  //           await _entradasController.editEntrada(entradaEdit);
  //       if (!entradaUpdated) throw Exception('Error al actualizar entrada');

  //       // Acumular cantidades a restar por producto
  //       final int? productoId = entradaItem.idProducto;
  //       if (productoId != null) {
  //         productosARestar.update(productoId,
  //             (value) => value + (entradaItem.entrada_Unidades ?? 0),
  //             ifAbsent: () => entradaItem.entrada_Unidades ?? 0);
  //       }
  //     }

  //     // Actualizar productos
  //     for (var entry in productosARestar.entries) {
  //       final Productos? producto = _productosCache[entry.key];
  //       if (producto != null) {
  //         final double nuevaExistencia =
  //             (producto.prodExistencia ?? 0) - entry.value;
  //         final Productos productoEdit =
  //             producto.copyWith(prodExistencia: nuevaExistencia);
  //         await _productosController.editProducto(productoEdit);
  //       }
  //     }

  //     showOk(context,
  //         'Todas las entradas del folio ${entrada.entrada_CodFolio} han sido canceladas.');
  //     await _loadData();
  //   } catch (e) {
  //     showError(context, 'Error durante el proceso de cancelación: $e');
  //   } finally {
  //     setState(() {
  //       _isLoadingCancel = false;
  //     });
  //   }
  // }
}
