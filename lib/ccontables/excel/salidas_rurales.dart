import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelSalidasRurales {
  static Future<void> generateExcelSalidasRurales({
    required int? selectedMonth,
    required List<int> juntasEsp,
    required List<Juntas> juntas,
    required ProductosController productosController,
    required SalidasController salidasController,
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

      // Obtener salidas para todas las juntas rurales en el mes seleccionado
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, selectedMonth + 1, 0);

      final allSalidas = await salidasController.listSalidas();

      // 1. Primero obtén todos los productos y filtra los que no son "Servicio"
      final allProductos = await productosController.listProductos();
      final productosNoServicio = allProductos
          .where((p) =>
              p.prodUMedSalida?.toLowerCase() != "servicio" &&
              p.prodUMedEntrada?.toLowerCase() != "servicio")
          .toList();

      // 2. Luego filtra las salidas para incluir solo las de productos no servicio
      final salidasInPeriod = allSalidas.where((s) {
        if (s.salida_Fecha == null ||
            s.id_Junta == null ||
            s.idProducto == null) {
          return false;
        }

        // Excluir juntas especiales
        if (juntasEsp.contains(s.id_Junta)) {
          return false;
        }

        // Verificar que el producto no sea de tipo "Servicio"
        final producto = productosNoServicio.firstWhere(
            (p) => p.id_Producto == s.idProducto,
            orElse: () => Productos());
        if (producto.id_Producto == null) {
          return false; // Excluir si el producto es de tipo "Servicio"
        }

        final salidaDate = parseFecha(s.salida_Fecha!);
        return salidaDate.year == currentYear &&
            salidaDate.month == selectedMonth;
      }).toList();

      // Obtener salidas activas (estado = true)
      final salidasActivas =
          salidasInPeriod.where((s) => s.salida_Estado == true).toList();

      // Obtener salidas canceladas (estado = false)
      // final salidasCanceladas =
      //     salidasInPeriod.where((s) => s.salida_Estado == false).toList();

      // Agrupar salidas por junta (en lugar de por producto)
      final Map<int, List<Salidas>> salidasByJunta = {};
      final Map<int, double> totalCostoByJunta = {};

      for (var salida in salidasActivas) {
        if (salida.id_Junta == null) continue;

        if (!salidasByJunta.containsKey(salida.id_Junta)) {
          salidasByJunta[salida.id_Junta!] = [];
          totalCostoByJunta[salida.id_Junta!] = 0;
        }

        salidasByJunta[salida.id_Junta!]!.add(salida);
        totalCostoByJunta[salida.id_Junta!] =
            (totalCostoByJunta[salida.id_Junta!] ?? 0) +
                (salida.salida_Costo ?? 0);
      }

      double totalCargo = 0;
      for (var juntaId in salidasByJunta.keys) {
        final totalCosto = totalCostoByJunta[juntaId] ?? 0;
        totalCargo += totalCosto;
      }

      // Crear Excel workbook
      final Workbook workbook = Workbook();

      // Hoja 1: Reporte Salidas Rurales (formato contable)
      final Worksheet sheet1 = workbook.worksheets[0];
      sheet1.name = 'Reporte Salidas Rurales';

      // Hoja 2: Salidas Rurales Activas
      final Worksheet sheet2 = workbook.worksheets.add();
      sheet2.name = 'Salidas Rurales Activas';

      // Hoja 3: Salidas Rurales Completas
      final Worksheet sheet3 = workbook.worksheets.add();
      sheet3.name = 'Salidas Rurales Completas';

      // ===== HOJA 1: Reporte Salidas Rurales =====
      // Configuración de columnas y estilos
      sheet1.getRangeByName('A1').columnWidth = 20;
      sheet1.getRangeByName('B1').columnWidth = 15;
      sheet1.getRangeByName('C1').columnWidth = 15;
      sheet1.getRangeByName('D1').columnWidth = 50;
      sheet1.getRangeByName('E1').columnWidth = 25;
      sheet1.getRangeByName('F1').columnWidth = 25;
      sheet1.getRangeByName('G1').columnWidth = 25;
      sheet1.getRangeByName('H1').columnWidth = 25;

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
      sheet1.getRangeByName('A1:E1').merge();
      sheet1.getRangeByName('A1').setText(
          'SISTEMA AUTOMATIZADO DE ADMINISTRACIÓN Y CONTABILIDAD GUBERNAMENTAL SAACG.NET');
      sheet1.getRangeByName('A1').cellStyle = headerStyle;

      // Fecha
      sheet1.getRangeByName('A2').setText('FECHA:');
      sheet1.getRangeByName('A2').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A2').cellStyle.hAlign = HAlignType.right;
      sheet1.getRangeByName('B2').setText(
          '${lastDay.day.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')}/$currentYear');
      sheet1.getRangeByName('B2').cellStyle = dataStyle;
      sheet1.getRangeByName('B2').cellStyle.hAlign = HAlignType.right;

      // Tipo de Poliza
      sheet1.getRangeByName('A3').setText('TIPO DE POLIZA:');
      sheet1.getRangeByName('A3').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A3').cellStyle.hAlign = HAlignType.right;
      sheet1.getRangeByName('B3').setText('D');
      sheet1.getRangeByName('B3').cellStyle = dataStyle;
      sheet1.getRangeByName('B3').cellStyle.hAlign = HAlignType.left;

      // No. Cheque
      sheet1.getRangeByName('A4').setText('NO. CHEQUE:');
      sheet1.getRangeByName('A4').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A4').cellStyle.hAlign = HAlignType.right;
      sheet1.getRangeByName('B4').setText(''); // Queda en blanco
      sheet1.getRangeByName('B4').cellStyle = dataStyle;
      sheet1.getRangeByName('B4').cellStyle.hAlign = HAlignType.left;

      // Concepto (modificado para juntas rurales)
      sheet1.getRangeByName('A5').setText('CONCEPTO:');
      sheet1.getRangeByName('A5').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A5').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'SALIDAS DE ALMACÉN RURALES DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
      sheet1.getRangeByName('B5:D5').merge();
      sheet1.getRangeByName('B5').setText(concepto);
      sheet1.getRangeByName('B5').cellStyle = dataStyle;

      // Beneficiario (nuevo campo)
      sheet1.getRangeByName('A6').setText('BENEFICIARIO:');
      sheet1.getRangeByName('A6').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A6').cellStyle.hAlign = HAlignType.right;
      sheet1.getRangeByName('B6:D6').merge();
      sheet1.getRangeByName('B6').setText(''); // Queda en blanco
      sheet1.getRangeByName('B6').cellStyle = dataStyle;

      // SUMAS IGUALES
      int sumasIgualesRow = 7;
      sheet1.getRangeByName('A$sumasIgualesRow').setText('SUMAS IGUALES');
      sheet1.getRangeByName('A$sumasIgualesRow').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.right;

      sheet1.getRangeByName('B$sumasIgualesRow').setNumber(totalCargo);
      sheet1.getRangeByName('B$sumasIgualesRow').cellStyle = styleSuma;
      sheet1.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet1.getRangeByName('C$sumasIgualesRow').setNumber(totalCargo);
      sheet1.getRangeByName('C$sumasIgualesRow').cellStyle = styleSuma;
      sheet1.getRangeByName('C$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      // Encabezados de tabla
      sheet1.getRangeByName('A8').setText('Cuenta');
      sheet1.getRangeByName('A8').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A8').cellStyle.hAlign = HAlignType.center;
      sheet1.getRangeByName('B8').setText('Cargo');
      sheet1.getRangeByName('B8').cellStyle = grayBgStyle;
      sheet1.getRangeByName('B8').cellStyle.hAlign = HAlignType.center;
      sheet1.getRangeByName('C8').setText('Abono');
      sheet1.getRangeByName('C8').cellStyle = grayBgStyle;
      sheet1.getRangeByName('C8').cellStyle.hAlign = HAlignType.center;
      sheet1.getRangeByName('D8').setText('Concepto por Movimiento');
      sheet1.getRangeByName('D8').cellStyle = grayBgStyle;
      sheet1.getRangeByName('D8').cellStyle.hAlign = HAlignType.center;
      sheet1.getRangeByName('E8').setText('Fuente Financiamiento');
      sheet1.getRangeByName('E8').cellStyle = grayBgStyle;
      sheet1.getRangeByName('E8').cellStyle.hAlign = HAlignType.center;

      // Datos - ahora agrupados por junta
      int currentRow = 9;

      for (var juntaId in salidasByJunta.keys) {
        final junta = juntasRurales.firstWhere((j) => j.id_Junta == juntaId,
            orElse: () => Juntas());
        final totalCosto = totalCostoByJunta[juntaId] ?? 0;

        // Usar junta_Cuenta en lugar de cuenta de producto
        sheet1
            .getRangeByName('A$currentRow')
            .setText(junta.junta_Cuenta?.toString() ?? '0');
        sheet1.getRangeByName('A$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('B$currentRow').setNumber(totalCosto);
        sheet1.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet1.getRangeByName('B$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('C$currentRow').setNumber(0);
        sheet1.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet1.getRangeByName('C$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('D$currentRow').merge();
        sheet1.getRangeByName('D$currentRow').setText(
            'SALIDA DE ALMACÉN DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear ${junta.junta_Name?.toUpperCase()}');
        sheet1.getRangeByName('D$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('E$currentRow').setText('149825');
        sheet1.getRangeByName('E$currentRow').cellStyle = styleSuma;
        sheet1.getRangeByName('E$currentRow').cellStyle.hAlign =
            HAlignType.center;

        currentRow++;
      }

      // Fila final con el resumen
      sheet1.getRangeByName('A$currentRow').setText('');
      sheet1.getRangeByName('B$currentRow').setText('');
      sheet1.getRangeByName('C$currentRow').setNumber(totalCargo);
      sheet1.getRangeByName('C$currentRow').cellStyle = styleInfoData;
      sheet1.getRangeByName('D$currentRow').setText(
          'SALIDAS DE ALMACÉN RURALES DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear');
      sheet1.getRangeByName('E$currentRow').setText('149825');
      sheet1.getRangeByName('E$currentRow').cellStyle.hAlign =
          HAlignType.center;

      // ===== HOJA 2: Salidas Rurales Activas =====
      await _generateDetailedSheet(
        sheet: sheet2,
        salidas: salidasActivas,
        juntas: juntasRurales,
        allProductos: allProductos,
        allCuentas: await ccontablesController.listCcontables(),
        title:
            'SALIDAS RURALES ACTIVAS - ${getMonthName(selectedMonth).toUpperCase()} $currentYear',
        isComplete: false,
      );

      // ===== HOJA 3: Salidas Rurales Completas =====
      await _generateDetailedSheet(
        sheet: sheet3,
        salidas: salidasInPeriod, // Todas las salidas (activas + canceladas)
        juntas: juntasRurales,
        allProductos: allProductos,
        allCuentas: await ccontablesController.listCcontables(),
        title:
            'SALIDAS RURALES COMPLETAS - ${getMonthName(selectedMonth).toUpperCase()} $currentYear',
        isComplete: true,
      );

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Salidas_Almacen_Juntas_Rurales_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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

  // Método auxiliar para generar hojas detalladas
  static Future<void> _generateDetailedSheet({
    required Worksheet sheet,
    required List<Salidas> salidas,
    required List<Juntas> juntas,
    required List<Productos> allProductos,
    required List<CContables> allCuentas,
    required String title,
    required bool isComplete, // Si es true, marca las canceladas en rojo
  }) async {
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
    final Workbook workbook = sheet.workbook;
    final Style headerStyle = workbook.styles.add('headerStyle${sheet.index}');
    headerStyle.backColor = '#000000';
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.fontName = 'Arial';
    headerStyle.fontSize = 12;
    headerStyle.bold = true;
    headerStyle.hAlign = HAlignType.center;
    headerStyle.vAlign = VAlignType.center;

    final Style normalStyle = workbook.styles.add('normalStyle${sheet.index}');
    normalStyle.fontName = 'Arial';
    normalStyle.fontSize = 11;

    final Style canceledStyle =
        workbook.styles.add('canceledStyle${sheet.index}');
    canceledStyle.fontName = 'Arial';
    canceledStyle.fontSize = 11;
    canceledStyle.fontColor = '#FF0000'; // Rojo para salidas canceladas
    canceledStyle.italic = true;

    // Título
    sheet.getRangeByName('A1:J1').merge();
    sheet.getRangeByName('A1').setText(title);
    sheet.getRangeByName('A1').cellStyle = headerStyle;

    // Fecha de generación
    sheet.getRangeByName('A2').setText('Fecha de generación:');
    sheet
        .getRangeByName('B2')
        .setText(DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

    // Encabezados de columnas
    final List<String> headers = [
      'Folio',
      'Código Cuenta',
      'Estado',
      'Unidades',
      'Costo',
      'Fecha',
      'ID Producto',
      'ID Almacén',
      'ID Padron',
      'ID Junta - Nombre'
    ];

    // Escribir encabezados
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(4, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(4, i + 1).cellStyle = headerStyle;
    }

    // Datos
    int rowIndex = 5;
    for (var salida in salidas) {
      final isCanceled = !(salida.salida_Estado ?? false);
      final currentStyle = isCanceled ? canceledStyle : normalStyle;

      sheet.getRangeByIndex(rowIndex, 1).setText(salida.salida_CodFolio ?? '');
      sheet.getRangeByIndex(rowIndex, 1).cellStyle = currentStyle;

      // Código de cuenta
      String codigoCuenta = '';
      if (salida.idProducto != null) {
        final cuenta = allCuentas.firstWhere(
          (c) => c.idProducto == salida.idProducto,
          orElse: () => CContables(),
        );

        if (cuenta.cC_Detalle != null) {
          codigoCuenta = '${cuenta.cC_Detalle}';
        }
      }
      sheet.getRangeByIndex(rowIndex, 2).setText(codigoCuenta);
      sheet.getRangeByIndex(rowIndex, 2).cellStyle = currentStyle;

      // Estado
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setText(isCanceled ? 'Cancelado' : 'Activo');
      sheet.getRangeByIndex(rowIndex, 3).cellStyle = currentStyle;

      // Unidades
      sheet.getRangeByIndex(rowIndex, 4).setNumber(salida.salida_Unidades ?? 0);
      sheet.getRangeByIndex(rowIndex, 4).cellStyle = currentStyle;

      // Costo
      sheet.getRangeByIndex(rowIndex, 5).setNumber(salida.salida_Costo ?? 0);
      sheet.getRangeByIndex(rowIndex, 5).cellStyle = currentStyle;

      // Fecha
      sheet.getRangeByIndex(rowIndex, 6).setText(salida.salida_Fecha ?? '');
      sheet.getRangeByIndex(rowIndex, 6).cellStyle = currentStyle;

      // IDs
      sheet
          .getRangeByIndex(rowIndex, 7)
          .setNumber((salida.idProducto ?? 0).toDouble());
      sheet.getRangeByIndex(rowIndex, 7).cellStyle = currentStyle;

      sheet
          .getRangeByIndex(rowIndex, 8)
          .setNumber((salida.id_Almacen ?? 0).toDouble());
      sheet.getRangeByIndex(rowIndex, 8).cellStyle = currentStyle;

      sheet
          .getRangeByIndex(rowIndex, 9)
          .setNumber((salida.idPadron ?? 0).toDouble());
      sheet.getRangeByIndex(rowIndex, 9).cellStyle = currentStyle;

      // Junta (ID - Nombre)
      final juntaID = salida.id_Junta ?? 0;
      final junta = juntas.firstWhere(
        (j) => j.id_Junta == juntaID,
        orElse: () => Juntas(junta_Name: 'Desconocido'),
      );
      sheet
          .getRangeByIndex(rowIndex, 10)
          .setText('$juntaID - ${junta.junta_Name}');
      sheet.getRangeByIndex(rowIndex, 10).cellStyle = currentStyle;

      rowIndex++;
    }

    // Totales (solo para salidas activas si es la hoja completa)
    if (!isComplete) {
      final double totalUnidades =
          salidas.fold(0, (sum, item) => sum + (item.salida_Unidades ?? 0));
      final double totalCosto =
          salidas.fold(0, (sum, item) => sum + (item.salida_Costo ?? 0));

      sheet.getRangeByIndex(rowIndex, 3).setText('TOTALES:');
      sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 4).setNumber(totalUnidades);
      sheet.getRangeByIndex(rowIndex, 5).setNumber(totalCosto);
    }
  }

  // Función auxiliar para parsear fechas
  static DateTime parseFecha(String fechaStr) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm:ss').parse(fechaStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Función auxiliar para obtener nombre del mes
  static String getMonthName(int month) {
    final months = [
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
    return months[month - 1];
  }
}
