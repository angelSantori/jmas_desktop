import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' as html;

Future<void> excelValidarCaptura({
  required List<Map<String, dynamic>> data,
  required BuildContext context,
}) async {
  try {
    // Crear un nuevo libro de Excel
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Configuración de columnas
    sheet.getRangeByName('A1').columnWidth = 15; // IdProducto
    sheet.getRangeByName('B1').columnWidth = 40; // Descripción
    sheet.getRangeByName('C1').columnWidth = 20; // Existencia Sistema
    sheet.getRangeByName('D1').columnWidth = 20; // Conteo Capturado
    sheet.getRangeByName('E1').columnWidth = 20; // Diferencia
    sheet.getRangeByName('F1').columnWidth = 30; // Justificación

    // Estilos
    final Style headerStyle = workbook.styles.add('headerStyle');
    headerStyle.backColor = '#244062';
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.fontName = 'Arial Black';
    headerStyle.fontSize = 11;
    headerStyle.bold = true;
    headerStyle.hAlign = HAlignType.center;
    headerStyle.vAlign = VAlignType.center;

    final Style normalStyle = workbook.styles.add('normalStyle');
    normalStyle.fontName = 'Arial';
    normalStyle.fontSize = 11;

    final Style highlightStyle = workbook.styles.add('highlightStyle');
    highlightStyle.backColor = '#FFFF00'; // Amarillo
    highlightStyle.fontName = 'Arial';
    highlightStyle.fontSize = 11;

    // Encabezados
    sheet.getRangeByName('A1').setText('IdProducto');
    sheet.getRangeByName('A1').cellStyle = headerStyle;
    sheet.getRangeByName('B1').setText('Descripción');
    sheet.getRangeByName('B1').cellStyle = headerStyle;
    sheet.getRangeByName('C1').setText('Existencia Sistema');
    sheet.getRangeByName('C1').cellStyle = headerStyle;
    sheet.getRangeByName('D1').setText('Conteo Capturado');
    sheet.getRangeByName('D1').cellStyle = headerStyle;
    sheet.getRangeByName('E1').setText('Diferencia');
    sheet.getRangeByName('E1').cellStyle = headerStyle;
    sheet.getRangeByName('F1').setText('Justificación');
    sheet.getRangeByName('F1').cellStyle = headerStyle;

    // Añadir datos
    for (var i = 0; i < data.length; i++) {
      final rowData = data[i];
      final rowIndex = i + 2; // +2 porque la fila 1 es el encabezado

      // Determinar el estilo basado en si hay justificación
      final cellStyle = (rowData['Justificación'] as String).isNotEmpty
          ? highlightStyle
          : normalStyle;

      sheet
          .getRangeByName('A$rowIndex')
          .setNumber(rowData['IdProducto'] as double);
      sheet.getRangeByName('A$rowIndex').cellStyle = cellStyle;

      sheet
          .getRangeByName('B$rowIndex')
          .setText(rowData['Descripción'] as String);
      sheet.getRangeByName('B$rowIndex').cellStyle = cellStyle;

      sheet
          .getRangeByName('C$rowIndex')
          .setNumber((rowData['Existencia Sistema'] as num).toDouble());
      sheet.getRangeByName('C$rowIndex').cellStyle = cellStyle;
      sheet.getRangeByName('C$rowIndex').numberFormat = '0.00';

      sheet
          .getRangeByName('D$rowIndex')
          .setNumber((rowData['Conteo Capturado'] as num).toDouble());
      sheet.getRangeByName('D$rowIndex').cellStyle = cellStyle;
      sheet.getRangeByName('D$rowIndex').numberFormat = '0.00';

      sheet
          .getRangeByName('E$rowIndex')
          .setNumber((rowData['Diferencia'] as num).toDouble());
      sheet.getRangeByName('E$rowIndex').cellStyle = cellStyle;
      sheet.getRangeByName('E$rowIndex').numberFormat = '0.00';

      sheet
          .getRangeByName('F$rowIndex')
          .setText(rowData['Justificación'] as String);
      sheet.getRangeByName('F$rowIndex').cellStyle = cellStyle;
    }

    // Guardar y descargar
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String fileName =
        'Capturas_Pendientes_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
    showError(context, 'Error al generar el archivo');
    print('Error al generar el archivo: $e');
  }
}
