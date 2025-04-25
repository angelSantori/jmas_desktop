import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:jmas_desktop/contollers/productos_controller.dart';

class ExcelService {
  static Future<void> exportProductosToExcel({
    required List<Productos> productos,
    required String fileName,
  }) async {
    try {
      // 1. Crear el Excel sin la hoja por defecto
      final excel = Excel.createExcel();

      // 2. Eliminar todas las hojas existentes primero
      final sheetNames = excel.tables.keys.toList();
      for (var sheetName in sheetNames) {
        excel.delete(sheetName);
      }

      // 3. Crear la hoja con el nombre deseado
      final sheet = excel[fileName];

      // 4. Configurar encabezados
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.yellow,
      );

      final headers = [
        'ID',
        'Descripción',
        'Existencia',
        'Mínimo',
        'Máximo',
        'Costo',
        'Precio',
        'Ubicación',
        'Unidad Medida',
        'Proveedor ID'
      ];

      // 5. Añadir encabezados
      for (int col = 0; col < headers.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          ..value = TextCellValue(headers[col])
          ..cellStyle = headerStyle;
      }

      // 6. Llenar con datos
      for (final producto in productos) {
        sheet.appendRow([
          IntCellValue(producto.id_Producto ?? 0),
          TextCellValue(producto.prodDescripcion ?? ''),
          DoubleCellValue(producto.prodExistencia ?? 0),
          DoubleCellValue(producto.prodMin ?? 0),
          DoubleCellValue(producto.prodMax ?? 0),
          DoubleCellValue(producto.prodCosto ?? 0),
          DoubleCellValue(producto.prodPrecio ?? 0),
          TextCellValue(producto.prodUbFisica ?? ''),
          TextCellValue(
              '${producto.prodUMedEntrada ?? ''}/${producto.prodUMedSalida ?? ''}'),
          IntCellValue(producto.idProveedor ?? 0),
        ]);
      }

      // 7. Generar nombre del archivo
      final fechaHora = DateFormat('ddMMyyyy_HHmmss').format(DateTime.now());
      final nombreArchivo = '${fileName}_$fechaHora.xlsx';

      // 8. Descargar el archivo
      final bytes = excel.encode();
      if (bytes != null) {
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', nombreArchivo)
          ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();

        // Limpieza después de 1 segundo para asegurar la descarga
        Future.delayed(const Duration(seconds: 1), () {
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        });
      }
    } catch (e) {
      print('Error al exportar Excel: $e');
      rethrow;
    }
  }
}
