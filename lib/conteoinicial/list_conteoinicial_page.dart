import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListConteoinicialPage extends StatefulWidget {
  const ListConteoinicialPage({super.key});

  @override
  State<ListConteoinicialPage> createState() => _ListConteoinicialPageState();
}

class _ListConteoinicialPageState extends State<ListConteoinicialPage> {
  final CapturainviniController _capturainviniController =
      CapturainviniController();
  final ProductosController _productosController = ProductosController();
  final AlmacenesController _almacenesController = AlmacenesController();

  final TextEditingController _searchController = TextEditingController();

  List<Capturainvini> _allConteos = [];
  List<Capturainvini> _filteredConteos = [];
  Map<int, String> _productosCache = {};
  Map<int, String> _almacenesCache = {};
  bool _isLoading = false;
  String? _selectedMonth;
  final List<String> _months = [
    'Todos',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterConteos);
    _selectedMonth = 'Todos';
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar datos en paralelo
      final results = await Future.wait([
        _capturainviniController.listCapturaI(),
        _productosController.listProductos(),
        _almacenesController.listAlmacenes(),
      ]);

      // Procesar productos
      final productos = results[1] as List<Productos>;
      _productosCache = {
        for (var p in productos)
          p.id_Producto!: '${p.prodDescripcion} (${p.id_Producto})'
      };

      // Procesar almacenes
      final almacenes = results[2] as List<Almacenes>;
      _almacenesCache = {
        for (var a in almacenes)
          a.id_Almacen!: a.almacen_Nombre ?? 'Almacén ${a.id_Almacen}'
      };

      // Procesar conteos
      setState(() {
        _allConteos = results[0] as List<Capturainvini>;
        _filteredConteos = _allConteos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterConteos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConteos = _allConteos.where((conteo) {
        final productoNombre =
            _productosCache[conteo.id_Producto]?.toLowerCase() ?? '';
        final almacenNombre =
            _almacenesCache[conteo.id_Almacen]?.toLowerCase() ?? '';
        final productoId = conteo.id_Producto?.toString() ?? '';

        return productoNombre.contains(query) ||
            almacenNombre.contains(query) ||
            productoId.contains(query);
      }).toList();

      // Aplicar filtro por mes si está seleccionado
      if (_selectedMonth != null && _selectedMonth != 'Todos') {
        final monthIndex = _months.indexOf(_selectedMonth!);
        _filteredConteos = _filteredConteos.where((conteo) {
          if (conteo.invIniFecha == null) return false;

          // Parsear fecha en formato dd/MM/yy
          final dateParts = conteo.invIniFecha!.split('/');
          if (dateParts.length != 3) return false;

          final month = int.tryParse(dateParts[1]);
          return month == monthIndex;
        }).toList();
      }
    });
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';

    try {
      final parts = date.split('/');
      if (parts.length != 3) return date;

      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2].length == 2 ? '20${parts[2]}' : parts[2];

      return '$day/$month/$year';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Conteos Iniciales'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // Filtros de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFielTexto(
                      controller: _searchController,
                      labelText: 'Buscar por ID de Producto o Almacén',
                      prefixIcon: Icons.search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedMonth,
                    items: _months.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                        _filterConteos();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //Listado de conteos
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade900,
                      ),
                    )
                  : _filteredConteos.isEmpty
                      ? const Center(
                          child: Text('No hay conteos iniciales registrados'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredConteos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final conteo = _filteredConteos[index];
                            final productoNombre =
                                _productosCache[conteo.id_Producto] ??
                                    'Producto no encontrado';
                            final almacenNombre =
                                _almacenesCache[conteo.id_Almacen] ??
                                    'Almacén no encontrado';

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icono
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.inventory,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Producto y Almacén
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              //Prodcuto
                                              Text(
                                                productoNombre,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade900,
                                                ),
                                              ),
                                              Text(
                                                almacenNombre,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Conteo y Fecha
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Conteo: ${conteo.invIniConteo?.toStringAsFixed(2) ?? '0.00'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Fecha: ${conteo.invIniFecha ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
