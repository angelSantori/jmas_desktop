import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/consulta_universal_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ConsultaUniversalPage extends StatefulWidget {
  const ConsultaUniversalPage({super.key});

  @override
  State<ConsultaUniversalPage> createState() => _ConsultaUniversalPageState();
}

class _ConsultaUniversalPageState extends State<ConsultaUniversalPage> {
  final TextEditingController _idController = TextEditingController();
  final ConsultasController _consultasController = ConsultasController();
  final CapturainviniController _capturaController = CapturainviniController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final JuntasController _juntasController = JuntasController();

  Future<Map<String, dynamic>>? _movimientosFuture;

  // Variables para los totales
  String? _currentMonthCapture;
  double _totalEntradas = 0;
  double _totalSalidas = 0;
  double _totalCalculado = 0;

  // Variables para filtros
  int? _selectedProveedorId;
  int? _selectedJuntaId;
  List<Proveedores> _proveedoresList = [];
  List<Juntas> _juntasList = [];

  // Variables para filtros de fecha
  int? _selectedMonth;
  int? _selectedYear;
  final List<int> _months = List.generate(12, (index) => index + 1);
  final List<int> _years =
      List.generate(10, (index) => DateTime.now().year - index);

  final List<String> _monthNames = [
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
  final List<String> _yearStrings =
      List.generate(10, (index) => (DateTime.now().year - index).toString());

  @override
  void initState() {
    super.initState();
    _loadProveedores();
    _loadJuntas();
    // Establecer mes y año actual por defecto
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  Future<void> _loadProveedores() async {
    final proveedores = await _proveedoresController.listProveedores();
    if (mounted) {
      setState(() {
        _proveedoresList = proveedores;
      });
    }
  }

  Future<void> _loadJuntas() async {
    final juntas = await _juntasController.listJuntas();
    if (mounted) {
      setState(() {
        _juntasList = juntas;
      });
    }
  }

  void buscarMovimientos() async {
    final idProducto = int.tryParse(_idController.text);
    if (idProducto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese un ID válido")),
      );
      return;
    }

    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione mes y año")),
      );
      return;
    }

    setState(() {
      _currentMonthCapture = 'Cargando...';
      _totalEntradas = 0;
      _totalSalidas = 0;
      _totalCalculado = 0;
    });

