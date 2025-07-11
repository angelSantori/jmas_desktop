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

      // Estilos
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#000000';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      final Style grayBgStyle = workbook.styles.add('grayBgStyle');
      grayBgStyle.backColor = '#D3D3D3';
      grayBgStyle.fontName = 'Arial';
      grayBgStyle.fontSize = 11;
      grayBgStyle.bold = true;

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

      // Tipo de Poliza
      sheet.getRangeByName('A3').setText('TIPO DE POLIZA:');
      sheet.getRangeByName('A3').cellStyle = grayBgStyle;
      sheet.getRangeByName('A3').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B3').setText('D');
      sheet.getRangeByName('B3').cellStyle.hAlign = HAlignType.left;

      // Concepto (modificado para juntas rurales)
      sheet.getRangeByName('A4').setText('CONCEPTO:');
      sheet.getRangeByName('A4').cellStyle = grayBgStyle;
      sheet.getRangeByName('A4').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'ENTRADAS DE JUNTAS RURALES DEL 01/${selectedMonth.toString().padLeft(2, '0')} AL ${lastDay.day.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
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

      // Datos - ahora agrupados por junta
      int currentRow = 8;

      for (var juntaId in entradasByJunta.keys) {
        final junta = juntasRurales.firstWhere((j) => j.id_Junta == juntaId,
            orElse: () => Juntas());
        final totalCosto = totalCostoByJunta[juntaId] ?? 0;

        // Usar junta_Cuenta en lugar de cuenta de producto
        sheet
            .getRangeByName('A$currentRow')
            .setText(junta.junta_Cuenta?.toString() ?? '0');

        sheet.getRangeByName('B$currentRow').setNumber(0);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('C$currentRow').setNumber(totalCosto);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;

        sheet.getRangeByName('D$currentRow:G$currentRow').merge();
        // Mostrar nombre de la junta en lugar de producto
        sheet
            .getRangeByName('D$currentRow')
            .setText('${junta.junta_Name?.toUpperCase()}');

        currentRow++;
      }

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Poliza_Entradas_Juntas_Rurales_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
