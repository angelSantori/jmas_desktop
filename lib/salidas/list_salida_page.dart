import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/salidas/details_salida_page.dart';
import 'package:jmas_desktop/salidas/excel/excel_salidas.dart';
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
  //final AuthService _authService = AuthService();
  final SalidasController _salidasController = SalidasController();
  final ProductosController _productosController = ProductosController();
  final JuntasController _juntasController = JuntasController();
  final AlmacenesController _almacenesController = AlmacenesController();
  final UsersController _usersController = UsersController();
  final PadronController _padronController = PadronController();
  final ColoniasController _coloniasController = ColoniasController();
  final CallesController _callesController = CallesController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();

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
  List<OrdenServicio> _ordenesServicios = [];
  List<Colonias> _colonias = [];
  List<Calles> _calles = [];
  List<Users> _userAsignado = [];

  String? _selectedJunta;
  String? _selectedColonia;
  String? _selectedCalle;
  String? _selectedAlmacen;

  bool _isLoading = true;

  DateTime? _selectedMonth;
  // ignore: unused_field
  bool _isGeneratingExcel = false;
  bool _showExportOptions = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSalidas);
  }

  Future<void> _reloadData() async {
    setState(() => _isLoading = true);
    try {
      final salidas = await _salidasController.listSalidas();
      setState(() {
        _allSalidas = salidas;
        _filterSalidas(); // Esto aplicará los filtros actuales a los nuevos datos
      });
    } catch (e) {
      print('Error al recargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
      final ordenesServicios =
          await _ordenServicioController.listOrdenServicio();
      final colonias = await _coloniasController.listColonias();
      final calles = await _callesController.listCalles();
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
        _ordenesServicios = ordenesServicios;
        _colonias = colonias;
        _calles = calles;
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

        // Normalize dates by ignoring time components for comparison
        DateTime? normalizedFecha;
        if (fecha != null) {
          normalizedFecha = DateTime(fecha.year, fecha.month, fecha.day);
        }

        DateTime? normalizedStartDate;
        if (_startDate != null) {
          normalizedStartDate =
              DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        }

        DateTime? normalizedEndDate;
        if (_endDate != null) {
          normalizedEndDate =
              DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        }

        final matchesFolio = folio.contains(query);
        final matchesReferencia = referencia.contains(query);
        final matchesText = query.isEmpty || matchesFolio || matchesReferencia;

        bool matchesDate = true;
        if (normalizedFecha != null) {
          if (normalizedStartDate != null) {
            matchesDate = matchesDate &&
                normalizedFecha.isAfter(
                    normalizedStartDate.subtract(const Duration(days: 1)));
          }
          if (normalizedEndDate != null) {
            matchesDate = matchesDate &&
                normalizedFecha
                    .isBefore(normalizedEndDate.add(const Duration(days: 1)));
          }
        } else if (_startDate != null || _endDate != null) {
          matchesDate = false;
        }
        //Match Junta
        final matchesJunta = _selectedJunta == null ||
            salida.id_Junta.toString() == _selectedJunta;

        //Match Almacen
        final matchesAlmacen = _selectedAlmacen == null ||
            salida.id_Almacen.toString() == _selectedAlmacen;

        //Match Colonia
        final matchesColonia = _selectedColonia == null ||
            salida.idColonia.toString() == _selectedColonia;

        //Match Calle
        final matchesCalle = _selectedCalle == null ||
            salida.idCalle.toString() == _selectedCalle;

        return matchesText &&
            matchesDate &&
            matchesJunta &&
            matchesAlmacen &&
            matchesColonia &&
            matchesCalle;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'), // Fuerza el formato dd/mm/yyyy
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    titleLarge: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
            ),
            child: child!,
          ),
        );
      },
      helpText: 'Seleccionar rango', // Personaliza el texto principal
      cancelText: 'Cancelar', // Personaliza el texto del botón Cancelar
      confirmText: 'Confirmar', // Personaliza el texto del botón Confirmar
      saveText: 'Guardar', // Personaliza el texto del botón Guardar
      fieldStartLabelText:
          'Fecha inicial', // Personaliza la etiqueta de fecha inicial
      fieldEndLabelText:
          'Fecha final', // Personaliza la etiqueta de fecha final
      errorFormatText:
          'Formato inválido (dd/mm/yyyy)', // Mensaje de error para formato
      errorInvalidText:
          'Rango inválido', // Mensaje de error para rango inválido
      errorInvalidRangeText:
          'Rango no válido', // Mensaje de error para rango no válido
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

  void _clearColoniaFilter() {
    setState(() {
      _selectedColonia = null;
      _filterSalidas();
    });
  }

  void _clearCalleFilter() {
    setState(() {
      _selectedCalle = null;
      _filterSalidas();
    });
  }

  void _clearAlmacenFilter() {
    setState(() {
      _selectedAlmacen = null;
      _filterSalidas();
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    DateTime? tempSelectedMonth;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Mes para Todas las Salidas'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Selector de año
                    DropdownButton<int>(
                      value: tempSelectedMonth?.year ?? DateTime.now().year,
                      items: List.generate(
                        5,
                        (index) => DateTime.now().year - 2 + index,
                      ).map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            tempSelectedMonth = DateTime(
                              year,
                              tempSelectedMonth?.month ?? DateTime.now().month,
                              1,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Selector de mes
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                tempSelectedMonth = DateTime(
                                  tempSelectedMonth?.year ??
                                      DateTime.now().year,
                                  month,
                                  1,
                                );
                              });
                            },
                            child: Card(
                              color: tempSelectedMonth?.month == month
                                  ? Colors.green[100]
                                  : null,
                              child: Center(
                                child: Text(
                                  DateFormat('MMM', 'es_ES')
                                      .format(DateTime(2020, month)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    if (tempSelectedMonth != null) {
                      setState(() {
                        _selectedMonth = DateTime(
                          tempSelectedMonth!.year,
                          tempSelectedMonth!.month,
                          1, // Siempre día 1
                        );
                      });
                      Navigator.pop(context);
                      _generateExcel();
                      //_filterByMonth();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generateExcel() async {
    if (_selectedMonth == null || _filteredSalidas.isEmpty) {
      showAdvertence(context, 'No hay datos para exportar');
      return;
    }
    setState(() => _isGeneratingExcel = true);
    try {
      await ExcelSalidasMes.generateExcelSalidasMes(
        selectedMonth: _selectedMonth,
        filteredSalidas: _filteredSalidas,
        context: context,
      );
    } catch (e) {
      print('_generateExcel | ListSalidaPage: $e');
    } finally {
      setState(() => _isGeneratingExcel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Salidas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
                      const SizedBox(height: 20),
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
                      if (_startDate != null || _endDate != null) ...[
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
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                //Listas desplegables
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
                      const SizedBox(width: 20),

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
                      const SizedBox(width: 20),

                      //Colonias
                      Expanded(
                        child: CustomListaDesplegableTipo<Colonias>(
                          value: _selectedColonia != null
                              ? _colonias.firstWhere((colonia) =>
                                  colonia.idColonia.toString() ==
                                  _selectedColonia)
                              : null,
                          labelText: 'Seleccionar Colonia',
                          items: _colonias,
                          onChanged: (Colonias? newValue) {
                            setState(() {
                              _selectedColonia = newValue?.idColonia.toString();
                            });
                            _filterSalidas();
                          },
                          itemLabelBuilder: (colonia) =>
                              colonia.nombreColonia ?? 'Desconocido',
                        ),
                      ),
                      if (_selectedColonia != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearColoniaFilter,
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomListaDesplegableTipo<Calles>(
                          value: _selectedCalle != null
                              ? _calles.firstWhere((calle) =>
                                  calle.idCalle.toString() == _selectedCalle)
                              : null,
                          labelText: 'Seleccionar Calle',
                          items: _calles,
                          onChanged: (Calles? newValue) {
                            setState(() {
                              _selectedCalle = newValue?.idCalle.toString();
                            });
                            _filterSalidas();
                          },
                          itemLabelBuilder: (calle) =>
                              calle.calleNombre ?? 'Desconocido',
                        ),
                      ),
                      if (_selectedCalle != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearCalleFilter,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Colors.blue.shade900),
                        )
                      : _buildListView(),
                ),
                const SizedBox(height: 30),
              ],
            ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showExportOptions) ...[
                  _buildExportOption(
                    icon: Icons.download,
                    color: Colors.green.shade900,
                    label: 'Todas las Salidas',
                    onTap: () => _selectMonth(context),
                  ),
                  const SizedBox(height: 8),
                  _buildExportOption(
                    icon: Icons.download,
                    color: Colors.purple.shade900,
                    label: 'Juntas Especiales',
                    onTap: () => _selectMonthForEspeciales(context),
                  ),
                  const SizedBox(height: 8),
                  _buildExportOption(
                    icon: Icons.download,
                    color: Colors.orange.shade900,
                    label: 'Juntas Rurales',
                    onTap: () => _selectMonthForRurales(context),
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton(
                  backgroundColor: Colors.green.shade900,
                  onPressed: () {
                    setState(() {
                      _showExportOptions = !_showExportOptions;
                    });
                  },
                  child: _showExportOptions
                      ? const Icon(Icons.close, color: Colors.white)
                      : SvgPicture.asset(
                          'assets/icons/excel.svg',
                          width: 30,
                          height: 30,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _showExportOptions = false);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
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

        Color colorCard = salida.salida_Estado == false
            ? Colors.red.shade100
            : Colors.blue.shade100;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: colorCard,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () async {
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

              final ordenServicio = _ordenesServicios.firstWhere(
                (ordenS) => ordenS.idOrdenServicio == salida.idOrdenServicio,
                orElse: () => OrdenServicio(folioOS: 'S/F'),
              );

              final colonia = _colonias.firstWhere(
                (colonia) => colonia.idColonia == salida.idColonia,
                orElse: () =>
                    Colonias(idColonia: 0, nombreColonia: 'Desconocido'),
              );

              final calle = _calles.firstWhere(
                (calles) => calles.idCalle == salida.idCalle,
                orElse: () => Calles(idCalle: 0, calleNombre: 'Desconocida'),
              );

              final userAsig = _userAsignado.firstWhere(
                (uas) => uas.id_User == salida.id_User_Asignado,
                orElse: () => Users(id_User: 0, user_Name: 'Desconocido'),
              );

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsSalidaPage(
                    salidas: salidas,
                    almacen: almacen,
                    junta: junta,
                    padron: padron,
                    calle: calle,
                    colonia: colonia,
                    user: user!.user_Name!,
                    userAsignado: userAsig,
                    ordenServicio: ordenServicio,
                    userRole: widget.userRole!,
                  ),
                ),
              );

              if (result == true) {
                await _reloadData();
              }
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
                            ? Text(
                                'Realizado por: ${user.user_Name}',
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              )
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
                        // Text(
                        //   'Referencia: ${salida.salida_Referencia ?? 'No disponible'}',
                        //   overflow: TextOverflow.ellipsis,
                        //   style: const TextStyle(
                        //     fontSize: 15,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 82,
                        child: Text(
                          salida.salida_Fecha ?? 'Sin Fecha',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // Método para seleccionar mes para juntas especiales
  Future<void> _selectMonthForEspeciales(BuildContext context) async {
    DateTime? tempSelectedMonth;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Mes para Juntas Especiales'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Selector de año
                    DropdownButton<int>(
                      value: tempSelectedMonth?.year ?? DateTime.now().year,
                      items: List.generate(
                        5,
                        (index) => DateTime.now().year - 2 + index,
                      ).map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            tempSelectedMonth = DateTime(
                              year,
                              tempSelectedMonth?.month ?? DateTime.now().month,
                              1,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Selector de mes
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                tempSelectedMonth = DateTime(
                                  tempSelectedMonth?.year ??
                                      DateTime.now().year,
                                  month,
                                  1,
                                );
                              });
                            },
                            child: Card(
                              color: tempSelectedMonth?.month == month
                                  ? Colors.purple[100]
                                  : null,
                              child: Center(
                                child: Text(
                                  DateFormat('MMM', 'es_ES')
                                      .format(DateTime(2020, month)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    if (tempSelectedMonth != null) {
                      setState(() {
                        _selectedMonth = DateTime(
                          tempSelectedMonth!.year,
                          tempSelectedMonth!.month,
                          1,
                        );
                      });
                      Navigator.pop(context);
                      _generateExcelJuntasEspeciales();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectMonthForRurales(BuildContext context) async {
    DateTime? tempSelectedMonth;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Mes para Juntas Rurales'),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Selector de año
                    DropdownButton<int>(
                      value: tempSelectedMonth?.year ?? DateTime.now().year,
                      items: List.generate(
                        5,
                        (index) => DateTime.now().year - 2 + index,
                      ).map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setState(() {
                            tempSelectedMonth = DateTime(
                              year,
                              tempSelectedMonth?.month ?? DateTime.now().month,
                              1,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Selector de mes
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                tempSelectedMonth = DateTime(
                                  tempSelectedMonth?.year ??
                                      DateTime.now().year,
                                  month,
                                  1,
                                );
                              });
                            },
                            child: Card(
                              color: tempSelectedMonth?.month == month
                                  ? Colors.orange[100]
                                  : null,
                              child: Center(
                                child: Text(
                                  DateFormat('MMM', 'es_ES')
                                      .format(DateTime(2020, month)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    if (tempSelectedMonth != null) {
                      setState(() {
                        _selectedMonth = DateTime(
                          tempSelectedMonth!.year,
                          tempSelectedMonth!.month,
                          1,
                        );
                      });
                      Navigator.pop(context);
                      _generateExcelJuntasRurales();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para generar Excel de juntas especiales
  Future<void> _generateExcelJuntasEspeciales() async {
    if (_selectedMonth == null) return;

    setState(() => _isGeneratingExcel = true);
    try {
      await ExcelSalidasMes.generateExcelJuntasEspeciales(
        selectedMonth: _selectedMonth,
        allSalidas: _allSalidas,
        context: context,
      );
    } catch (e) {
      print('Error al generar Excel Juntas Especiales: $e');
    } finally {
      setState(() => _isGeneratingExcel = false);
    }
  }

// Método para generar Excel de juntas regulares
  Future<void> _generateExcelJuntasRurales() async {
    if (_selectedMonth == null) return;

    setState(() => _isGeneratingExcel = true);
    try {
      await ExcelSalidasMes.generateExcelJuntasRurales(
        selectedMonth: _selectedMonth,
        allSalidas: _allSalidas,
        context: context,
      );
    } catch (e) {
      print('Error al generar Excel Juntas Regulares: $e');
    } finally {
      setState(() => _isGeneratingExcel = false);
    }
  }
}
