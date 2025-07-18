import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/ccontables/widgets_ccontables.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelEntradasIndividual {
  static Future<void> generateExcelEntradaIndividual({
    required int? selectedMonth,
    required Juntas selectedJunta,
    required ProductosController productosController,
    required EntradasController entradasController,
    required CcontablesController ccontablesController,
    required BuildContext context,
  }) async {
    try {
      // Get all products for the selected almacen
      final productos = await productosController.listProductos();

      // Get all entradas for the selected month and almacen
      final currentYear = DateTime.now().year;
      //final firstDay = DateTime(currentYear, _selectedMonth!, 1);
      final lastDay = DateTime(currentYear, selectedMonth! + 1, 0);

      final allEntradas = await entradasController.listEntradas();
      final entradasInPeriod = allEntradas.where((e) {
        if (e.entrada_Fecha == null ||
            e.id_Junta != selectedJunta.id_Junta ||
            e.entrada_Estado != true) {
          return false;
        }

        // Use _parseFecha to handle different date formats
        final entradaDate = parseFecha(e.entrada_Fecha!);
        return entradaDate.year == currentYear &&
            entradaDate.month == selectedMonth;
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
                (entrada.entrada_Costo ?? 0);
      }

      // Get CC details for each product
      final Map<int, CContables?> ccByProduct = {};
      for (var productId in entradasByProduct.keys) {
        final ccList = await ccontablesController.listCCxProducto(productId);
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
      sheet.getRangeByName('H1').columnWidth = 25;

      // Estilos
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#244062';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial Black';
      headerStyle.fontSize = 11;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      final Style titleStyle = workbook.styles.add('titleStyle');
      titleStyle.fontName = 'Arial';
      titleStyle.fontSize = 14;
      titleStyle.bold = true;
      titleStyle.hAlign = HAlignType.center;

      final Style normalStyle = workbook.styles.add('normalStyle');
      normalStyle.fontName = 'Arial';
      normalStyle.fontSize = 11;

      final Style grayBgStyle = workbook.styles.add('grayBgStyle');
      grayBgStyle.backColor = '#8DB4E2';
      grayBgStyle.fontName = 'Arial';
      grayBgStyle.fontSize = 9;
      grayBgStyle.bold = true;
      grayBgStyle.borders.all.lineStyle = LineStyle.thin;

      final Style dataStyle = workbook.styles.add('dataStyle');
      dataStyle.fontName = 'Courier';
      dataStyle.fontSize = 10;
      dataStyle.bold = true;

      final Style styleSuma = workbook.styles.add('styleSuma');
      styleSuma.fontName = 'Courier';
      styleSuma.numberFormat = '0.00';
      styleSuma.fontSize = 10;

      final Style styleInfoData = workbook.styles.add('styleInfoData');
      styleInfoData.fontName = 'Arial';
      styleSuma.numberFormat = '0.00';
      styleInfoData.fontSize = 10;

      // Header row
      sheet.getRangeByName('A1:E1').merge();
      sheet.getRangeByName('A1').setText(
          'SISTEMA AUTOMATIZADO DE ADMINISTRACIÓN Y CONTABILIDAD GUBERNAMENTAL SAACG.NET');
      sheet.getRangeByName('A1').cellStyle = headerStyle;

      // Date row
      sheet.getRangeByName('A2').setText('FECHA:');
      sheet.getRangeByName('A2').cellStyle = grayBgStyle;
      sheet.getRangeByName('A2').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B2').setText(
          '${lastDay.day.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')}/$currentYear');
      sheet.getRangeByName('B2').cellStyle = dataStyle;
      sheet.getRangeByName('B2').cellStyle.hAlign = HAlignType.right;

      // Tipo de Poliza row
      sheet.getRangeByName('A3').setText('TIPO DE POLIZA:');
      sheet.getRangeByName('A3').cellStyle = grayBgStyle;
      sheet.getRangeByName('A3').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B3').setText('D');
      sheet.getRangeByName('B3').cellStyle = dataStyle;
      sheet.getRangeByName('B3').cellStyle.hAlign = HAlignType.left;

      // No. Cheque
      sheet.getRangeByName('A4').setText('NO. CHEQUE:');
      sheet.getRangeByName('A4').cellStyle = grayBgStyle;
      sheet.getRangeByName('A4').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B4').setText(''); // Queda en blanco
      sheet.getRangeByName('B4').cellStyle = dataStyle;
      sheet.getRangeByName('B4').cellStyle.hAlign = HAlignType.left;

      // Concepto row
      sheet.getRangeByName('A5').setText('CONCEPTO:');
      sheet.getRangeByName('A5').cellStyle = grayBgStyle;
      sheet.getRangeByName('A5').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'ENTRADAS DE ${selectedJunta.junta_Name?.toUpperCase()} DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
      sheet.getRangeByName('B5:D5').merge();
      sheet.getRangeByName('B5').setText(concepto);
      sheet.getRangeByName('B5').cellStyle = dataStyle;

      // Beneficiario (nuevo campo)
      sheet.getRangeByName('A6').setText('BENEFICIARIO:');
      sheet.getRangeByName('A6').cellStyle = grayBgStyle;
      sheet.getRangeByName('A6').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B6:D6').merge();
      sheet.getRangeByName('B6').setText(''); // Queda en blanco
      sheet.getRangeByName('B6').cellStyle = dataStyle;

      // SUMAS IGUALES
      int sumasIgualesRow = 7;
      sheet.getRangeByName('A$sumasIgualesRow').setText('SUMAS IGUALES');
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle = grayBgStyle;
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.right;

      sheet.getRangeByName('B$sumasIgualesRow').setNumber(totalAbono);
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle = styleSuma;
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet.getRangeByName('C$sumasIgualesRow').setNumber(totalAbono);
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle = styleSuma;
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      // Encabezados de tabla
      sheet.getRangeByName('A8').setText('Cuenta');
      sheet.getRangeByName('A8').cellStyle = grayBgStyle;
      sheet.getRangeByName('A8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B8').setText('Cargo');
      sheet.getRangeByName('B8').cellStyle = grayBgStyle;
      sheet.getRangeByName('B8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('C8').setText('Abono');
      sheet.getRangeByName('C8').cellStyle = grayBgStyle;
      sheet.getRangeByName('C8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D8').setText('Concepto por Movimiento');
      sheet.getRangeByName('D8').cellStyle = grayBgStyle;
      sheet.getRangeByName('D8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('E8').setText('Fuente Financiamiento');
      sheet.getRangeByName('E8').cellStyle = grayBgStyle;
      sheet.getRangeByName('E8').cellStyle.hAlign = HAlignType.center;

      // Add data rows
      int currentRow = 9;

      for (var productId in entradasByProduct.keys) {
        final product = productos.firstWhere((p) => p.id_Producto == productId,
            orElse: () => Productos());
        final cc = ccByProduct[productId];
        final totalCosto = totalCostoByProduct[productId] ?? 0;
        totalAbono += totalCosto;

        sheet
            .getRangeByName('A$currentRow')
            .setText(cc?.cC_Detalle?.toString() ?? '0');
        sheet.getRangeByName('A$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('B$currentRow').setNumber(0);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('C$currentRow').setNumber(totalCosto);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;

        sheet
            .getRangeByName('D$currentRow')
            .setText('${product.prodDescripcion?.toUpperCase()}');
        sheet.getRangeByName('D$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('E$currentRow').setText('149825');
        sheet.getRangeByName('E$currentRow').cellStyle = styleSuma;
        sheet.getRangeByName('E$currentRow').cellStyle.hAlign =
            HAlignType.center;

        currentRow++;
      }

      // Fila final con el resumen
      sheet.getRangeByName('A$currentRow').setText('1151-8-004');
      sheet.getRangeByName('B$currentRow').setNumber(totalAbono);
      sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;
      sheet.getRangeByName('C$currentRow').setText('');
      sheet.getRangeByName('D$currentRow').setText(
          'ENTRADAS DE ${selectedJunta.junta_Name?.toUpperCase()} DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear');
      sheet.getRangeByName('E$currentRow').setText('149825');
      sheet.getRangeByName('E$currentRow').cellStyle.hAlign = HAlignType.center;

      // Save the workbook
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // For web, use download approach
      final String fileName =
          'Entradas_Almacen_${selectedJunta.junta_Name}_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
    }
  }
}
