import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/presupuestos_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/presupuestos/details_presupuestos.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/formularios/custom_autocomplete_field.dart';

class ListPresupuestosPage extends StatefulWidget {
  final String? userRole;
  final String? userName;
  const ListPresupuestosPage({super.key, this.userRole, this.userName});

  @override
  State<ListPresupuestosPage> createState() => _ListPresupuestosPageState();
}

class _ListPresupuestosPageState extends State<ListPresupuestosPage> {
  final PresupuestosController _presupuestosController =
      PresupuestosController();
  final PadronController _padronController = PadronController();
  final UsersController _usersController = UsersController();
  final ProductosController _productosController = ProductosController();

  final TextEditingController _searchController = TextEditingController();
  List<Presupuestos> _allPresupuestos = [];
  List<Presupuestos> _filteredPresupuestos = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};
  Map<int, Padron> _padronCache = {};

  List<Padron> _padrones = [];
  List<Users> _users = [];
  List<Productos> _productos = [];

  String? _selectedPadron;

  bool _isLoading = true;

  int _currentPage = 1;
  int _itemsPerPage = 20;
  int get _totalPages =>
      (_filteredPresupuestosGrouped.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPresupuestos);
  }

  Map<String, List<Presupuestos>> get _paginatedGroupedPresupuestos {
    // Primero agrupar todos los presupuestos filtrados
    Map<String, List<Presupuestos>> groupedPresupuestos = {};
    for (var presupuesto in _filteredPresupuestos) {
      groupedPresupuestos.putIfAbsent(
        presupuesto.presupuestoFolio,
        () => [],
      );
      groupedPresupuestos[presupuesto.presupuestoFolio]!.add(presupuesto);
    }

    // Convertir a lista de grupos y paginar
    final groupsList = groupedPresupuestos.entries.toList();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    // Crear un nuevo mapa solo con los grupos de la página actual
    final paginatedGroups = groupsList.sublist(
      startIndex.clamp(0, groupsList.length),
      endIndex.clamp(0, groupsList.length),
    );

    return Map.fromEntries(paginatedGroups);
  }

  Map<String, List<Presupuestos>> get _filteredPresupuestosGrouped {
    Map<String, List<Presupuestos>> grouped = {};
    for (var presupuesto in _filteredPresupuestos) {
      grouped.putIfAbsent(
        presupuesto.presupuestoFolio,
        () => [],
      );
      grouped[presupuesto.presupuestoFolio]!.add(presupuesto);
    }
    return grouped;
  }

  Future<void> _reloadData() async {
    setState(() => _isLoading = true);
    try {
      final presupuestos = await _presupuestosController.getPresupuestos();
      setState(() {
        _allPresupuestos = presupuestos;
        _filterPresupuestos(); // Esto aplicará los filtros actuales a los nuevos datos
      });
    } catch (e) {
      print('Error al recargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      // Cargar presupuestos
      final presupuestos = await _presupuestosController.getPresupuestos();
      final productos = await _productosController.listProductos();
      final users = await _usersController.listUsers();
      final padrones = await _padronController.listPadron();

      setState(() {
        _allPresupuestos = presupuestos;
        _filteredPresupuestos = presupuestos;

        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};
        _padronCache = {for (var pad in padrones) pad.idPadron!: pad};

        _padrones = padrones;
        _users = users;
        _productos = productos;

        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPresupuestos() {
    setState(() {
      _filteredPresupuestos = _allPresupuestos.where((presupuesto) {
        final fechaString = presupuesto.presupuestoFecha;
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

        // Match búsqueda por folio
        final matchesSearch = _searchController.text.isEmpty ||
            presupuesto.presupuestoFolio.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

        // Match Padron
        final matchesPadron = _selectedPadron == null ||
            presupuesto.idPadron.toString() == _selectedPadron;

        return matchesDate && matchesSearch && matchesPadron;
      }).toList();
      _currentPage = 1;
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
      helpText: 'Seleccionar rango',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      saveText: 'Guardar',
      fieldStartLabelText: 'Fecha inicial',
      fieldEndLabelText: 'Fecha final',
      errorFormatText: 'Formato inválido (dd/mm/yyyy)',
      errorInvalidText: 'Rango inválido',
      errorInvalidRangeText: 'Rango no válido',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterPresupuestos();
    }
  }

  Widget _buildPaginationControls() {
    if (_filteredPresupuestos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed:
                _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          ),
          Text(
            'Página $_currentPage de $_totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentPage < _totalPages
                ? () => setState(() => _currentPage++)
                : null,
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: _itemsPerPage,
            items: [10, 20, 50, 100].map(
              (value) {
                return DropdownMenuItem<int>(
                    value: value, child: Text('$value por página'));
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                _itemsPerPage = value!;
                _currentPage = 1;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Presupuestos',
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
                      // Folio
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por folio',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Padron
                      Expanded(
                        child: CustomAutocompleteField<Padron>(
                          value: _selectedPadron != null
                              ? _padrones.firstWhere(
                                  (padron) =>
                                      padron.idPadron.toString() ==
                                      _selectedPadron,
                                  orElse: () =>
                                      Padron(idPadron: 0, padronNombre: 'N/A'),
                                )
                              : null,
                          labelText: 'Buscar Padron',
                          items: _padrones,
                          prefixIcon: Icons.search,
                          onChanged: (Padron? newValue) {
                            setState(() {
                              _selectedPadron = newValue?.idPadron.toString();
                            });
                            _filterPresupuestos();
                          },
                          itemLabelBuilder: (padron) =>
                              '${padron.idPadron ?? 0} - ${padron.padronNombre ?? 'N/A'}',
                          itemValueBuilder: (padron) =>
                              padron.idPadron.toString(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Fecha
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
                              _filterPresupuestos();
                            });
                          },
                        ),
                      ],
                      const SizedBox(width: 10),
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
                _buildPaginationControls(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildListView() {
    if (_filteredPresupuestos.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No hay presupuestos que coincidan con el folio'
              : (_startDate != null || _endDate != null)
                  ? 'No hay presupuestos que coincidan con el rango de fechas'
                  : 'No hay presupuestos disponibles',
        ),
      );
    }

    final groupedPresupuestos = _paginatedGroupedPresupuestos;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: groupedPresupuestos.keys.length,
            itemBuilder: (context, index) {
              if (index >= groupedPresupuestos.keys.length) {
                return const SizedBox.shrink();
              }
              String codFolio = groupedPresupuestos.keys.elementAt(index);
              List<Presupuestos> presupuestos = groupedPresupuestos[codFolio]!;

              double totalUnidades = presupuestos.fold(
                  0, (sum, item) => sum + item.presupuestoUnidades);

              double totalCosto = presupuestos.fold(
                  0, (sum, item) => sum + item.presupuestoTotal);

              final presupuestoPrincipal = presupuestos.first;
              final presupuesto = presupuestoPrincipal;

              final producto = _productosCache[presupuesto.idProducto];
              final user = _usersCache[presupuesto.idUser];
              final padron = _padronCache[presupuesto.idPadron];

              Color colorCard = presupuesto.presupuestoEstado == false
                  ? Colors.red.shade100
                  : Colors.green.shade100;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: colorCard,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPresupuestoPage(
                          presupuestos:
                              presupuestos, // Lista de presupuestos del folio
                          user: widget.userName!,
                          userRole: widget.userRole!,
                          padron: padron, // Padrón obtenido del cache
                          userCreoPresupuesto:
                              user, // Usuario que creó el presupuesto
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
                                  ? Text(
                                      'Realizado por: ${user.user_Name}',
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const Text('Usuario no encontrado'),
                              const SizedBox(height: 10),
                              padron != null
                                  ? Text(
                                      'Padron: ${padron.padronNombre}',
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const Text('Padron no encontrado'),
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
                                'Estado: ${presupuesto.presupuestoEstado ? 'Sin usar' : 'Usado'}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: presupuesto.presupuestoEstado
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(
                                width: 82,
                                child: Text(
                                  presupuesto.presupuestoFecha,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Indicador de estado
                            Icon(
                              presupuesto.presupuestoEstado
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: presupuesto.presupuestoEstado
                                  ? Colors.green
                                  : Colors.red,
                              size: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
