import 'package:flutter/material.dart';
import 'package:jmas_desktop/ccontables/widgets_ccontables.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'dart:html' as html;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;

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

  List<Juntas> _juntas = [];
  Juntas? _selectedJunta;
  bool _isGeneratingEntrada = false;

  bool _isGeneratingSalida = false;

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

  Future<void> _generateExcel() async {
    if (_selectedJunta == null || _selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione un almacén y un mes');
      return;
    }

    setState(() => _isGeneratingEntrada = true);

    try {
      // Get all products for the selected almacen
      final productos = await _productosController.listProductos();
      // final productosInAlmacen = productos
      //     .where((p) => p.id_Almacen == _selectedAlmacen!.id_Almacen)
      //     .toList();

      // Get all entradas for the selected month and almacen
      final currentYear = DateTime.now().year;
      //final firstDay = DateTime(currentYear, _selectedMonth!, 1);
      final lastDay = DateTime(currentYear, _selectedMonth! + 1, 0);

      final allEntradas = await _entradasController.listEntradas();
      final entradasInPeriod = allEntradas.where((e) {
        if (e.entrada_Fecha == null ||
            e.id_Junta != _selectedJunta!.id_Junta ||
            e.entrada_Estado != true) {
          return false;
        }

        // Use _parseFecha to handle different date formats
        final entradaDate = parseFecha(e.entrada_Fecha!);
        return entradaDate.year == currentYear &&
            entradaDate.month == _selectedMonth;
      }).toList();

      // Group entradas by product
      final Map<int, List<Entradas>> entradasByProduct = {};
      final Map<int, double> totalCostoByProduct = {};

      for (var entrada in entradasInPeriod) {
        if (entrada.idProducto == null) continue;

        if (!entradasByProduct.containsKey(entrada.idProducto)) {
          entradasByProduct[entrada.idProducto!] = [];
          totalCostoByProduct[entrada.idProducto!] = 0;
        }

        entradasByProduct[entrada.idProducto!]!.add(entrada);
        totalCostoByProduct[entrada.idProducto!] =
            (totalCostoByProduct[entrada.idProducto!] ?? 0) +
                (entrada.entrada_Costo ?? 0) * (entrada.entrada_Unidades ?? 0);
      }

      // Get CC details for each product
      final Map<int, CContables?> ccByProduct = {};
      for (var productId in entradasByProduct.keys) {
        final ccList = await _ccontablesController.listCCxProducto(productId);
        ccByProduct[productId] = ccList.isNotEmpty ? ccList.first : null;
      }

      double totalAbono = 0;
      for (var productId in entradasByProduct.keys) {
        final totalCosto = totalCostoByProduct[productId] ?? 0;
        totalAbono += totalCosto;
      }

      // Create Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Set column widths
      sheet.getRangeByName('A1').columnWidth = 20;
      sheet.getRangeByName('B1').columnWidth = 15;
      sheet.getRangeByName('C1').columnWidth = 15;
      sheet.getRangeByName('D1').columnWidth = 50;
      sheet.getRangeByName('E1').columnWidth = 25;
      sheet.getRangeByName('F1').columnWidth = 25;
      sheet.getRangeByName('G1').columnWidth = 25;

      // Header style
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#000000';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      // Title style
      final Style titleStyle = workbook.styles.add('titleStyle');
      titleStyle.fontName = 'Arial';
      titleStyle.fontSize = 14;
      titleStyle.bold = true;
      titleStyle.hAlign = HAlignType.center;

      // Normal style
      final Style normalStyle = workbook.styles.add('normalStyle');
      normalStyle.fontName = 'Arial';
      normalStyle.fontSize = 11;

      // Bold style
      final Style boldStyle = workbook.styles.add('boldStyle');
      boldStyle.fontName = 'Arial';
      boldStyle.fontSize = 11;
      boldStyle.bold = true;

      // Right align style
      final Style rightAlignStyle = workbook.styles.add('rightAlignStyle');
      rightAlignStyle.fontName = 'Arial';
      rightAlignStyle.fontSize = 11;
      rightAlignStyle.hAlign = HAlignType.right;

      // Gray background style
      final Style grayBgStyle = workbook.styles.add('grayBgStyle');
      grayBgStyle.backColor = '#D3D3D3';
      grayBgStyle.fontName = 'Arial';
      grayBgStyle.fontSize = 11;
      grayBgStyle.bold = true;

      // Gray background normal style (for cells)
      final Style grayBgNormalStyle = workbook.styles.add('grayBgNormalStyle');
      grayBgNormalStyle.backColor = '#D3D3D3';
      grayBgNormalStyle.fontName = 'Arial';
      grayBgNormalStyle.fontSize = 11;

      // Center align style for sumas iguales
      final Style centerAlignStyle = workbook.styles.add('centerAlignStyle');
      centerAlignStyle.fontName = 'Arial';
      centerAlignStyle.fontSize = 11;
      centerAlignStyle.hAlign = HAlignType.center;

      // Header row
      sheet.getRangeByName('A1:G1').merge();
      sheet.getRangeByName('A1').setText(
          'SISTEMA AUTOMATIZADO DE ADMINISTRACIÓN Y CONTABILIDAD GUBERNAMENTAL SAACG.NET');
      sheet.getRangeByName('A1').cellStyle = headerStyle;

      // Date row
      sheet.getRangeByName('A2').setText('FECHA:');
      sheet.getRangeByName('A2').cellStyle = grayBgStyle;
      sheet.getRangeByName('A2').cellStyle.hAlign = HAlignType.right;
      sheet
          .getRangeByName('B2')
          .setText(DateFormat('dd/MM/yyyy').format(DateTime.now()));
      sheet.getRangeByName('B2').cellStyle.hAlign = HAlignType.right;

      // Tipo de Poliza row
      sheet.getRangeByName('A3').setText('TIPO DE POLIZA:');
      sheet.getRangeByName('A3').cellStyle = grayBgStyle;
      sheet.getRangeByName('A3').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B3').setText('D');
      sheet.getRangeByName('B3').cellStyle.hAlign = HAlignType.left;

      // Concepto row
      sheet.getRangeByName('A4').setText('CONCEPTO:');
      sheet.getRangeByName('A4').cellStyle = grayBgStyle;
      sheet.getRangeByName('A4').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'ENTRADAS DE ${_selectedJunta!.junta_Name?.toUpperCase()} DEL 01/${_selectedMonth!.toString().padLeft(2, '0')} AL ${lastDay.day.toString().padLeft(2, '0')}/${_selectedMonth!.toString().padLeft(2, '0')} DE ${getMonthName(_selectedMonth!).toUpperCase()} $currentYear';
      sheet.getRangeByName('B4:D4').merge();
      sheet.getRangeByName('B4').setText(concepto);

      // SUMAS IGUALES
      int sumasIgualesRow = 5;
      sheet.getRangeByName('A$sumasIgualesRow').setText('SUMAS IGUALES');
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle = grayBgStyle;
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.right;

      sheet.getRangeByName('B$sumasIgualesRow').setNumber(totalAbono);
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet.getRangeByName('C$sumasIgualesRow').setNumber(totalAbono);
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      // Add some space
      sheet.getRangeByName('A6').rowHeight = 10;

      // Table headers
      sheet.getRangeByName('A7').setText('Cuenta');
      sheet.getRangeByName('A7').cellStyle = grayBgStyle;
      sheet.getRangeByName('A7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B7').setText('Cargo');
      sheet.getRangeByName('B7').cellStyle = grayBgStyle;
      sheet.getRangeByName('B7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('C7').setText('Abono');
      sheet.getRangeByName('C7').cellStyle = grayBgStyle;
      sheet.getRangeByName('C7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D7').setText('Concepto por Movimiento');
      sheet.getRangeByName('D7').cellStyle = grayBgStyle;
      sheet.getRangeByName('D7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D7:G7').merge();

      // Add data rows
      int currentRow = 8;

      for (var productId in entradasByProduct.keys) {
        final product = productos.firstWhere((p) => p.id_Producto == productId,
            orElse: () => Productos());
        final cc = ccByProduct[productId];
        final totalCosto = totalCostoByProduct[productId] ?? 0;
        totalAbono += totalCosto;

        sheet
            .getRangeByName('A$currentRow')
            .setText(cc?.cC_Detalle?.toString() ?? '0');

        sheet.getRangeByName('B$currentRow').setNumber(0);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('C$currentRow').setNumber(totalCosto);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('D$currentRow:G$currentRow').merge();
        sheet
            .getRangeByName('D$currentRow')
            .setText('${product.prodDescripcion?.toUpperCase()}');

        currentRow++;
      }

      // Save the workbook
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // For web, use download approach
      final String fileName =
          'Poliza_${_selectedJunta!.junta_Name}_${_selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

      // Create a blob and download it
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      showOk(context, 'Archivo generado: $fileName');
    } catch (e) {
      showError(context, 'Error al generar el archivo: $e');
      print('Error al generar el archivo: $e');
    } finally {
      setState(() => _isGeneratingEntrada = false);
    }
  }

  // Método para generar Excel de salidas
  Future<void> _generateExcelSalidas() async {
    if (_selectedJunta == null || _selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione una junta y un mes');
      return;
    }

    setState(() => _isGeneratingSalida = true);

    try {
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, _selectedMonth! + 1, 0);

      // Obtener todas las salidas
      final allSalidas = await _salidasController.listSalidas();
      final salidasInPeriod = allSalidas.where((s) {
        if (s.salida_Fecha == null ||
            s.id_Junta != _selectedJunta!.id_Junta ||
            s.salida_Estado != true) {
          return false;
        }

        final salidaDate = parseFecha(s.salida_Fecha!);
        return salidaDate.year == currentYear &&
            salidaDate.month == _selectedMonth;
      }).toList();

      // Agrupar salidas por producto
      final Map<int, List<Salidas>> salidasByProduct = {};
      final Map<int, double> totalCostoByProduct = {};

      for (var salida in salidasInPeriod) {
        if (salida.idProducto == null) continue;

        if (!salidasByProduct.containsKey(salida.idProducto)) {
          salidasByProduct[salida.idProducto!] = [];
          totalCostoByProduct[salida.idProducto!] = 0;
        }

        salidasByProduct[salida.idProducto!]!.add(salida);
        totalCostoByProduct[salida.idProducto!] =
            (totalCostoByProduct[salida.idProducto!] ?? 0) +
                (salida.salida_Costo ?? 0) * (salida.salida_Unidades ?? 0);
      }

      // Obtener detalles contables para cada producto
      final Map<int, CContables?> ccByProduct = {};
      for (var productId in salidasByProduct.keys) {
        final ccList = await _ccontablesController.listCCxProducto(productId);
        ccByProduct[productId] = ccList.isNotEmpty ? ccList.first : null;
      }

      // Calcular el total de cargos
      double totalCargo = 0;
      for (var productId in salidasByProduct.keys) {
        final totalCosto = totalCostoByProduct[productId] ?? 0;
        totalCargo += totalCosto;
      }

      // Crear libro de Excel
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Set column widths
      sheet.getRangeByName('A1').columnWidth = 20;
      sheet.getRangeByName('B1').columnWidth = 15;
      sheet.getRangeByName('C1').columnWidth = 15;
      sheet.getRangeByName('D1').columnWidth = 50;
      sheet.getRangeByName('E1').columnWidth = 25;
      sheet.getRangeByName('F1').columnWidth = 25;
      sheet.getRangeByName('G1').columnWidth = 25;

      // Header style
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#000000';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      // Title style
      final Style titleStyle = workbook.styles.add('titleStyle');
      titleStyle.fontName = 'Arial';
      titleStyle.fontSize = 14;
      titleStyle.bold = true;
      titleStyle.hAlign = HAlignType.center;

      // Normal style
      final Style normalStyle = workbook.styles.add('normalStyle');
      normalStyle.fontName = 'Arial';
      normalStyle.fontSize = 11;

      // Bold style
      final Style boldStyle = workbook.styles.add('boldStyle');
      boldStyle.fontName = 'Arial';
      boldStyle.fontSize = 11;
      boldStyle.bold = true;

      // Right align style
      final Style rightAlignStyle = workbook.styles.add('rightAlignStyle');
      rightAlignStyle.fontName = 'Arial';
      rightAlignStyle.fontSize = 11;
      rightAlignStyle.hAlign = HAlignType.right;

      // Gray background style
      final Style grayBgStyle = workbook.styles.add('grayBgStyle');
      grayBgStyle.backColor = '#D3D3D3';
      grayBgStyle.fontName = 'Arial';
      grayBgStyle.fontSize = 11;
      grayBgStyle.bold = true;

      // Gray background normal style (for cells)
      final Style grayBgNormalStyle = workbook.styles.add('grayBgNormalStyle');
      grayBgNormalStyle.backColor = '#D3D3D3';
      grayBgNormalStyle.fontName = 'Arial';
      grayBgNormalStyle.fontSize = 11;

      // Center align style for sumas iguales
      final Style centerAlignStyle = workbook.styles.add('centerAlignStyle');
      centerAlignStyle.fontName = 'Arial';
      centerAlignStyle.fontSize = 11;
      centerAlignStyle.hAlign = HAlignType.center;

      // Header row
      sheet.getRangeByName('A1:G1').merge();
      sheet.getRangeByName('A1').setText(
          'SISTEMA AUTOMATIZADO DE ADMINISTRACIÓN Y CONTABILIDAD GUBERNAMENTAL SAACG.NET');
      sheet.getRangeByName('A1').cellStyle = headerStyle;

      // Fecha
      sheet.getRangeByName('A2').setText('FECHA:');
      sheet.getRangeByName('A2').cellStyle = grayBgStyle;
      sheet.getRangeByName('A2').cellStyle.hAlign = HAlignType.right;
      sheet
          .getRangeByName('B2')
          .setText(DateFormat('dd/MM/yyyy').format(DateTime.now()));
      sheet.getRangeByName('B2').cellStyle.hAlign = HAlignType.right;

      // Tipo de Póliza
      sheet.getRangeByName('A3').setText('TIPO DE POLIZA:');
      sheet.getRangeByName('A3').cellStyle = grayBgStyle;
      sheet.getRangeByName('A3').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B3').setText('D');
      sheet.getRangeByName('B3').cellStyle.hAlign = HAlignType.left;

      // Concepto (ahora para salidas)
      sheet.getRangeByName('A4').setText('CONCEPTO:');
      sheet.getRangeByName('A4').cellStyle = grayBgStyle;
      sheet.getRangeByName('A4').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'SALIDAS DE ${_selectedJunta!.junta_Name?.toUpperCase()} DEL 01/${_selectedMonth!.toString().padLeft(2, '0')} AL ${lastDay.day.toString().padLeft(2, '0')}/${_selectedMonth!.toString().padLeft(2, '0')} DE ${getMonthName(_selectedMonth!).toUpperCase()} $currentYear';
      sheet.getRangeByName('B4:D4').merge();
      sheet.getRangeByName('B4').setText(concepto);

      // SUMAS IGUALES
      int sumasIgualesRow = 5;
      sheet.getRangeByName('A$sumasIgualesRow').setText('SUMAS IGUALES');
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle = grayBgStyle;
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.right;

      sheet.getRangeByName('B$sumasIgualesRow').setNumber(totalCargo);
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet.getRangeByName('C$sumasIgualesRow').setNumber(totalCargo);
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      // Espacio
      sheet.getRangeByName('A6').rowHeight = 10;

      // Encabezados de tabla
      sheet.getRangeByName('A7').setText('Cuenta');
      sheet.getRangeByName('A7').cellStyle = grayBgStyle;
      sheet.getRangeByName('A7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B7').setText('Cargo');
      sheet.getRangeByName('B7').cellStyle = grayBgStyle;
      sheet.getRangeByName('B7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('C7').setText('Abono');
      sheet.getRangeByName('C7').cellStyle = grayBgStyle;
      sheet.getRangeByName('C7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D7').setText('Concepto por Movimiento');
      sheet.getRangeByName('D7').cellStyle = grayBgStyle;
      sheet.getRangeByName('D7').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D7:G7').merge();

      // Datos de salidas
      int currentRow = 8;
      final productos = await _productosController.listProductos();

      for (var productId in salidasByProduct.keys) {
        final product = productos.firstWhere((p) => p.id_Producto == productId,
            orElse: () => Productos());
        final cc = ccByProduct[productId];
        final totalCosto = totalCostoByProduct[productId] ?? 0;

        sheet
            .getRangeByName('A$currentRow')
            .setText(cc?.cC_Detalle?.toString() ?? '0');

        // SALIDAS VAN EN CARGO (inverso de entradas)
        sheet.getRangeByName('B$currentRow').setNumber(totalCosto);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('C$currentRow').setNumber(0);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('D$currentRow:G$currentRow').merge();
        sheet
            .getRangeByName('D$currentRow')
            .setText('${product.prodDescripcion?.toUpperCase()}');

        currentRow++;
      }

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Poliza_Salidas_${_selectedJunta!.junta_Name}_${_selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      showOk(context, 'Archivo generado: $fileName');
    } catch (e) {
      showError(context, 'Error al generar el archivo de salidas: $e');
      print('Error al generar el archivo de salidas: $e');
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
                // Entradas
                ElevatedButton(
                  onPressed: _isGeneratingEntrada ? null : _generateExcel,
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

                // Salidas
                ElevatedButton(
                  onPressed: _isGeneratingSalida ? null : _generateExcelSalidas,
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
          ],
        ),
      ),
    );
  }
}
