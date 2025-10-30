import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/orden_compra_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListOrdenCompraPage extends StatefulWidget {
  final String? userRole;
  const ListOrdenCompraPage({super.key, this.userRole});

  @override
  State<ListOrdenCompraPage> createState() => _ListOrdenCompraPageState();
}

class _ListOrdenCompraPageState extends State<ListOrdenCompraPage> {
  final OrdenCompraController _ordenCompraController = OrdenCompraController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _requisicionController = TextEditingController();

  List<OrdenCompra> _allOrdenesCompra = [];
  List<OrdenCompra> _filteredOrdenesCompra = [];
  List<Proveedores> _proveedores = [];

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProveedor;
  bool _sortByFechaEntrega = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterOrdenesCompra);
    _requisicionController.addListener(_filterOrdenesCompra);
  }

  Future<void> _loadData() async {
    try {
      final ordenesCompra = await _ordenCompraController.listOrdenCompra();
      final proveedores = await _proveedoresController.listProveedores();

      setState(() {
        _allOrdenesCompra = ordenesCompra;
        _filteredOrdenesCompra = ordenesCompra;
        _proveedores = proveedores;
        _isLoading = false;
      });
      _filterOrdenesCompra();
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterOrdenesCompra() {
    final query = _searchController.text.trim().toLowerCase();
    final requisicionQuery = _requisicionController.text.trim();

    setState(() {
      _filteredOrdenesCompra = _allOrdenesCompra.where((orden) {
        final folio = (orden.folioOC ?? '').toString().toLowerCase();
        final requisicion = (orden.requisicionOC ?? '').toString();

        // Filtro por folio
        final matchesFolio = query.isEmpty || folio.contains(query);

        // Filtro por requisición
        final matchesRequisicion =
            requisicionQuery.isEmpty || requisicion.contains(requisicionQuery);

        // Filtro por fechas de entrega
        bool matchesDate = true;
        if (_startDate != null || _endDate != null) {
          if (orden.fechaEntregaOC == null) return false;

          final fechaEntrega = _parseCustomDate(orden.fechaEntregaOC!);
          if (fechaEntrega == null) return false;

          if (_startDate != null) {
            matchesDate = matchesDate &&
                fechaEntrega
                    .isAfter(_startDate!.subtract(const Duration(days: 1)));
          }

          if (_endDate != null) {
            matchesDate = matchesDate &&
                fechaEntrega.isBefore(_endDate!.add(const Duration(days: 1)));
          }
        }

        // Filtro por proveedor
        final matchesProveedor = _selectedProveedor == null ||
            orden.idProveedor.toString() == _selectedProveedor;

        return matchesFolio &&
            matchesRequisicion &&
            matchesDate &&
            matchesProveedor;
      }).toList();

      // Ordenar por fecha de entrega más próxima si está activado
      if (_sortByFechaEntrega) {
        _filteredOrdenesCompra.sort((a, b) {
          final fechaA = a.fechaEntregaOC != null
              ? _parseCustomDate(a.fechaEntregaOC!)
              : null;
          final fechaB = b.fechaEntregaOC != null
              ? _parseCustomDate(b.fechaEntregaOC!)
              : null;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaA.compareTo(fechaB);
        });
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterOrdenesCompra();
    }
  }

  void _clearProveedorFilter() {
    setState(() {
      _selectedProveedor = null;
      _filterOrdenesCompra();
    });
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      case 'completada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Órdenes de Compra',
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Buscador por folio
                          Expanded(
                            child: CustomTextFielTexto(
                              controller: _searchController,
                              labelText: 'Buscar por folio',
                              prefixIcon: Icons.search,
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Buscador por requisición
                          Expanded(
                            child: CustomTextFielTexto(
                              controller: _requisicionController,
                              labelText: 'Buscar por requisición',
                              prefixIcon: Icons.numbers,
                            ),
                          ),
                          const SizedBox(width: 20),

                          //Proveedor
                          Expanded(
                            child: CustomListaDesplegableTipo<Proveedores>(
                              value: _selectedProveedor != null
                                  ? _proveedores.firstWhere((prov) =>
                                      prov.id_Proveedor.toString() ==
                                      _selectedProveedor)
                                  : null,
                              labelText: 'Filtrar por proveedor',
                              items: _proveedores,
                              onChanged: (Proveedores? newValue) {
                                setState(() {
                                  _selectedProveedor =
                                      newValue?.id_Proveedor.toString();
                                });
                                _filterOrdenesCompra();
                              },
                              itemLabelBuilder: (prov) =>
                                  '${prov.proveedor_Name ?? 'Proveedor desconocido'} - (${prov.id_Proveedor})',
                            ),
                          ),
                          if (_selectedProveedor != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: _clearProveedorFilter,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Selector de rango de fechas (futuras)
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
                                    ? 'Entrega: ${DateFormat('yyyy-MM-dd').format(_startDate!)} a ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                                    : 'Rango de fechas de entrega',
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
                                _filterOrdenesCompra();
                              });
                            },
                          ),

                          // Botón para ordenar por fecha de entrega
                          IconButton(
                            icon: Icon(
                              Icons.sort,
                              color: _sortByFechaEntrega
                                  ? Colors.blue.shade900
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _sortByFechaEntrega = !_sortByFechaEntrega;
                                _filterOrdenesCompra();
                              });
                            },
                            tooltip: 'Ordenar por fecha de entrega',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
    );
  }

  Widget _buildListView() {
    if (_filteredOrdenesCompra.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty ||
                  _requisicionController.text.isNotEmpty
              ? 'No hay órdenes que coincidan con la búsqueda'
              : (_startDate != null || _endDate != null)
                  ? 'No hay órdenes que coincidan con el rango de fechas'
                  : (_selectedProveedor != null)
                      ? 'No hay órdenes para este proveedor'
                      : 'No hay órdenes de compra disponibles',
        ),
      );
    }

    // Agrupar órdenes por folio
    Map<String, List<OrdenCompra>> groupedOrdenes = {};
    for (var orden in _filteredOrdenesCompra) {
      groupedOrdenes.putIfAbsent(
        orden.folioOC ?? 'Sin folio',
        () => [],
      );
      groupedOrdenes[orden.folioOC]!.add(orden);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: groupedOrdenes.keys.length,
      itemBuilder: (context, index) {
        if (index >= groupedOrdenes.keys.length) {
          return const SizedBox.shrink();
        }

        String codFolio = groupedOrdenes.keys.elementAt(index);
        List<OrdenCompra> ordenes = groupedOrdenes[codFolio]!;
        final ordenPrincipal = ordenes.first;

        // Obtener nombre del proveedor
        final proveedor = _proveedores.firstWhere(
          (p) => p.id_Proveedor == ordenPrincipal.idProveedor,
          orElse: () => Proveedores(proveedor_Name: 'Proveedor desconocido'),
        );

        double totalOrden =
            ordenes.fold(0, (sum, item) => sum + (item.totalOC ?? 0));

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // Navegación a página de detalles
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
                        Row(
                          children: [
                            Text(
                              'Folio $codFolio',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              backgroundColor:
                                  _getEstadoColor(ordenPrincipal.estadoOC),
                              label: Text(
                                ordenPrincipal.estadoOC ?? 'Sin estado',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Proveedor: ${proveedor.proveedor_Name}',
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Entrega: ${ordenPrincipal.fechaEntregaOC ?? 'No especificada'}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Req: ${ordenPrincipal.requisicionOC ?? 'N/A'} | Total: \$${totalOrden.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${ordenes.length} ${ordenes.length == 1 ? 'ítem' : 'ítems'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
}

DateTime? _parseCustomDate(String dateString) {
  try {
    final parts = dateString.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}
