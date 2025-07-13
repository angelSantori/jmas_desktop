import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelEntradasMes {
  static Future<void> generateExcelEntradasMes({
    DateTime? selectedMonth,
    required List<Entradas> filteredEntradas,
    required BuildContext context,
  }) async {
    try {
      // Crear el archivo Excel
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Configuración de columnas
      sheet.getRangeByName('A1').columnWidth = 20;
      sheet.getRangeByName('B1').columnWidth = 30;
      sheet.getRangeByName('C1').columnWidth = 15;
      sheet.getRangeByName('D1').columnWidth = 15;
      sheet.getRangeByName('E1').columnWidth = 20;
      sheet.getRangeByName('F1').columnWidth = 20;
      sheet.getRangeByName('G1').columnWidth = 20;
      sheet.getRangeByName('H1').columnWidth = 20;
      sheet.getRangeByName('I1').columnWidth = 20;
      sheet.getRangeByName('J1').columnWidth = 20;

      // Estilos
      final Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#000000';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.fontName = 'Arial';
      headerStyle.fontSize = 12;
      headerStyle.bold = true;
      headerStyle.hAlign = HAlignType.center;
      headerStyle.vAlign = VAlignType.center;

      final Style normalStyle = workbook.styles.add('normalStyle');
      normalStyle.fontName = 'Arial';
      normalStyle.fontSize = 11;

      // Título
      sheet.getRangeByName('A1:J1').merge();
      sheet.getRangeByName('A1').setText('REPORTE DE ENTRADAS');
      sheet.getRangeByName('A1').cellStyle = headerStyle;

      // Fecha del reporte
      sheet.getRangeByName('A2').setText('Fecha de generación:');
      sheet
          .getRangeByName('B2')
          .setText(DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

      // Periodo
      sheet.getRangeByName('A3').setText('Periodo:');
      final monthName = DateFormat('MMMM', 'es_ES').format(selectedMonth!);
      sheet.getRangeByName('B3').setText(
          '${selectedMonth.year} - ${monthName[0].toUpperCase()}${monthName.substring(1)}');

      // Encabezados de columnas - SOLUCIÓN PARA PRIMER ERROR
      final List<String> headers = [
        'Folio',
        'Referencia',
        'Estado',
        'Unidades',
        'Costo',
        'Fecha',
        'ID Producto',
        'ID Almacén',
        'ID Proveedor',
        'ID Junta'
      ];

      // Escribir encabezados uno por uno
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(5, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(5, i + 1).cellStyle = headerStyle;
      }

      // Datos
      int rowIndex = 6;
      for (var entrada in filteredEntradas) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText(entrada.entrada_CodFolio ?? '');
        sheet
            .getRangeByIndex(rowIndex, 2)
            .setText(entrada.entrada_Referencia ?? '');
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setText(entrada.entrada_Estado ?? false ? 'Activo' : 'Inactivo');
        sheet
            .getRangeByIndex(rowIndex, 4)
            .setNumber(entrada.entrada_Unidades ?? 0);
        sheet
            .getRangeByIndex(rowIndex, 5)
            .setNumber(entrada.entrada_Costo ?? 0);
        sheet.getRangeByIndex(rowIndex, 6).setText(entrada.entrada_Fecha ?? '');

        // SOLUCIÓN PARA SEGUNDO ERROR - Convertir int a double
        sheet
            .getRangeByIndex(rowIndex, 7)
            .setNumber((entrada.idProducto ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 8)
            .setNumber((entrada.id_Almacen ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 9)
            .setNumber((entrada.id_Proveedor ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 10)
            .setNumber((entrada.id_Junta ?? 0).toDouble());

        rowIndex++;
      }

      // Totales
      final double totalUnidades = filteredEntradas.fold(
          0, (sum, item) => sum + (item.entrada_Unidades ?? 0));
      final double totalCosto = filteredEntradas.fold(
          0, (sum, item) => sum + (item.entrada_Costo ?? 0));

      sheet.getRangeByIndex(rowIndex, 3).setText('TOTALES:');
      sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 4).setNumber(totalUnidades);
      sheet.getRangeByIndex(rowIndex, 5).setNumber(totalCosto);

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Entradas_${selectedMonth.month}_${selectedMonth.year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
      showError(context, 'Error al generar el archivo Excel');
      print('Error al generar Excel: $e');
    }
  }
}
