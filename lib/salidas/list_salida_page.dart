import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/salidas/details_salida_page.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ListSalidaPage extends StatefulWidget {
  final String? userRole;
  const ListSalidaPage({super.key, this.userRole});

  @override
  State<ListSalidaPage> createState() => _ListSalidaPageState();
}

class _ListSalidaPageState extends State<ListSalidaPage> {
  final AuthService _authService = AuthService();
  final SalidasController _salidasController = SalidasController();
  final ProductosController _productosController = ProductosController();
  final JuntasController _juntasController = JuntasController();
  final AlmacenesController _almacenesController = AlmacenesController();
  final UsersController _usersController = UsersController();
  final PadronController _padronController = PadronController();

  final TextEditingController _searchController = TextEditingController();
  List<Salidas> _allSalidas = [];
  List<Salidas> _filteredSalidas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};
  // ignore: unused_field
  Map<int, Juntas> _juntasCache = {};
  // ignore: unused_field
  Map<int, Almacenes> _almacenCache = {};
  // ignore: unused_field
  Map<int, Users> _userAsignadoCache = {};

  List<Juntas> _juntas = [];
  List<Almacenes> _almacenes = [];
  List<Padron> _padrones = [];
  List<Users> _userAsignado = [];

  String? _selectedJunta;
  String? _selectedAlmacen;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSalidas);
  }

  Future<void> _loadData() async {
    try {
      // Cargar salidas
      final salidas = await _salidasController.listSalidas();
      final productos = await _productosController.listProductos();
      final users = await _usersController.listUsers();
      final juntas = await _juntasController.listJuntas();
      final almacen = await _almacenesController.listAlmacenes();
      final padrones = await _padronController.listPadron();
      final userAsignado = await _usersController.listUsers();

      setState(() {
        _allSalidas = salidas;
        _filteredSalidas = salidas;

        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};
        _userAsignadoCache = {for (var usAs in users) usAs.id_User!: usAs};
        _juntasCache = {for (var jn in juntas) jn.id_Junta!: jn};
        _almacenCache = {for (var alm in almacen) alm.id_Almacen!: alm};

        _juntas = juntas;
        _almacenes = almacen;
        _padrones = padrones;
        _userAsignado = userAsignado;

        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSalidas() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredSalidas = _allSalidas.where((salida) {
        final folio = (salida.salida_CodFolio ?? '').toString().toLowerCase();
        final referencia =
            (salida.salida_Referencia ?? '').toString().toLowerCase();
        final fechaString = salida.salida_Fecha;
        final fecha = fechaString != null ? parseDate(fechaString) : null;

        final matchesFolio = folio.contains(query);

        final matchesReferencia = referencia.contains(query);

        final matchesText = query.isEmpty || matchesFolio || matchesReferencia;

        final matchesDate = fecha != null &&
            (_startDate == null || !fecha.isBefore(_startDate!)) &&
            (_endDate == null || !fecha.isAfter(_endDate!));

        final matchesJunta = _selectedJunta == null ||
            salida.id_Junta.toString() == _selectedJunta;

        final matchesAlmacen = _selectedAlmacen == null ||
            salida.id_Almacen.toString() == _selectedAlmacen;

        return matchesText && matchesDate && matchesJunta && matchesAlmacen;
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
      _filterSalidas();
    }
  }

  void _clearJuntaFilter() {
    setState(() {
      _selectedJunta = null;
      _filterSalidas();
    });
  }

  void _clearAlmacenFilter() {
    setState(() {
      _selectedAlmacen = null;
      _filterSalidas();
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
                      //Folio
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por folio o referencia',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 10),

                      //Fecha
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDateRange(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 201, 230, 242),
                          ),
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade900,
                          ),
                          label: Text(
                            _startDate != null && _endDate != null
                                ? 'Desde: ${DateFormat('yyyy-MM-dd').format(_startDate!)} Hasta: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                                : 'Seleccionar rango de fechas',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _filterSalidas();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      //Juntas
                      Expanded(
                        child: CustomListaDesplegableTipo<Juntas>(
                          value: _selectedJunta != null
                              ? _juntas.firstWhere((junta) =>
                                  junta.id_Junta.toString() == _selectedJunta)
                              : null,
                          labelText: 'Seleccionar Junta',
                          items: _juntas,
                          onChanged: (Juntas? newValue) {
                            setState(() {
                              _selectedJunta = newValue?.id_Junta.toString();
                            });
                            _filterSalidas();
                          },
                          itemLabelBuilder: (junta) => junta.junta_Name ?? '',
                        ),
                      ),
                      if (_selectedJunta != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearJuntaFilter,
                        ),
                      const SizedBox(width: 10),

                      //Almacenes
                      Expanded(
                        child: CustomListaDesplegableTipo<Almacenes>(
                          value: _selectedAlmacen != null
                              ? _almacenes.firstWhere((almacen) =>
                                  almacen.id_Almacen.toString() ==
                                  _selectedAlmacen)
                              : null,
                          labelText: 'Seleccionar Almacen',
                          items: _almacenes,
                          onChanged: (Almacenes? newValue) {
                            setState(() {
                              _selectedAlmacen =
                                  newValue?.id_Almacen.toString();
                            });
                            _filterSalidas();
                          },
                          itemLabelBuilder: (entidad) =>
                              entidad.almacen_Nombre ?? '',
                        ),
                      ),
                      if (_selectedAlmacen != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearAlmacenFilter,
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
    if (_filteredSalidas.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No hay salidas que coincidan con el folio'
              : (_startDate != null || _endDate != null)
                  ? 'No hay salidas que coincidan con el rango de fechas'
                  : 'No hay salidas disponibles',
        ),
      );
    }

    Map<String, List<Salidas>> gorupSalidas = {};
    for (var salida in _filteredSalidas) {
      gorupSalidas.putIfAbsent(
        salida.salida_CodFolio!,
        () => [],
      );
      gorupSalidas[salida.salida_CodFolio]!.add(salida);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: gorupSalidas.keys.length,
      itemBuilder: (context, index) {
        if (index >= gorupSalidas.keys.length) {
          return const SizedBox.shrink();
        }
        String codFolio = gorupSalidas.keys.elementAt(index);
        List<Salidas> salidas = gorupSalidas[codFolio]!;

        double totalUnidades =
            salidas.fold(0, (sum, item) => sum + (item.salida_Unidades ?? 0));

        double totalCosto =
            salidas.fold(0, (sum, item) => sum + (item.salida_Costo ?? 0));

        final salidaPrincipal = salidas.first;
        final salida = salidaPrincipal;

        // ignore: unused_local_variable
        final producto = _productosCache[salida.idProducto];
        final user = _usersCache[salida.id_User];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              final almacen = _almacenes.firstWhere(
                (alm) => alm.id_Almacen == salida.id_Almacen,
                orElse: () =>
                    Almacenes(id_Almacen: 0, almacen_Nombre: 'Desconocido'),
              );

              final junta = _juntas.firstWhere(
                (jnt) => jnt.id_Junta == salida.id_Junta,
                orElse: () => Juntas(id_Junta: 0, junta_Name: 'Deconocido'),
              );

              final padron = _padrones.firstWhere(
                (pdr) => pdr.idPadron == salida.idPadron,
                orElse: () => Padron(idPadron: 0, padronNombre: 'Desconocido'),
              );

              final userAsig = _userAsignado.firstWhere(
                (uas) => uas.id_User == salida.id_User_Asignado,
                orElse: () => Users(id_User: 0, user_Name: 'Desconocido'),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsSalidaPage(
                    salidas: salidas,
                    almacen: almacen,
                    junta: junta,
                    padron: padron,
                    user: user!.user_Name!,
                    userAsignado: userAsig,
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
                          'Folio $codFolio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        user != null
                            ? Text('Realizado por: ${user.user_Name}',
                                style: const TextStyle(fontSize: 15))
                            : const Text('Usuario no encontrado'),
                        const SizedBox(height: 10),
                        Text(
                          'Total unidades: $totalUnidades',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Costo: \$${totalCosto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Referencia: ${salida.salida_Referencia ?? 'No disponible'}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        salida.salida_Fecha ?? 'Sin Fecha',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.userRole == "Admin" &&
                          salida.salida_Estado == true)
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
                              onPressed: () => _confirmarCancelacion(salida),
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

  String? idUserDelete;

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserDelete = decodeToken?['Id_User'] ?? '0';
  }

  void _confirmarCancelacion(Salidas salida) {
    // Verificar primero si el ID es válido
    if (salida.id_Salida == null || salida.id_Salida == 0) {
      showError(
          context, 'No se puede cancelar: La salida no tiene un ID válido');
      return;
    }

    // Luego obtener el ID del usuario
    _getUserId().then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Cancelación'),
          content: Text(
              '¿Estás seguro de que deseas cancelar esta salida? \nFolio salida: ${salida.salida_CodFolio} \nIdSalida: ${salida.id_Salida}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'No',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarMotivoDialog(salida);
              },
              child: Text(
                'Sí, cancelar',
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          ],
        ),
      );
    });
  }

  final TextEditingController _motivoController = TextEditingController();
  void _mostrarMotivoDialog(Salidas salida) {
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
              return 'Motivo obligatorio.';
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelarSalida(salida);
            },
            child: Text(
              'Registrar Cancelación',
              style: TextStyle(color: Colors.red.shade900),
            ),
          )
        ],
      ),
    );
  }

  bool _isLoadingCancel = false;
  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<void> _cancelarSalida(Salidas salida) async {
    // Verificación adicional
    if (salida.id_Salida == null || salida.id_Salida == 0) {
      showError(context, 'Error: La salida no tiene un ID válido');
      return;
    }

    if (idUserDelete == null) {
      await _getUserId();
    }

    final CanceladoSalidaController canceladoSalidaController =
        CanceladoSalidaController();

    if (_motivoController.text.isEmpty) {
      showAdvertence(context, 'Motivo obligatorio');
      return;
    }

    setState(() => _isLoadingCancel = true);

    try {
      // Buscar salidas válidas (con ID != 0)
      final List<Salidas> salidasACancelar = _allSalidas
          .where((element) =>
              element.salida_CodFolio == salida.salida_CodFolio &&
              (element.id_Salida ?? 0) != 0)
          .toList();

      if (salidasACancelar.isEmpty) {
        throw Exception('No se encontraron salidas válidas para cancelar');
      }

      final Map<int, double> productosASumar = {};

      for (var salidaItem in salidasACancelar) {
        final CanceladoSalidas cancelacionSalida = CanceladoSalidas(
          idCanceladoSalida: 0,
          cancelSalidaMotivo: _motivoController.text,
          cancelSalidaFecha: _fecha,
          id_Salida: salidaItem.id_Salida!,
          id_User: int.tryParse(idUserDelete ?? '0'),
        );

        final bool success =
            await canceladoSalidaController.addCancelSalida(cancelacionSalida);
        if (!success) throw Exception('Error al registrar cancelación');

        final Salidas salidaEdit = salidaItem.copyWith(salida_Estado: false);
        final bool salidaUpdated =
            await _salidasController.editSalida(salidaEdit);
        if (!salidaUpdated) throw Exception('Error al actualizar salida');

        if (salidaItem.idProducto != null) {
          productosASumar.update(salidaItem.idProducto!,
              (value) => value + (salidaItem.salida_Unidades ?? 0),
              ifAbsent: () => salidaItem.salida_Unidades ?? 0);
        }
      }

      // Actualizar productos
      for (var entry in productosASumar.entries) {
        final producto = _productosCache[entry.key];
        if (producto != null) {
          final nuevaExistencia = (producto.prodExistencia ?? 0) + entry.value;
          await _productosController
              .editProducto(producto.copyWith(prodExistencia: nuevaExistencia));
        }
      }

      showOk(context, 'Salidas canceladas correctamente');
      await _loadData();
    } catch (e) {
      showError(context, 'Error durante la cancelación: ${e.toString()}');
    } finally {
      setState(() => _isLoadingCancel = false);
    }
  }
}
