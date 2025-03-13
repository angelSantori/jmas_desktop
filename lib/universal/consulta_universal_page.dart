import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/consulta_universal_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ConsultaUniversalPage extends StatefulWidget {
  const ConsultaUniversalPage({super.key});

  @override
  State<ConsultaUniversalPage> createState() => _ConsultaUniversalPageState();
}

class _ConsultaUniversalPageState extends State<ConsultaUniversalPage> {
  final TextEditingController _idController = TextEditingController();
  final ConsultasController _consultasController = ConsultasController();
  Future<Map<String, dynamic>>? _movimientosFuture;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _fechaController = TextEditingController();

  void buscarMovimientos() {
    final idProducto = int.tryParse(_idController.text);
    if (idProducto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese un ID válido")),
      );
      return;
    }

    setState(() {
      _movimientosFuture = _consultasController.consultaUniversal(idProducto);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _fechaController.text =
            "${picked.start.toLocal().toString().split(' ')[0]} - ${picked.end.toLocal().toString().split(' ')[0]}";
      });
    }
  }

  DateTime _parseFecha(String fecha) {
    final parts = fecha.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  List<Map<String, dynamic>> _filtrarPorFecha(
      List<Map<String, dynamic>> movimientos) {
    if (_selectedDateRange == null) return movimientos;

    return movimientos.where((movimiento) {
      final fechaString =
          movimiento['entrada_Fecha'] ?? movimiento['salida_Fecha'];
      final fechaMovimiento = _parseFecha(fechaString);
      return fechaMovimiento.isAfter(_selectedDateRange!.start) &&
          fechaMovimiento
              .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
    }).toList();
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextFieldNumero(
                    controller: _idController,
                    labelText: 'ID del Producto',
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 8,
                    shadowColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: buscarMovimientos,
                  child: const Text(
                    "Buscar",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CustomTextFielFecha(
                  controller: _fechaController,
                  labelText: 'Rango de Fechas',
                  onTap: () => _selectDateRange(context),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _fechaController.clear();
                      _selectedDateRange = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _movimientosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error al obtener datos"));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final entradas =
                        List<Map<String, dynamic>>.from(data['entradas'] ?? []);
                    final salidas =
                        List<Map<String, dynamic>>.from(data['salidas'] ?? []);

                    // Aplicar el filtro de fechas
                    final entradasFiltradas = _filtrarPorFecha(entradas);
                    final salidasFiltradas = _filtrarPorFecha(salidas);

                    if (entradasFiltradas.isEmpty && salidasFiltradas.isEmpty) {
                      return const Center(
                          child: Text(
                              "No hay movimientos en el rango seleccionado"));
                    }

                    return ListView(
                      children: [
                        if (entradasFiltradas.isNotEmpty) ...[
                          const Text("Entradas",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          ...entradasFiltradas
                              .map((e) => _buildEntradaCard(e))
                              .toList(),
                        ],
                        if (salidasFiltradas.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Text("Salidas",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          ...salidasFiltradas
                              .map((s) => _buildSalidaCard(s))
                              .toList(),
                        ],
                      ],
                    );
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

  Widget _buildEntradaCard(Map<String, dynamic> entrada) {
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
            Text("Costo: \$${entrada['entrada_Costo']}"),
            Text("Fecha: ${entrada['entrada_Fecha']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildSalidaCard(Map<String, dynamic> salida) {
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
            Text("Costo: \$${salida['salida_Costo']}"),
            Text("Fecha: ${salida['salida_Fecha']}"),
            Text("Tipo de Trabajo: ${salida['salida_TipoTrabajo']}"),
          ],
        ),
      ),
    );
  }
}
