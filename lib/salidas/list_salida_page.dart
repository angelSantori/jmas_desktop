import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';

class ListSalidaPage extends StatefulWidget {
  const ListSalidaPage({super.key});

  @override
  State<ListSalidaPage> createState() => _ListSalidaPageState();
}

class _ListSalidaPageState extends State<ListSalidaPage> {
  final SalidasController _salidasController = SalidasController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final UsersController _usersController = UsersController();

  final TextEditingController _searchController = TextEditingController();
  List<Salidas> _allSalidas = [];
  List<Salidas> _filteredSalidas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Proveedores> _proveedoresCache = {};
  Map<int, Users> _usersCache = {};

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
      final proveedores = await _proveedoresController.listProveedores();
      final users = await _usersController.listUsers();

      setState(() {
        _allSalidas = salidas;
        _filteredSalidas = salidas;

        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _proveedoresCache = {
          for (var prov in proveedores) prov.id_Proveedor!: prov
        };
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

  void _filterSalidas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSalidas = _allSalidas.where((salida) {
        final folio = salida.salida_Folio?.toString() ?? '';
        final fechaString = salida.salida_Fecha;

        final fecha = fechaString != null ? parseDate(fechaString) : null;

        final matchesFolio =
            query.isEmpty || folio.toLowerCase().contains(query);

        final matchesDate = fecha != null &&
            (_startDate == null || !fecha.isBefore(_startDate!)) &&
            (_endDate == null || !fecha.isAfter(_endDate!));

        return matchesFolio && matchesDate;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Salidas'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por folio',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDateRange(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate != null && _endDate != null
                              ? 'Desde: ${_startDate!.toLocal()} - Hasta: ${_endDate!.toLocal()}'
                              : 'Seleccionar rango de fechas'),
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
                Expanded(
                  child: _buildListView(),
                ),
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

    return ListView.builder(
      itemCount: _filteredSalidas.length,
      itemBuilder: (context, index) {
        final salida = _filteredSalidas[index];
        final producto = _productosCache[salida.id_Producto];
        final proveedor = _proveedoresCache[salida.id_Proveedor];
        final user = _usersCache[salida.user_Reporte];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          color: const Color.fromARGB(255, 201, 230, 242),
          child: ListTile(
            title: producto != null
                ? Text(
                    '${producto.producto_Descripcion}',
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
                proveedor != null
                    ? Text(
                        '${proveedor.proveedor_Name}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Proveedor no encontrado'),
                const SizedBox(height: 10),
                user != null
                    ? Text('Realizado por: ${user.user_Name}',
                        style: const TextStyle(fontSize: 15))
                    : const Text('Usuario no encontrado'),
                const SizedBox(height: 10),
                Text(
                  'Unidades: ${salida.salida_Unidades ?? 'No disponible'}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Costo: \$${salida.salida_Costo}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                )
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Folio: ${salida.salida_Folio ?? "Sin Folio"}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  salida.salida_Fecha ?? 'Sin Fecha',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
