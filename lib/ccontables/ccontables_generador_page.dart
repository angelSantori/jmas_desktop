import 'package:flutter/material.dart';
import 'package:jmas_desktop/ccontables/excel/entradas_especiales.dart';
import 'package:jmas_desktop/ccontables/excel/entradas_individual.dart';
import 'package:jmas_desktop/ccontables/excel/entradas_rurales.dart';
import 'package:jmas_desktop/ccontables/excel/salida_individual.dart';
import 'package:jmas_desktop/ccontables/excel/salidas_especiales.dart';
import 'package:jmas_desktop/ccontables/excel/salidas_rurales.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'dart:html' as html;

class CcontablesGeneradorPage extends StatefulWidget {
  const CcontablesGeneradorPage({super.key});

  @override
  State<CcontablesGeneradorPage> createState() =>
      _CcontablesGeneradorPageState();
}

class _CcontablesGeneradorPageState extends State<CcontablesGeneradorPage> {
  final JuntasController _juntasController = JuntasController();
  final ProductosController _productosController = ProductosController();
  final CcontablesController _ccontablesController = CcontablesController();
  final EntradasController _entradasController = EntradasController();
  final SalidasController _salidasController = SalidasController();
  final CapturainviniController _capturainviniController =
      CapturainviniController();

  List<Juntas> _juntas = [];
  Juntas? _selectedJunta;
  bool _isGeneratingEntrada = false;

  bool _isGeneratingSalida = false;
  final List<int> _juntasEspeciales = [1, 6, 8, 14];
  bool _isGeneratingEntradasEspeciales = false;
  bool _isGeneratingSalidasEspeciales = false;
  bool _isGeneratingEntradasRurales = false;
  bool _isGeneratingSalidasRurales = false;
  bool _isGeneratingConteo = false;

  int? _selectedMonth;
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

  @override
  void initState() {
    super.initState();
    _loadJuntas();
  }

  Future<void> _loadJuntas() async {
    final juntas = await _juntasController.listJuntas();
    setState(() {
      _juntas = juntas;
    });
  }

