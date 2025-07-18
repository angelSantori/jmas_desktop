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

class ExcelEntradasRurales {
  static Future<void> generateExcelEntradasRurales({
    required int? selectedMonth,
    required List<int> juntasEsp,
    required List<Juntas> juntas,
    required ProductosController productosController,
    required EntradasController entradasController,
    required CcontablesController ccontablesController,
    required BuildContext context,
  }) async {
    if (selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione un mes');
      return;
    }

    try {
      // Obtener todas las juntas rurales (todas excepto las especiales)
      final juntasRurales =
          juntas.where((j) => !juntasEsp.contains(j.id_Junta)).toList();
      if (juntasRurales.isEmpty) {
        showAdvertence(context, 'No se encontraron juntas rurales');
        return;
      }

      // Obtener entradas para todas las juntas rurales en el mes seleccionado
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, selectedMonth + 1, 0);

      final allEntradas = await entradasController.listEntradas();

      // Filtrar entradas para juntas rurales en el periodo seleccionado
      final entradasInPeriod = allEntradas.where((e) {
        if (e.entrada_Fecha == null ||
            e.entrada_Estado != true ||
            e.id_Junta == null) {
          return false;
        }

        if (juntasEsp.contains(e.id_Junta)) {
          return false;
        }

        final entradaDate = parseFecha(e.entrada_Fecha!);
        return entradaDate.year == currentYear &&
            entradaDate.month == selectedMonth;
      }).toList();

      // Agrupar entradas por junta (en lugar de por producto)
      final Map<int, List<Entradas>> entradasByJunta = {};
      final Map<int, double> totalCostoByJunta = {};

      for (var entrada in entradasInPeriod) {
        if (entrada.id_Junta == null) continue;

        if (!entradasByJunta.containsKey(entrada.id_Junta)) {
          entradasByJunta[entrada.id_Junta!] = [];
          totalCostoByJunta[entrada.id_Junta!] = 0;
        }

        entradasByJunta[entrada.id_Junta!]!.add(entrada);
        totalCostoByJunta[entrada.id_Junta!] =
            (totalCostoByJunta[entrada.id_Junta!] ?? 0) +
                (entrada.entrada_Costo ?? 0);
      }

      double totalAbono = 0;
      for (var juntaId in entradasByJunta.keys) {
        final totalCosto = totalCostoByJunta[juntaId] ?? 0;
        totalAbono += totalCosto;
      }

      // Crear Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Configuración de columnas y estilos
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
      styleSuma.fontSize = 10;
      styleSuma.numberFormat = '0.00';

      final Style styleInfoData = workbook.styles.add('styleInfoData');
      styleInfoData.fontName = 'Arial';
      styleInfoData.fontSize = 10;
      styleSuma.numberFormat = '0.00';

      // Header row
      sheet.getRangeByName('A1:E1').merge();
      sheet.getRangeByName('A1').setText(
          'SISTEMA AUTOMATIZADO DE ADMINISTRACIÓN Y CONTABILIDAD GUBERNAMENTAL SAACG.NET');
      sheet.getRangeByName('A1').cellStyle = headerStyle;

      // Fecha
      sheet.getRangeByName('A2').setText('FECHA:');
      sheet.getRangeByName('A2').cellStyle = grayBgStyle;
      sheet.getRangeByName('A2').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B2').setText(
          '${lastDay.day.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')}/$currentYear');
      sheet.getRangeByName('B2').cellStyle = dataStyle;
      sheet.getRangeByName('B2').cellStyle.hAlign = HAlignType.right;

      // Tipo de Poliza
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

      // Concepto (modificado para juntas rurales)
      sheet.getRangeByName('A5').setText('CONCEPTO:');
      sheet.getRangeByName('A5').cellStyle = grayBgStyle;
      sheet.getRangeByName('A5').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'ENTRADAS DE ALMACÉN RURALES DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
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

      // Datos - ahora agrupados por junta
      int currentRow = 9;

      for (var juntaId in entradasByJunta.keys) {
        final junta = juntasRurales.firstWhere((j) => j.id_Junta == juntaId,
            orElse: () => Juntas());
        final totalCosto = totalCostoByJunta[juntaId] ?? 0;

        // Usar junta_Cuenta en lugar de cuenta de producto
        sheet
            .getRangeByName('A$currentRow')
            .setText(junta.junta_Cuenta?.toString() ?? '0');
        sheet.getRangeByName('A$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('B$currentRow').setNumber(0);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('C$currentRow').setNumber(totalCosto);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('D$currentRow:G$currentRow').merge();
        sheet
            .getRangeByName('D$currentRow')
            .setText('${junta.junta_Name?.toUpperCase()}');
        sheet.getRangeByName('D$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('E$currentRow').setText('149825');
        sheet.getRangeByName('E$currentRow').cellStyle = styleSuma;
        sheet.getRangeByName('E$currentRow').cellStyle.hAlign =
            HAlignType.center;

        currentRow++;
      }

      // Fila final con el resumen
      sheet.getRangeByName('A$currentRow').setText('');
      sheet.getRangeByName('B$currentRow').setNumber(totalAbono);
      sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;
      sheet.getRangeByName('C$currentRow').setText('');
      sheet.getRangeByName('D$currentRow').setText(
          'ENTRADAS DE ALMACÉN RURALES DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear');
      sheet.getRangeByName('E$currentRow').setText('149825');
      sheet.getRangeByName('E$currentRow').cellStyle.hAlign = HAlignType.center;

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Entradas_Almacen_Juntas_Rurales_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
