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
          'ENTRADAS DE ${selectedJunta.junta_Name?.toUpperCase()} DEL 01/${selectedMonth.toString().padLeft(2, '0')} AL ${lastDay.day.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
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
          'Poliza_${selectedJunta.junta_Name}_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
