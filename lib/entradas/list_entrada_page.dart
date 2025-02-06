import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/entradas/details_entrada_page.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListEntradaPage extends StatefulWidget {
  final String? userRole;
  const ListEntradaPage({super.key, required this.userRole});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final AuthService _authService = AuthService();
  final EntradasController _entradasController = EntradasController();
  final ProductosController _productosController = ProductosController();
  final UsersController _usersController = UsersController();
  final AlmacenesController _almacenesController = AlmacenesController();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  List<Entradas> _allEntradas = [];
  List<Entradas> _filteredEntradas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};
  Map<int, Almacenes> _almacenCache = {};

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
      final productos = await _productosController.listProductos();
      final almacenes = await _almacenesController.listAlmacenes();
      final users = await _usersController.listUsers();

      setState(() {
        _allEntradas = entradas;
        _filteredEntradas = entradas;

        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};
        _almacenCache = {for (var alm in almacenes) alm.id_Almacen!: alm};

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

        //Validar folio
        final matchesFolio = folio.contains(query);

        //Validar referencia
        final matchesReferencia = referencia.contains(query);

        final matchesText = query.isEmpty || matchesFolio || matchesReferencia;

        //Validar rango de fechas
        final matchesDate = fecha != null &&
            (_startDate == null || !fecha.isBefore(_startDate!)) &&
            (_endDate == null || !fecha.isAfter(_endDate!));

        return matchesText && matchesDate;
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
                          labelText: 'Buscar por folio o referencia',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
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

    return ListView.builder(
      itemCount: _filteredEntradas.length,
      itemBuilder: (context, index) {
        final entrada = _filteredEntradas[index];
        final producto = _productosCache[entrada.idProducto];
        final user = _usersCache[entrada.id_User];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          color: entrada.entrada_Estado == false
              ? Colors.red.shade300
              : const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              showEntradaDetailsDialog(
                context,
                entrada,
                _productosCache,
                _almacenCache,
                _usersCache,
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
                        producto != null
                            ? Text(
                                '${producto.prodDescripcion}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('Producto no encontrado'),
                        const SizedBox(height: 10),
                        user != null
                            ? Text('Realizado por: ${user.user_Name}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ))
                            : const Text(
                                'Realizado por: Usuario no encontrado'),
                        const SizedBox(height: 10),
                        Text(
                          'Unidades: ${entrada.entrada_Unidades ?? 'No disponible'}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Costo: \$${entrada.entrada_Costo}',
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
                        'Folio: ${entrada.entrada_CodFolio ?? "Sin folio"}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        entrada.entrada_Fecha ?? 'Sin Fecha',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.userRole == "Admin" &&
                          entrada.entrada_Estado == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 30),
                            IconButton(
                              icon: Icon(
                                size: 40,
                                Icons.delete_forever,
                                color: Colors.red.shade900,
                              ),
                              onPressed: () => _confirmarCancelacion(entrada),
                            ),
                          ],
                        ),
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

  void _confirmarCancelacion(Entradas entrada) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: Text(
            '¿Estás seguro de que deseas cancelar esta entrada? \nFolio entrada: ${entrada.entrada_CodFolio} \nIdEntrada: ${entrada.id_Entradas}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(
                color: Colors.blue.shade900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarMotivoDialog(entrada);
            },
            child: Text(
              'Sí, cancelar',
              style: TextStyle(
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMotivoDialog(Entradas entrada) {
    // Limpiar el controlador de motivo
    _motivoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo de Cancelación', textAlign: TextAlign.center),
        content: CustomTextFielTexto(
          labelText: 'Motivo',
          controller: _motivoController,
          validator: (motivo) {
            if (motivo == null || motivo.isEmpty) {
              return 'Motivo obligaorio';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.blue.shade900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelarEntrada(entrada);
            },
            child: Text(
              'Registrar Cancelación',
              style: TextStyle(
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarEntrada(Entradas entrada) async {
    final CanceladoController canceladoController = CanceladoController();

    if (_motivoController.text.isEmpty) {
      showAdvertence(context, 'Motivo obligatorio');
      return;
    }

    setState(() {
      _isLoadingCancel = true;
    });

    //Add registro a cancelado
    final Cancelados cancelacion = Cancelados(
      idCancelacion: 0,
      cancelMotivo: _motivoController.text,
      cancelFecha: _fecha,
      id_Entrada: entrada.id_Entradas,
      id_User: int.tryParse(idUserDelete!),
    );

    final bool success = await canceladoController.addCancelacion(cancelacion);

    if (success) {
      //Estado entrada
      final Entradas entradaEdit = entrada.copyWith(
        entrada_Estado: false,
      );

      //Retar unidades
      final Productos? producto = _productosCache[entrada.idProducto];
      if (producto != null) {
        final double nuevaExistencia =
            (producto.prodExistencia ?? 0) - (entrada.entrada_Unidades ?? 0);
        final Productos productoEdit = producto.copyWith(
          prodExistencia: nuevaExistencia,
        );

        //Actualizar entrada y producto
        final bool entradaUpdated =
            await _entradasController.editEntrada(entradaEdit);
        final bool productoUpdated =
            await _productosController.editProducto(productoEdit);

        if (entradaUpdated && productoUpdated) {
          showOk(context, 'Entrada cancelada y existencia actualizada.');
          await _loadData();
        } else {
          showError(context, 'Error al cancelar entrada o actualizar produco.');
        }
      } else {
        showError(context, 'Error al registrar la cancelación.');
      }
    }
    setState(() {
      _isLoadingCancel = false;
    });
  }
}
