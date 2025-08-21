import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelSalidasMes {
  // Lista de IDs de juntas especiales
  static final List<int> _juntasEspeciales = [1, 6, 8, 14];

  // Nuevo método para generar Excel de juntas especiales
  static Future<void> generateExcelJuntasEspeciales({
    DateTime? selectedMonth,
    required List<Salidas> allSalidas,
    required BuildContext context,
    required ProductosController productosController,
  }) async {
    try {
      // Filtrar salidas: solo juntas especiales, activas y del mes seleccionado
      final filteredSalidas = allSalidas.where((salida) {
        if (!_juntasEspeciales.contains(salida.id_Junta)) return false;
        if (!(salida.salida_Estado ?? false)) return false;

        // Si no hay mes seleccionado, no filtrar por fecha
        if (selectedMonth == null) return true;

        // Filtrar por mes
        try {
          if (salida.salida_Fecha == null) return false;
          final fecha =
              DateFormat('dd/MM/yyyy HH:mm:ss').parse(salida.salida_Fecha!);
          return fecha.month == selectedMonth.month &&
              fecha.year == selectedMonth.year;
        } catch (e) {
          return false;
        }
      }).toList();

      if (filteredSalidas.isEmpty) {
        showAdvertence(context,
            'No hay salidas activas de juntas especiales para el periodo seleccionado');
        return;
      }

      await _generateExcelReport(
          context: context,
          filteredSalidas: filteredSalidas,
          reportType: 'JUNTAS_ESPECIALES',
          selectedMonth: selectedMonth,
          productosController: productosController);
    } catch (e) {
      showError(
          context, 'Error al generar el archivo Excel de juntas especiales');
      print('Error al generar Excel Juntas Especiales: $e');
    }
  }

  // Método para generar Excel de juntas regulares con filtrado por mes
  static Future<void> generateExcelJuntasRurales({
    DateTime? selectedMonth,
    required List<Salidas> allSalidas,
    required BuildContext context,
    required ProductosController productosController,
  }) async {
    try {
      // Filtrar salidas: juntas no especiales, activas y del mes seleccionado
      final filteredSalidas = allSalidas.where((salida) {
        if (_juntasEspeciales.contains(salida.id_Junta)) return false;
        if (!(salida.salida_Estado ?? false)) return false;

        // Si no hay mes seleccionado, no filtrar por fecha
        if (selectedMonth == null) return true;

        // Filtrar por mes
        try {
          if (salida.salida_Fecha == null) return false;
          final fecha =
              DateFormat('dd/MM/yyyy HH:mm:ss').parse(salida.salida_Fecha!);
          return fecha.month == selectedMonth.month &&
              fecha.year == selectedMonth.year;
        } catch (e) {
          return false;
        }
      }).toList();

      if (filteredSalidas.isEmpty) {
        showAdvertence(context,
            'No hay salidas activas de juntas regulares para el periodo seleccionado');
        return;
      }

      await _generateExcelReport(
        context: context,
        filteredSalidas: filteredSalidas,
        reportType: 'JUNTAS_RURALES',
        selectedMonth: selectedMonth,
        productosController: productosController,
      );
    } catch (e) {
      showError(context, 'Error al generar el archivo Excel de juntas rurales');
      print('Error al generar Excel Juntas Rurales: $e');
    }
  }

  // Método privado para generar el reporte (compartido por ambos tipos)
  static Future<void> _generateExcelReport({
    required BuildContext context,
    required List<Salidas> filteredSalidas,
    required String reportType,
    DateTime? selectedMonth,
    required ProductosController productosController,
  }) async {
    final allProductos = await productosController.listProductos();

    // Filtrar salidas para excluir productos de tipo "Servicio"
    final filteredSalidasSinServicios = filteredSalidas.where((salida) {
      final producto = allProductos.firstWhere(
        (prod) => prod.id_Producto == salida.idProducto,
        orElse: () => Productos(
          id_Producto: 0,
          prodUMedEntrada: '',
          prodUMedSalida: '',
        ),
      );

      return producto.prodUMedEntrada?.toLowerCase() != 'servicio' &&
          producto.prodUMedSalida?.toLowerCase() != 'servicio';
    }).toList();

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

    // Título según el tipo de reporte
    final title = reportType == 'JUNTAS_ESPECIALES'
        ? 'REPORTE DE SALIDAS - JUNTAS ESPECIALES'
        : 'REPORTE DE SALIDAS - JUNTAS RURALES';

    sheet.getRangeByName('A1:J1').merge();
    sheet.getRangeByName('A1').setText(title);
    sheet.getRangeByName('A1').cellStyle = headerStyle;

    // Fecha del reporte
    sheet.getRangeByName('A2').setText('Fecha de generación:');
    sheet
        .getRangeByName('B2')
        .setText(DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

    // Periodo (si hay mes seleccionado)
    if (selectedMonth != null) {
      sheet.getRangeByName('A3').setText('Periodo:');
      final monthName = DateFormat('MMMM', 'es_ES').format(selectedMonth);
      sheet.getRangeByName('B3').setText(
          '${selectedMonth.year} - ${monthName[0].toUpperCase()}${monthName.substring(1)}');
    }

    // Encabezados de columnas
    final List<String> headers = [
      'Folio',
      'Referencia',
      'Estado',
      'Unidades',
      'Costo',
      'Fecha',
      'ID Producto',
      'ID Almacén',
      'ID Padron',
      'ID Junta'
    ];

    // Escribir encabezados
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(4, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(4, i + 1).cellStyle = headerStyle;
    }

    // Datos
    int rowIndex = 5;
    for (var salida in filteredSalidasSinServicios) {
      sheet.getRangeByIndex(rowIndex, 1).setText(salida.salida_CodFolio ?? '');
      sheet
          .getRangeByIndex(rowIndex, 2)
          .setText(salida.salida_Referencia ?? '');
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setText(salida.salida_Estado ?? false ? 'Activo' : 'Inactivo');
      sheet.getRangeByIndex(rowIndex, 4).setNumber(salida.salida_Unidades ?? 0);
      sheet.getRangeByIndex(rowIndex, 5).setNumber(salida.salida_Costo ?? 0);
      sheet.getRangeByIndex(rowIndex, 6).setText(salida.salida_Fecha ?? '');

      // Convertir int a double
      sheet
          .getRangeByIndex(rowIndex, 7)
          .setNumber((salida.idProducto ?? 0).toDouble());
      sheet
          .getRangeByIndex(rowIndex, 8)
          .setNumber((salida.id_Almacen ?? 0).toDouble());
      sheet
          .getRangeByIndex(rowIndex, 9)
          .setNumber((salida.idPadron ?? 0).toDouble());
      sheet
          .getRangeByIndex(rowIndex, 10)
          .setNumber((salida.id_Junta ?? 0).toDouble());

      rowIndex++;
    }

    // Totales
    final double totalUnidades = filteredSalidasSinServicios.fold(
        0, (sum, item) => sum + (item.salida_Unidades ?? 0));
    final double totalCosto = filteredSalidasSinServicios.fold(
        0, (sum, item) => sum + (item.salida_Costo ?? 0));

    sheet.getRangeByIndex(rowIndex, 3).setText('TOTALES:');
    sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 4).setNumber(totalUnidades);
    sheet.getRangeByIndex(rowIndex, 5).setNumber(totalCosto);

    // Guardar y descargar
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String fileName =
        '${reportType == 'JUNTAS_ESPECIALES' ? 'Salidas_Juntas_Especiales' : 'Salidas_Juntas_Rurales'}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

    final blob = html.Blob([bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);

    showOk(context, 'Archivo generado: $fileName');
  }

  static Future<void> generateExcelSalidasMes({
    DateTime? selectedMonth,
    required List<Salidas> filteredSalidas,
    required BuildContext context,
  }) async {
    try {
      // Filtrar salidas por mes si está seleccionado
      final salidasFiltradas = selectedMonth != null
          ? filteredSalidas.where((salida) {
              if (salida.salida_Fecha == null) return false;
              try {
                final fecha = DateFormat('dd/MM/yyyy HH:mm:ss')
                    .parse(salida.salida_Fecha!);
                return fecha.month == selectedMonth.month &&
                    fecha.year == selectedMonth.year;
              } catch (e) {
                return false;
              }
            }).toList()
          : filteredSalidas;

      if (salidasFiltradas.isEmpty) {
        showAdvertence(context, 'No hay salidas para el periodo seleccionado');
        return;
      }
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
      sheet.getRangeByName('A1').setText('REPORTE DE SALIDAS');
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
        'ID Padron',
        'ID Junta'
      ];

      // Escribir encabezados uno por uno
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(5, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(5, i + 1).cellStyle = headerStyle;
      }

      // Datos
      int rowIndex = 6;
      for (var salida in salidasFiltradas) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText(salida.salida_CodFolio ?? '');
        sheet
            .getRangeByIndex(rowIndex, 2)
            .setText(salida.salida_Referencia ?? '');
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setText(salida.salida_Estado ?? false ? 'Activo' : 'Inactivo');
        sheet
            .getRangeByIndex(rowIndex, 4)
            .setNumber(salida.salida_Unidades ?? 0);
        sheet.getRangeByIndex(rowIndex, 5).setNumber(salida.salida_Costo ?? 0);
        sheet.getRangeByIndex(rowIndex, 6).setText(salida.salida_Fecha ?? '');

        // SOLUCIÓN PARA SEGUNDO ERROR - Convertir int a double
        sheet
            .getRangeByIndex(rowIndex, 7)
            .setNumber((salida.idProducto ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 8)
            .setNumber((salida.id_Almacen ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 9)
            .setNumber((salida.idPadron ?? 0).toDouble());
        sheet
            .getRangeByIndex(rowIndex, 10)
            .setNumber((salida.id_Junta ?? 0).toDouble());

        rowIndex++;
      }

      // Totales
      final double totalUnidades = salidasFiltradas.fold(
          0, (sum, item) => sum + (item.salida_Unidades ?? 0));
      final double totalCosto = salidasFiltradas.fold(
          0, (sum, item) => sum + (item.salida_Costo ?? 0));

      sheet.getRangeByIndex(rowIndex, 3).setText('TOTALES:');
      sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 4).setNumber(totalUnidades);
      sheet.getRangeByIndex(rowIndex, 5).setNumber(totalCosto);

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Salidas_${selectedMonth.month}_${selectedMonth.year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
      print('Error al generar Excel | ExcelSalidasMes: $e');
    }
  }
}