  Future<void> _generateConteoInicialExcel() async {
    if (_selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione un mes');
      return;
    }

    setState(() => _isGeneratingConteo = true);

    try {
      final currentYear = DateTime.now().year;
      final result = await _capturainviniController.generateConteoInicialExcel(
        month: _selectedMonth!,
        year: currentYear,
        entradasController: _entradasController,
        salidasController: _salidasController,
        productosController: _productosController,
      );

      final blob = html.Blob(
        [result['bytes']],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', result['fileName'])
        ..click();

      html.Url.revokeObjectUrl(url);

      showOk(context, 'Archivo generado: ${result['fileName']}');
    } catch (e) {
      showError(context, 'Error al generar el archivo: $e');
      print('Error al generar el archivo: $e');
    } finally {
      setState(() => _isGeneratingConteo = false);
    }
  }

  Future<void> _generateExcelEntradasEspeciales() async {
    setState(() => _isGeneratingEntradasEspeciales = true);
    try {
      await ExcelEntradasEspeciales.generateExcelEntradasEspeciales(
          selectedMonth: _selectedMonth,
          juntasEspecialesRecibidas: _juntasEspeciales,
          juntas: _juntas,
          productosController: _productosController,
          entradasController: _entradasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelEntradasEspeciales | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingEntradasEspeciales = false);
    }
  }

  Future<void> _generateExcelSalidasEspeciales() async {
    setState(() => _isGeneratingSalidasEspeciales = true);
    try {
      await ExcelSalidasEspeciales.generateExcelSalidasEspeciales(
          selectedMonth: _selectedMonth,
          juntasEsp: _juntasEspeciales,
          juntas: _juntas,
          productosController: _productosController,
          salidasController: _salidasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelSalidasEspeciales | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingSalidasEspeciales = false);
    }
  }

  // Método para generar Excel de entradas de juntas rurales (todas excepto 1,6,8,14)
  Future<void> _generateExcelEntradasRurales() async {
    setState(() => _isGeneratingEntradasRurales = true);
    try {
      await ExcelEntradasRurales.generateExcelEntradasRurales(
          selectedMonth: _selectedMonth,
          juntasEsp: _juntasEspeciales,
          juntas: _juntas,
          productosController: _productosController,
          entradasController: _entradasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelEntradasRurales | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingEntradasRurales = false);
    }
  }

  // Método para generar Excel de salidas de juntas rurales (todas excepto 1,6,8,14)
  Future<void> _generateExcelSalidasRurales() async {
    setState(() => _isGeneratingSalidasRurales = true);
    try {
      await ExcelSalidasRurales.generateExcelSalidasRurales(
          selectedMonth: _selectedMonth,
          juntasEsp: _juntasEspeciales,
          juntas: _juntas,
          productosController: _productosController,
          salidasController: _salidasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelSalidasRurales | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingSalidasRurales = false);
    }
  }

  Future<void> _generateExcelEntradaIndividual() async {
    if (_selectedJunta == null || _selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione una junta y un mes');
      return;
    }
    setState(() => _isGeneratingEntrada = true);
    try {
      await ExcelEntradasIndividual.generateExcelEntradaIndividual(
          selectedMonth: _selectedMonth,
          selectedJunta: _selectedJunta!,
          productosController: _productosController,
          entradasController: _entradasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelEntradaIndividual | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingEntrada = false);
    }
  }

  // Método para generar Excel de salidas
  Future<void> _generateExcelSalidaIndividual() async {
    if (_selectedJunta == null || _selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione una junta y un mes');
      return;
    }
    setState(() => _isGeneratingSalida = true);
    try {
      await ExcelSalidasIndividual.generateExcelSalidaIndividual(
          selectedMonth: _selectedMonth,
          selectedJunta: _selectedJunta!,
          productosController: _productosController,
          salidasController: _salidasController,
          ccontablesController: _ccontablesController,
          context: context);
    } catch (e) {
      print('_generateExcelSalidaIndividual | ccontablesGenerador: $e');
    } finally {
      setState(() => _isGeneratingSalida = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Pólizas Contables - Trámite #1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Generar reporte de entradas para póliza contable',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  '(Año: ${DateTime.now().year})',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Mes
                Expanded(
                  child: CustomListaDesplegable(
                    value: _selectedMonth != null
                        ? _monthNames[_selectedMonth! - 1]
                        : null,
                    labelText: 'Mes',
                    items: _monthNames,
                    onChanged: (mes) {
                      final newMonth = _monthNames.indexOf(mes!) + 1;
                      setState(() {
                        _selectedMonth = newMonth;
                      });
                    },
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(width: 20),

                // Almacenes
                Expanded(
                  child: CustomListaDesplegableTipo<Juntas>(
                    value: _selectedJunta,
                    labelText: 'Junta',
                    items: _juntas,
                    onChanged: (junta) {
                      setState(() {
                        _selectedJunta = junta;
                      });
                    },
                    itemLabelBuilder: (junta) =>
                        '${junta.junta_Name ?? 'Sin Nombre'} (${junta.id_Junta ?? 'N/A'})',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Entradas individuales
                ElevatedButton(
                  onPressed: _isGeneratingEntrada
                      ? null
                      : _generateExcelEntradaIndividual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: _isGeneratingEntrada
                      ? const CircularProgressIndicator()
                      : const Text('Generar Entradas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          )),
                ),
                const SizedBox(width: 20),

                // Salidas individuales
                ElevatedButton(
                  onPressed: _isGeneratingSalida
                      ? null
                      : _generateExcelSalidaIndividual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingSalida
                      ? const CircularProgressIndicator()
                      : const Text('Generar Salidas',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Reportes consolidados para juntas especiales (Meoqui, Jaquez, Progreso, Lomas del Consuelo)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Entradas juntas especiales
                ElevatedButton(
                  onPressed: _isGeneratingEntradasEspeciales
                      ? null
                      : _generateExcelEntradasEspeciales,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingEntradasEspeciales
                      ? const CircularProgressIndicator()
                      : const Text('Entradas Juntas Especiales',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          )),
                ),
                const SizedBox(width: 20),

                // Salidas juntas especiales
                ElevatedButton(
                  onPressed: _isGeneratingSalidasEspeciales
                      ? null
                      : _generateExcelSalidasEspeciales,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingSalidasEspeciales
                      ? const CircularProgressIndicator()
                      : const Text('Salidas Juntas Especiales',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Reportes consolidados para juntas rurales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Entradas juntas rurales
                ElevatedButton(
                  onPressed: _isGeneratingEntradasRurales
                      ? null
                      : _generateExcelEntradasRurales,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingEntradasRurales
                      ? const CircularProgressIndicator()
                      : const Text('Entradas Juntas Rurales',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          )),
                ),
                const SizedBox(width: 20),
                // Salidas juntas rurales
                ElevatedButton(
                  onPressed: _isGeneratingSalidasRurales
                      ? null
                      : _generateExcelSalidasRurales,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingSalidasRurales
                      ? const CircularProgressIndicator()
                      : const Text('Salidas Juntas Rurales',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _isGeneratingConteo ? null : _generateConteoInicialExcel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: _isGeneratingConteo
                      ? const CircularProgressIndicator()
                      : const Text('Generar Conteo Inicial',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
