import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';

class InventoryDashboardPage extends StatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  State<InventoryDashboardPage> createState() => _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends State<InventoryDashboardPage> {
  final EntradasController _entradasController = EntradasController();
  final SalidasController _salidasController = SalidasController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final JuntasController _juntasController = JuntasController();

  DateTimeRange? _selectedDateRange;
  int? _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  List<Entradas> _entradas = [];
  List<Salidas> _salidas = [];
  List<Productos> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entradas = await _entradasController.listEntradas();
    final salidas = await _salidasController.listSalidas();
    final productos = await _productosController.listProductos();

    setState(() {
      _entradas = entradas;
      _salidas = salidas;
      _productos = productos;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedMonth = null;
      });
      _loadData();
    }
  }

  void _selectMonth(int? month) {
    setState(() {
      _selectedMonth = month;
      _selectedDateRange = null;
    });
    _loadData();
  }

  void _selectYear(int? year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
      _selectedDateRange = null;
    });
    _loadData();
  }

  List<Entradas> get _filteredEntradas {
    if (_selectedDateRange != null) {
      return _entradas.where((e) {
        final fecha = _parseDate(e.entrada_Fecha ?? '');
        return fecha != null &&
            fecha.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            fecha
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    } else if (_selectedMonth != null) {
      return _entradas.where((e) {
        final fecha = _parseDate(e.entrada_Fecha ?? '');
        return fecha != null &&
            fecha.month == _selectedMonth &&
            fecha.year == _selectedYear;
      }).toList();
    }
    return _entradas;
  }

  List<Salidas> get _filteredSalidas {
    if (_selectedDateRange != null) {
      return _salidas.where((s) {
        final fecha = _parseDate(s.salida_Fecha ?? '');
        return fecha != null &&
            fecha.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            fecha
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    } else if (_selectedMonth != null) {
      return _salidas.where((s) {
        final fecha = _parseDate(s.salida_Fecha ?? '');
        return fecha != null &&
            fecha.month == _selectedMonth &&
            fecha.year == _selectedYear;
      }).toList();
    }
    return _salidas;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  double get _totalCostoAlmacen {
    return _productos.fold(0, (sum, producto) {
      final existencia = producto.prodExistencia ?? 0;
      final costo = producto.prodCosto ?? 0;
      return sum + (existencia * costo);
    });
  }

  Map<int, double> get _productosMovimientos {
    final Map<int, double> movimientos = {};

    // Contar entradas por producto
    for (final entrada in _filteredEntradas) {
      final productoId = entrada.idProducto ?? 0;
      movimientos.update(
        productoId,
        (value) => value + (entrada.entrada_Unidades ?? 0),
        ifAbsent: () => entrada.entrada_Unidades ?? 0,
      );
    }

    // Contar salidas por producto
    for (final salida in _filteredSalidas) {
      final productoId = salida.idProducto ?? 0;
      movimientos.update(
        productoId,
        (value) => value + (salida.salida_Unidades ?? 0),
        ifAbsent: () => salida.salida_Unidades ?? 0,
      );
    }

    return movimientos;
  }

  Map<int, int> get _proveedoresRecurrentes {
    final Map<int, int> conteo = {};

    for (final entrada in _filteredEntradas) {
      final proveedorId = entrada.id_Proveedor ?? 0;
      conteo.update(
        proveedorId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return conteo;
  }

  Map<int, int> get _juntasRecurrentes {
    final Map<int, int> conteo = {};

    for (final salida in _filteredSalidas) {
      final juntaId = salida.id_Junta ?? 0;
      conteo.update(
        juntaId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return conteo;
  }

  final NumberFormat _decimalFormat = NumberFormat.decimalPattern('en_US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Almacén'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          DropdownButton<int>(
            value: _selectedMonth ?? DateTime.now().month,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    DateFormat('MMMM', 'es_ES')
                        .format(DateTime(0, index + 1))
                        .toUpperCase(),
                  ));
            }),
            onChanged: _selectMonth,
          ),
          DropdownButton<int>(
            value: _selectedYear,
            items: List.generate(1, (index) {
              final year = DateTime.now().year + index;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: _selectYear,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Primera fila con métricas principales
            Row(
              children: [
                _buildMetricCard(
                  'Total Entradas',
                  _decimalFormat.format(_filteredEntradas.length),
                  Icons.input,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Total Salidas',
                  _decimalFormat.format(_filteredSalidas.length),
                  Icons.output,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                    'Costo Almacén',
                    '${_totalCostoAlmacen < 0 ? '-' : ''}\$${_decimalFormat.format(_totalCostoAlmacen.abs())}',
                    Icons.attach_money,
                    Colors.green.shade800,
                    isNegative: _totalCostoAlmacen < 0),
              ],
            ),
            const SizedBox(height: 16),

            // Segunda fila con gráficos
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyBarChart(
                    'Entradas y Salidas por Mes',
                    _buildMonthlyData(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPieChart(
                    'Productos con Más Entradas / Salidas',
                    _buildTopProductsData(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tercera fila con más gráficos
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getProvidersChartData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error al cargar datos'));
                      }
                      final data = snapshot.data!;
                      return _buildBarChart(
                        'Proveedores Recurrentes',
                        data['data'] as List<BarChartGroupData>,
                        labels: data['labels'] as List<String>,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getJuntasChartData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error al cargar datos'));
                      }
                      final data = snapshot.data!;
                      return _buildBarChart(
                        'Juntas Recurrentes',
                        data['data'] as List<BarChartGroupData>,
                        labels: data['labels'] as List<String>,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color,
      {bool isNegative = false}) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 40, color: isNegative ? Colors.red.shade800 : color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      isNegative ? Colors.red.shade800 : Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, List<BarChartGroupData> barGroups,
      {List<String>? labels}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(barGroups),
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Display "ID: value" for each bar
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'ID: $value',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final name =
                            labels != null && groupIndex < labels.length
                                ? labels[groupIndex]
                                : 'ID: ${group.x}';
                        return BarTooltipItem(
                          '$name\nMovimientos: ${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, List<PieChartSectionData> sections) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(
                    enabled: true,
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                ),
              ),
            ),
            // Leyenda con tooltips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: sections.map((section) {
                  // Obtener el ID del producto del título de la sección
                  final productId = _getProductIdFromSection(section);

                  // Buscar el producto por ID
                  final producto = _productos.firstWhere(
                    (p) => p.id_Producto == productId,
                    orElse: () => Productos(
                      prodDescripcion: 'Desconocido',
                      prodCosto: 0,
                      prodExistencia: 0,
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message:
                            '${producto.prodDescripcion ?? 'Desconocido'}\n'
                            'ID: ${producto.id_Producto ?? 0}\n'
                            'Movimientos: ${section.value.toInt()}\n'
                            'Existencia: ${producto.prodExistencia ?? 0}\n'
                            'Costo: \$${(producto.prodCosto ?? 0).toStringAsFixed(2)}',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: section.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              producto.prodDescripcion?.split(' ').first ??
                                  'Prod',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Función auxiliar para obtener el ID del producto desde la sección del gráfico
  int _getProductIdFromSection(PieChartSectionData section) {
    // Obtenemos los productos ordenados por movimientos
    // ignore: unused_local_variable
    final sortedProducts = _productosMovimientos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Para secciones que no son "Otros"
    if (section.title != 'Otros') {
      try {
        // El título contiene el ID del producto
        final productId = int.tryParse(section.title) ?? 0;
        return productId;
      } catch (e) {
        return 0;
      }
    }

    // Para la sección "Otros"
    return 0;
  }

  double _calculateMaxY(List<BarChartGroupData> barGroups) {
    double maxY = 0;
    for (final group in barGroups) {
      for (final bar in group.barRods) {
        if (bar.toY > maxY) {
          maxY = bar.toY;
        }
      }
    }
    return maxY * 1.2; // Añadir un 20% de espacio extra
  }

  List<BarChartGroupData> _buildMonthlyData() {
    final Map<int, double> entradasPorMes = {};
    final Map<int, double> salidasPorMes = {};

    // Inicializar todos los meses
    for (int i = 1; i <= 12; i++) {
      entradasPorMes[i] = 0;
      salidasPorMes[i] = 0;
    }

    // Contar entradas por mes
    for (final entrada in _entradas) {
      final fecha = _parseDate(entrada.entrada_Fecha ?? '');
      if (fecha != null && fecha.year == _selectedYear) {
        entradasPorMes[fecha.month] = (entradasPorMes[fecha.month] ?? 0) +
            (entrada.entrada_Unidades ?? 0);
      }
    }

    // Contar salidas por mes
    for (final salida in _salidas) {
      final fecha = _parseDate(salida.salida_Fecha ?? '');
      if (fecha != null && fecha.year == _selectedYear) {
        salidasPorMes[fecha.month] =
            (salidasPorMes[fecha.month] ?? 0) + (salida.salida_Unidades ?? 0);
      }
    }

    return List.generate(12, (index) {
      final month = index + 1;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: entradasPorMes[month] ?? 0,
            color: Colors.blue,
            width: 12,
          ),
          BarChartRodData(
            toY: salidasPorMes[month] ?? 0,
            color: Colors.orange,
            width: 12,
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> _buildTopProductsData() {
    final sortedProducts = _productosMovimientos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topProducts = sortedProducts.take(5).toList();
    final otherProducts =
        sortedProducts.skip(5).fold(0.0, (sum, entry) => sum + entry.value);

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.grey,
    ];

    final sections = <PieChartSectionData>[];

    for (int i = 0; i < topProducts.length; i++) {
      final entry = topProducts[i];
      final producto = _productos.firstWhere(
        (p) => p.id_Producto == entry.key,
        orElse: () => Productos(
          id_Producto: entry.key,
          prodDescripcion: 'Producto ${entry.key}',
        ),
      );

      sections.add(
        PieChartSectionData(
          value: entry.value,
          color: colors[i],
          title: '${producto.id_Producto}', // Almacenamos SOLO el ID aquí
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          radius: 80,
          badgeWidget: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
          badgePositionPercentageOffset: 0.98,
        ),
      );
    }

    if (otherProducts > 0) {
      sections.add(
        PieChartSectionData(
          value: otherProducts,
          color: colors.last,
          title: 'Otros',
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          radius: 80,
          badgeWidget: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              otherProducts.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
          badgePositionPercentageOffset: 0.98,
        ),
      );
    }

    return sections;
  }

  Future<List<BarChartGroupData>> _buildProvidersData() async {
    final sortedProviders = _proveedoresRecurrentes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topProviders = sortedProviders.take(5).toList();
    final proveedores = await _proveedoresController.listProveedores();

    return topProviders.map((entry) {
      // ignore: unused_local_variable
      final proveedor = proveedores.firstWhere(
        (p) => p.id_Proveedor == entry.key,
        orElse: () => Proveedores(proveedor_Name: 'Desconocido'),
      );

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Future<List<String>> _buildProviderNames() async {
    final proveedores = await _proveedoresController.listProveedores();
    final sortedProviders = _proveedoresRecurrentes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedProviders.take(5).map((entry) {
      final proveedor = proveedores.firstWhere(
        (p) => p.id_Proveedor == entry.key,
        orElse: () => Proveedores(proveedor_Name: 'Desconocido'),
      );
      return proveedor.proveedor_Name ?? 'Proveedor ${entry.key}';
    }).toList();
  }

  Future<Map<String, dynamic>> _getProvidersChartData() async {
    final chartData = await _buildProvidersData();
    final labels = await _buildProviderNames();
    return {'data': chartData, 'labels': labels};
  }

  Future<List<BarChartGroupData>> _buildJuntasData() async {
    final sortedJuntas = _juntasRecurrentes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topJuntas = sortedJuntas.take(5).toList();
    final juntas = await _juntasController.listJuntas();

    return topJuntas.map((entry) {
      // ignore: unused_local_variable
      final juntaInfo = juntas.firstWhere(
        (j) => j.id_Junta == entry.key,
        orElse: () => Juntas(junta_Name: 'Desconocida'),
      );

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.green,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Future<List<String>> _buildJuntasNames() async {
    final juntas = await _juntasController.listJuntas();
    final sortedJuntas = _juntasRecurrentes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedJuntas.take(5).map((entry) {
      final junta = juntas.firstWhere(
        (j) => j.id_Junta == entry.key,
        orElse: () => Juntas(junta_Name: 'Desconocida'),
      );
      return junta.junta_Name ?? 'Junta ${entry.key}';
    }).toList();
  }

  Future<Map<String, dynamic>> _getJuntasChartData() async {
    final chartData = await _buildJuntasData();
    final labels = await _buildJuntasNames();
    return {'data': chartData, 'labels': labels};
  }

  Widget _buildMonthlyBarChart(
      String title, List<BarChartGroupData> barGroups) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(barGroups),
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM', 'es_ES')
                                  .format(DateTime(0, value.toInt()))
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final monthName = DateFormat('MMMM', 'es_ES')
                            .format(DateTime(0, group.x.toInt()));
                        final tipo = rodIndex == 0 ? 'Entradas' : 'Salidas';
                        return BarTooltipItem(
                          '$monthName\n$tipo: ${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  groupsSpace: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Entradas'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, 'Salidas'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text.toUpperCase(),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