    try {
      final data = await _consultasController.consultaUniversal(idProducto);
      await _loadCurrentMonthCapture(idProducto);

      final entradas = List<Map<String, dynamic>>.from(data['entradas'] ?? []);
      final salidas = List<Map<String, dynamic>>.from(data['salidas'] ?? []);

      final entradasFiltradas = _filtrarMovimientos(entradas, true);
      final salidasFiltradas = _filtrarMovimientos(salidas, false);

      // Calcular totales
      _totalEntradas = entradasFiltradas.fold(0,
          (sum, e) => sum + ((e['entrada_Unidades'] as num?)?.toDouble() ?? 0));
      _totalSalidas = salidasFiltradas.fold(0,
          (sum, s) => sum + ((s['salida_Unidades'] as num?)?.toDouble() ?? 0));
      _totalCalculado = (double.tryParse(_currentMonthCapture ?? '0') ?? 0) +
          _totalEntradas -
          _totalSalidas;

      // Actualizar el estado
      if (mounted) {
        setState(() {
          _movimientosFuture = Future.value(data);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentMonthCapture = 'Error';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al buscar: $e")),
      );
    }
  }

  Future<void> _loadCurrentMonthCapture(int idProducto) async {
    if (_selectedMonth == null || _selectedYear == null) return;

    try {
      final capturas = await _capturaController.listCiiXProducto(idProducto);

      // Filtrar capturas del mes y año seleccionado
      int prevMonth = _selectedMonth! - 1;

      final capturasFiltradas = capturas.where((c) {
        if (c.invIniFecha == null) return false;

        final fechaLimpia = c.invIniFecha!.trim();
        final parts = fechaLimpia.split('/');
        if (parts.length != 3) return false;

        final day = parts[0];
        final month = parts[1];
        final year = parts[2];

        return int.parse(month) == prevMonth &&
            int.parse(year) ==
                _selectedYear! % 100; // Comparar solo los últimos 2 dígitos
      }).toList();

      // Ordenar por fecha descendente y tomar la más reciente
      capturasFiltradas.sort((a, b) {
        final fechaA = _parseFecha(a.invIniFecha!.trim());
        final fechaB = _parseFecha(b.invIniFecha!.trim());
        return fechaB.compareTo(fechaA);
      });

      final capturaActual = capturasFiltradas.isNotEmpty
          ? capturasFiltradas.first
          : Capturainvini();

      if (mounted) {
        setState(() {
          _currentMonthCapture =
              capturaActual.invIniConteo?.toStringAsFixed(2) ?? '0.00';
        });
      }

      // Logs para diagnóstico
      print('Id Producto buscado: ${_idController.text}');
      print('Capturas encontradas: ${capturas.length}');
      print('Capturas del mes seleccionado: ${capturasFiltradas.length}');
      if (capturasFiltradas.isNotEmpty) {
        print(
            'Captura seleccionada: ${capturaActual.invIniFecha}, ${capturaActual.invIniConteo}');
      }
    } catch (e) {
      print('Error al cargar captura inicial: $e');
      if (mounted) {
        setState(() {
          _currentMonthCapture = '0.00';
        });
      }
    }
  }

  DateTime _parseFecha(String fecha) {
    try {
      // Limpiar espacios adicionales y normalizar
      fecha = fecha.trim().toLowerCase();

      // Casos especiales con "a. m." o "p. m."
      if (fecha.contains("a. m.") || fecha.contains("p. m.")) {
        return _parseFechaConAMPM(fecha);
      }

      // Separar fecha y hora
      final partes = fecha.split(' ');
      final fechaPart = partes[0];
      final horaPart = partes.length > 1 ? partes[1] : null;

      // Parsear la parte de la fecha
      final dateParts = fechaPart.split('/');
      if (dateParts.length != 3)
        throw FormatException("Formato de fecha inválido");

      int day, month, year;

      // Determinar el formato (DD/MM/YY o MM/DD/YYYY)
      if (dateParts[0].length <= 2 && dateParts[1].length <= 2) {
        // Formato DD/MM/YY o DD/MM/YYYY
        day = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        year = dateParts[2].length == 2
            ? 2000 + int.parse(dateParts[2])
            : int.parse(dateParts[2]);
      } else {
        // Formato MM/DD/YYYY
        month = int.parse(dateParts[0]);
        day = int.parse(dateParts[1]);
        year = int.parse(dateParts[2]);
      }

      // Si no hay hora, retornar solo la fecha
      if (horaPart == null || horaPart.isEmpty) {
        return DateTime(year, month, day);
      }

      // Parsear la hora si existe
      final timeParts = horaPart.split(':');
      if (timeParts.length < 2)
        throw FormatException("Formato de hora inválido");

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      int second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      print('Error al parsear fecha: "$fecha" - $e');
      return DateTime.now(); // Fallback
    }
  }

  DateTime _parseFechaConAMPM(String fecha) {
    // Normalizar el string
    fecha = fecha.replaceAll("a. m.", "am").replaceAll("p. m.", "pm").trim();

    // Separar fecha y hora
    final partes = fecha.split(' ');
    final fechaPart = partes[0];
    final horaPart = partes.length > 1 ? partes[1] : null;
    final ampm = partes.length > 2 ? partes[2] : null;

    // Parsear la fecha
    final dateParts = fechaPart.split('/');
    if (dateParts.length != 3)
      throw FormatException("Formato de fecha inválido");

    int day, month, year;

    // Determinar formato de fecha (DD/MM/YYYY o MM/DD/YYYY)
    if (dateParts[0].length <= 2 && dateParts[1].length <= 2) {
      // Formato DD/MM/YYYY
      day = int.parse(dateParts[0]);
      month = int.parse(dateParts[1]);
      year = int.parse(dateParts[2]);
    } else {
      // Formato MM/DD/YYYY
      month = int.parse(dateParts[0]);
      day = int.parse(dateParts[1]);
      year = int.parse(dateParts[2]);
    }

    // Si no hay hora, retornar solo fecha
    if (horaPart == null || ampm == null) {
      return DateTime(year, month, day);
    }

    // Parsear la hora con AM/PM
    final timeParts = horaPart.split(':');
    if (timeParts.length < 2) throw FormatException("Formato de hora inválido");

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

    // Ajustar hora para formato 24h
    if (ampm == "pm" && hour < 12) {
      hour += 12;
    } else if (ampm == "am" && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute, second);
  }

  List<Map<String, dynamic>> _filtrarMovimientos(
      List<Map<String, dynamic>> movimientos, bool isEntrada) {
    if (_selectedMonth == null || _selectedYear == null) return [];

    // Filtrar por mes y año
    var filtrados = movimientos.where((movimiento) {
      final fechaString =
          isEntrada ? movimiento['entrada_Fecha'] : movimiento['salida_Fecha'];
      if (fechaString == null) return false;

      try {
        final fechaMovimiento = _parseFecha(fechaString);
        return fechaMovimiento.month == _selectedMonth &&
            fechaMovimiento.year == _selectedYear;
      } catch (e) {
        return false;
      }
    }).toList();

    // Filtro por proveedor (solo para entradas)
    if (isEntrada && _selectedProveedorId != null) {
      filtrados = filtrados
          .where((e) => e['id_Proveedor'] == _selectedProveedorId)
          .toList();
    }

    // Filtro por junta
    if (_selectedJuntaId != null) {
      filtrados =
          filtrados.where((m) => m['id_Junta'] == _selectedJuntaId).toList();
    }

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consulta de Movimientos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda y botón
            Row(
              children: [
                //Id del producto
                Expanded(
                  child: CustomTextFieldNumero(
                    controller: _idController,
                    labelText: 'ID del Producto',
                    prefixIcon: Icons.search,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        buscarMovimientos();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),

                //Mes
                Expanded(
                  child: CustomListaDesplegable(
                    value: _selectedMonth != null
                        ? _monthNames[_selectedMonth! - 1]
                        : null,
                    labelText: 'Mes',
                    items: _monthNames,
                    onChanged: (mes) {
                      final newMoth = _monthNames.indexOf(mes!) + 1;
                      setState(() {
                        _selectedMonth = newMoth;
                      });
                      if (_idController.text.isNotEmpty) {
                        buscarMovimientos();
                      }
                    },
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(width: 20),

                //Año
                Expanded(
                  child: CustomListaDesplegable(
                    value: _selectedYear?.toString(),
                    labelText: 'Año',
                    items: _yearStrings,
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = int.parse(value!);
                      });
                      if (_idController.text.isNotEmpty) {
                        buscarMovimientos();
                      }
                    },
                    icon: Icons.calendar_today_sharp,
                  ),
                ),
                const SizedBox(width: 20),

                //Proveedor
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo<Proveedores>(
                          value: _selectedProveedorId != null
                              ? _proveedoresList.firstWhere(
                                  (p) => p.id_Proveedor == _selectedProveedorId,
                                  orElse: () => Proveedores(),
                                )
                              : null,
                          labelText: 'Filtrar por Proveedor',
                          items: _proveedoresList,
                          onChanged: (p) => setState(() {
                            _selectedProveedorId = p?.id_Proveedor;
                          }),
                          itemLabelBuilder: (p) =>
                              '${p.proveedor_Name ?? 'Sin nombre'} (${p.id_Proveedor})',
                          icon: Icons.business,
                        ),
                      ),
                      if (_selectedProveedorId != null)
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => setState(() {
                            _selectedProveedorId = null;
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                //Junta
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomListaDesplegableTipo<Juntas>(
                          value: _selectedJuntaId != null
                              ? _juntasList.firstWhere(
                                  (j) => j.id_Junta == _selectedJuntaId,
                                  orElse: () => Juntas(),
                                )
                              : null,
                          labelText: 'Filtrar por Junta',
                          items: _juntasList,
                          onChanged: (j) => setState(() {
                            _selectedJuntaId = j?.id_Junta;
                          }),
                          itemLabelBuilder: (j) =>
                              '${j.junta_Name ?? 'Sin nombre'} (${j.id_Junta})',
                          icon: Icons.people,
                        ),
                      ),
                      if (_selectedJuntaId != null)
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => setState(() {
                            _selectedJuntaId = null;
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resumen de totales
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTotalItem(
                        'Captura Inicial', _currentMonthCapture ?? '0.00'),
                    _buildTotalItem(
                        'Total Entradas', _totalEntradas.toStringAsFixed(2)),
                    _buildTotalItem(
                        'Total Salidas', _totalSalidas.toStringAsFixed(2)),
                    _buildTotalItem(
                        'Total Calculado', _totalCalculado.toStringAsFixed(2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de movimientos
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _movimientosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final entradas =
                        List<Map<String, dynamic>>.from(data['entradas'] ?? []);
                    final salidas =
                        List<Map<String, dynamic>>.from(data['salidas'] ?? []);

                    final entradasFiltradas =
                        _filtrarMovimientos(entradas, true);
                    final salidasFiltradas =
                        _filtrarMovimientos(salidas, false);

                    return _buildMovimientosList(
                        entradasFiltradas, salidasFiltradas);
                  } else {
                    return const Center(
                        child: Text("Ingrese un ID para buscar"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  Widget _buildTotalItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEntradaCard(Map<String, dynamic> entrada) {
    final costo = (entrada['entrada_Costo'] as num?)?.toDouble();
    final costoFormatted = costo?.toStringAsFixed(2) ?? '0.00';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 4,
      color: const Color.fromARGB(255, 201, 230, 242),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("Folio: ${entrada['entrada_CodFolio']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Referencia: ${entrada['entrada_Referencia']}"),
            Text("Unidades: ${entrada['entrada_Unidades']}"),
            Text("Costo: \$$costoFormatted"),
            Text("Fecha: ${entrada['entrada_Fecha']}"),
            if (entrada['id_Proveedor'] != null)
              Text("Proveedor ID: ${entrada['id_Proveedor']}"),
            if (entrada['id_Junta'] != null)
              Text("Junta ID: ${entrada['id_Junta']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildSalidaCard(Map<String, dynamic> salida) {
    final costo = (salida['salida_Costo'] as num?)?.toDouble();
    final costoFormatted = costo?.toStringAsFixed(2) ?? '0.00';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 4,
      color: const Color.fromARGB(255, 235, 127, 127),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text("Folio: ${salida['salida_CodFolio']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Referencia: ${salida['salida_Referencia']}"),
            Text("Unidades: ${salida['salida_Unidades']}"),
            Text("Costo: \$$costoFormatted"),
            Text("Fecha: ${salida['salida_Fecha']}"),
            Text(
                "Tipo de Trabajo: ${salida['salida_TipoTrabajo'] ?? 'No asignado'}"),
            if (salida['id_Junta'] != null)
              Text("Junta ID: ${salida['id_Junta']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientosList(
      List<Map<String, dynamic>> entradas, List<Map<String, dynamic>> salidas) {
    if (entradas.isEmpty && salidas.isEmpty) {
      return const Center(
          child: Text("No hay movimientos en el mes seleccionado"));
    }

    return ListView(
      children: [
        if (entradas.isNotEmpty) ...[
          const Text("Entradas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...entradas.map((e) => _buildEntradaCard(e)).toList(),
        ],
        if (salidas.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text("Salidas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          ...salidas.map((s) => _buildSalidaCard(s)).toList(),
        ],
      ],
    );
  }
}
