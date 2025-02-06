import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/entradas/details_entrada_page.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListEntradaPage extends StatefulWidget {
  const ListEntradaPage({super.key});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final EntradasController _entradasController = EntradasController();
  final ProductosController _productosController = ProductosController();
  final UsersController _usersController = UsersController();

  final TextEditingController _searchController = TextEditingController();
  List<Entradas> _allEntradas = [];
  List<Entradas> _filteredEntradas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterEntradas);
  }

  Future<void> _loadData() async {
    try {
      final entradas = await _entradasController.listEntradas();
      final productos = await _productosController.listProductos();
      final users = await _usersController.listUsers();

      setState(() {
        _allEntradas = entradas;
        _filteredEntradas = entradas;

        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};

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
                  child: _buildListView(),
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
          color: const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              showEntradaDetailsDialog(
                context,
                entrada,
                _productosCache,
                _usersCache,
              );
            },
            child: ListTile(
              title: producto != null
                  ? Text(
                      '${producto.prodDescripcion}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Producto no encontrado'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  user != null
                      ? Text('Realizado por: ${user.user_Name}',
                          style: const TextStyle(
                            fontSize: 15,
                          ))
                      : const Text('Rrealizado por: Usuario no encontrado'),
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
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
