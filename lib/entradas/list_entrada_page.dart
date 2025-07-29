import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/entradas/details_entrada_page.dart';
import 'package:jmas_desktop/entradas/excel/excel_entradas.dart';
import 'package:jmas_desktop/service/auth_service.dart';
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
  final bool _isLoadingCancel = false;

  String? idUserDelete;

  DateTime? _selectedMonth;
  bool _isGeneratingExcel = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserId();
    _searchController.addListener(_filterEntradas);
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      _allEntradas.clear();
      _filteredEntradas.clear();

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

        //Parsear la fecha del string
        final fecha = entrada.entrada_Fecha != null
            ? DateFormat('dd/MM/yyyy HH:mm').parse(entrada.entrada_Fecha!)
            : null;

        final fechaDMY =
            fecha != null ? DateTime(fecha.year, fecha.month, fecha.day) : null;

        bool matchesDate = true;
        if (_startDate != null || _endDate != null) {
          if (fechaDMY == null) return false;

          if (_startDate != null) {
            matchesDate = matchesDate &&
                !fechaDMY.isBefore(DateTime(
                    _startDate!.year, _startDate!.month, _startDate!.day));
          }

          if (_endDate != null) {
            matchesDate = matchesDate &&
                !fechaDMY.isAfter(
                    DateTime(_endDate!.year, _endDate!.month, _endDate!.day));
          }
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

        return matchesText && matchesDate && matchesAlmacen && matchesProveedor;
      }).toList();
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
              title: const Text('Seleccionar Mes'),
              content: SizedBox(
                width: 300,
                height: 350,
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
                                  ? Colors.blue[100]
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
                      _filterByMonth();
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

  void _filterByMonth() {
    if (_selectedMonth == null) return;

    setState(() {
      _filteredEntradas = _allEntradas.where(
        (entradas) {
          if (entradas.entrada_Fecha == null) return false;

          try {
            final fecha = DateFormat('dd/MM/yyyy HH:mm:ss')
                .parse(entradas.entrada_Fecha!);
            return fecha.month == _selectedMonth!.month &&
                fecha.year == _selectedMonth!.year;
          } catch (e) {
            return false;
          }
        },
      ).toList();
    });
  }

  Future<void> _generateExcel() async {
    if (_selectedMonth == null || _filteredEntradas.isEmpty) {
      showAdvertence(context, 'No hay datos para exportar');
      return;
    }
    setState(() => _isGeneratingExcel = true);
    try {
      await ExcelEntradasMes.generateExcelEntradasMes(
        selectedMonth: _selectedMonth,
        filteredEntradas: _filteredEntradas,
        context: context,
      );
    } catch (e) {
      print('_generateExcel | ListEntradaPage: $e');
    } finally {
      setState(() => _isGeneratingExcel = false);
    }
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
      appBar: AppBar(
        title: const Text(
          'Lista de Entradas',
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
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por Folio o Referencia',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 20),
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
                      if (_startDate != null || _endDate != null) ...[
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
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                      const SizedBox(width: 20),

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
                      if (_selectedProveedor != null) ...[
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _clearProveedorFilter,
                        ),
                      ],
                      const SizedBox(width: 20),

                      //Excel
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade900,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _selectMonth(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 27, 94, 32),
                            ),
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                            ),
                            label: Text(
                              _selectedMonth != null
                                  ? 'Mes seleccionado: ${DateFormat('MMMM yyyy', 'es_ES').format(_selectedMonth!)}'
                                  : 'Excel Entradas por Mes',
                              style: const TextStyle(
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_selectedMonth != null) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedMonth = null;
                              _filteredEntradas = List.from(_allEntradas);
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade700,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed:
                                _isGeneratingExcel ? null : _generateExcel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 200, 242, 201),
                            ),
                            icon: _isGeneratingExcel
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Icon(Icons.download,
                                    color: Colors.black),
                            label: const Text(
                              'Exportar a Excel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
              ? Colors.red.shade100
              : Colors.blue.shade100,
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
                          overflow: TextOverflow.ellipsis,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 10),
                        // Text(
                        //   'Referencia: ${entrada.entrada_Referencia}',
                        //   style: const TextStyle(
                        //     fontSize: 15,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 81,
                        child: Text(
                          entrada.entrada_Fecha ?? 'Sin Fecha',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
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

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserDelete = decodeToken?['Id_User'] ?? '0';
  }
}
