import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';

class ListEntradaPage extends StatefulWidget {
  const ListEntradaPage({super.key});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final EntradasController _entradasController = EntradasController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  final TextEditingController _searchController = TextEditingController();
  List<Entradas> _allEntradas = [];
  List<Entradas> _filteredEntradas = [];

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadEntradas();
    _searchController.addListener(_filterEntradas);
  }

  Future<void> _loadEntradas() async {
    try {
      final entradas = await _entradasController.listEntradas();
      setState(() {
        _allEntradas = entradas;
        _filteredEntradas = entradas;
      });
    } catch (e) {
      print('Error al cargar entradas: $e');
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error al parsear fecha: $e');
    }
    return null;
  }

  void _filterEntradas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntradas = _allEntradas.where((entrada) {
        final folio = entrada.entrada_Folio?.toString() ?? '';
        final fechaString = entrada.entrada_Fecha;

        //Parsear la fecha del string
        final fecha = fechaString != null ? _parseDate(fechaString) : null;

        //Validar folio
        final matchesFolio =
            query.isEmpty || folio.toLowerCase().contains(query);

        //Validar rango de fechas
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
      _filterEntradas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Entradas'),
      ),
      body: Column(
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
                    label: Text(
                      _startDate != null && _endDate != null
                          ? 'Desde: ${_startDate!.toLocal()} Hasta: ${_endDate!.toLocal()}'
                          : 'Seleccionar rango de fechas',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
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
            child: _filteredEntradas.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No hay entradas que coincidan con el folio'
                          : (_startDate != null || _endDate != null)
                              ? 'No har entradas que coincidan con el rango de fechas'
                              : 'No hay entradas disponibles',
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredEntradas.length,
                    itemBuilder: (context, index) {
                      final entrada = _filteredEntradas[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: FutureBuilder<Productos?>(
                            future: _productosController
                                .getProductoById(entrada.id_Producto!),
                            builder: (context, productoSnapshot) {
                              if (productoSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Cargando producto...');
                              } else if (productoSnapshot.hasError) {
                                return const Text('Error al cargar producto');
                              } else if (productoSnapshot.data == null) {
                                return const Text('Producto no encontrado');
                              } else {
                                return Text(
                                  '${productoSnapshot.data!.producto_Descripcion}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Proveedores?>(
                                future: _proveedoresController
                                    .getProveedorById(entrada.id_Proveedor!),
                                builder: (context, proveedorSnapshot) {
                                  if (proveedorSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Cargando proveedor...');
                                  } else if (proveedorSnapshot.hasError) {
                                    return const Text(
                                        'Error al cargar proveedor');
                                  } else if (proveedorSnapshot.data == null) {
                                    return const Text(
                                        'Proveedor no encontrado');
                                  } else {
                                    return Text(
                                      '${proveedorSnapshot.data!.proveedor_Name}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Unidades: ${entrada.entrada_Unidades ?? "No disponible"}',
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
                              )
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Folio: ${entrada.entrada_Folio ?? "Sin Folio"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                entrada.entrada_Fecha ?? 'Sin Fecha',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
