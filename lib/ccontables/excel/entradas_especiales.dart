import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/ccontables/widgets_ccontables.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelEntradasEspeciales {
  static Future<void> generateExcelEntradasEspeciales({
    required int? selectedMonth,
    required List<int> juntasEspecialesRecibidas,
    required List<Juntas> juntas,
    required ProductosController productosController,
    required EntradasController entradasController,
    required CcontablesController ccontablesController,
    required ProveedoresController proveedoresController,
    required BuildContext context,
  }) async {
    if (selectedMonth == null) {
      showAdvertence(context, 'Por favor seleccione un mes');
      return;
    }
    try {
      // Obtener todas las juntas especiales
      final juntasEspeciales = juntas
          .where((j) => juntasEspecialesRecibidas.contains(j.id_Junta))
          .toList();
      if (juntasEspeciales.isEmpty) {
        showAdvertence(context, 'No se encontraron las juntas especiales');
        return;
      }

      // Obtener todos los productos
      final productos = await productosController.listProductos();

      // Obtener entradas para todas las juntas especiales en el mes seleccionado
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, selectedMonth + 1, 0);

      final allEntradas = await entradasController.listEntradas();

      final allProveedores = await proveedoresController.listProveedores();

      // Filtrar entradas para juntas especiales en el periodo seleccionado
      final entradasInPeriod = allEntradas.where((e) {
        if (e.entrada_Fecha == null || e.id_Junta == null) {
          return false;
        }

        if (!juntasEspecialesRecibidas.contains(e.id_Junta)) {
          return false;
        }

        final entradaDate = parseFecha(e.entrada_Fecha!);
        return entradaDate.year == currentYear &&
            entradaDate.month == selectedMonth;
      }).toList();

      // Obtener entradas activas (estado = true)
      final entradasActivas =
          entradasInPeriod.where((e) => e.entrada_Estado == true).toList();

      // Agrupar entradas por producto (sin importar la junta) - solo para la hoja contable
      final Map<int, List<Entradas>> entradasByProduct = {};
      final Map<int, double> totalCostoByProduct = {};

      for (var entrada in entradasActivas) {
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

      // Obtener detalles contables para cada producto
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

      // Crear Excel workbook
      final Workbook workbook = Workbook();

      // Hoja 1: Reporte Entradas Especiales (formato contable)
      final Worksheet sheet1 = workbook.worksheets[0];
      sheet1.name = 'Reporte Entradas Especiales';

      // Hoja 2: Entradas Especiales Activas
      final Worksheet sheet2 = workbook.worksheets.add();
      sheet2.name = 'Entradas Especiales Activas';

      // Hoja 3: Entradas Especiales Completas
      final Worksheet sheet3 = workbook.worksheets.add();
      sheet3.name = 'Entradas Especiales Completas';

      // ===== HOJA 1: Reporte Entradas Especiales =====
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

      // Concepto (modificado para juntas especiales)
      sheet1.getRangeByName('A5').setText('CONCEPTO:');
      sheet1.getRangeByName('A5').cellStyle = grayBgStyle;
      sheet1.getRangeByName('A5').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'ENTRADAS DE ALMACÉN DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
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

      sheet1.getRangeByName('B$sumasIgualesRow').setNumber(totalAbono);
      sheet1.getRangeByName('B$sumasIgualesRow').cellStyle = styleSuma;
      sheet1.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet1.getRangeByName('C$sumasIgualesRow').setNumber(totalAbono);
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

      // Datos
      int currentRow = 9;

      for (var productId in entradasByProduct.keys) {
        final product = productos.firstWhere((p) => p.id_Producto == productId,
            orElse: () => Productos());
        final cc = ccByProduct[productId];
        final totalCosto = totalCostoByProduct[productId] ?? 0;

        sheet1
            .getRangeByName('A$currentRow')
            .setText(cc?.cC_Detalle?.toString() ?? '0');
        sheet1.getRangeByName('A$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('B$currentRow').setNumber(0);
        sheet1.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet1.getRangeByName('B$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('C$currentRow').setNumber(totalCosto);
        sheet1.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet1.getRangeByName('C$currentRow').cellStyle = styleInfoData;

        sheet1
            .getRangeByName('D$currentRow')
            .setText('${product.prodDescripcion?.toUpperCase()}');
        sheet1.getRangeByName('D$currentRow').cellStyle = styleInfoData;

        sheet1.getRangeByName('E$currentRow').setText('149825');
        sheet1.getRangeByName('E$currentRow').cellStyle = styleSuma;
        sheet1.getRangeByName('E$currentRow').cellStyle.hAlign =
            HAlignType.center;

        currentRow++;
      }

      // Fila final con el resumen
      sheet1.getRangeByName('A$currentRow').setText('1151-8-004');
      sheet1.getRangeByName('B$currentRow').setNumber(totalAbono);
      sheet1.getRangeByName('B$currentRow').cellStyle = styleInfoData;
      sheet1.getRangeByName('C$currentRow').setText('');
      sheet1.getRangeByName('D$currentRow').setText(
          'ENTRADAS DE ALMACÉN DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear');
      sheet1.getRangeByName('E$currentRow').setText('149825');
      sheet1.getRangeByName('E$currentRow').cellStyle.hAlign =
          HAlignType.center;

      // ===== HOJA 2: Entradas Especiales Activas =====
      await _generateDetailedSheet(
        sheet: sheet2,
        entradas: entradasActivas,
        juntas: juntasEspeciales,
        allProductos: productos,
        allProveedores: allProveedores,
        allCuentas: await ccontablesController.listCcontables(),
        title:
            'ENTRADAS ESPECIALES ACTIVAS - ${getMonthName(selectedMonth).toUpperCase()} $currentYear',
        isComplete: false,
      );

      // ===== HOJA 3: Entradas Especiales Completas =====
      await _generateDetailedSheet(
        sheet: sheet3,
        allProveedores: allProveedores,
        entradas: entradasInPeriod, // Todas las entradas (activas + canceladas)
        juntas: juntasEspeciales,
        allProductos: productos,
        allCuentas: await ccontablesController.listCcontables(),
        title:
            'ENTRADAS ESPECIALES COMPLETAS - ${getMonthName(selectedMonth).toUpperCase()} $currentYear',
        isComplete: true,
      );

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Entradas_Almacen_Juntas_Especiales_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
    required List<Entradas> entradas,
    required List<Juntas> juntas,
    required List<Productos> allProductos,
    required List<CContables> allCuentas,
    required List<Proveedores> allProveedores,
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
    canceledStyle.backColor = '#FF0000'; // Fondo rojo
    canceledStyle.fontColor = '#FFFFFF'; // Texto blanco
    canceledStyle.bold = true;

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
      'ID Proveedor - Nombre',
      'ID Junta - Nombre'
    ];

    // Escribir encabezados
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(4, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(4, i + 1).cellStyle = headerStyle;
    }

    // Datos
    int rowIndex = 5;
    for (var entrada in entradas) {
      final isCanceled = !(entrada.entrada_Estado ?? false);
      final currentStyle = isCanceled ? canceledStyle : normalStyle;

      // Aplicar estilo a toda la fila
      final Range rowRange = sheet.getRangeByIndex(rowIndex, 1, rowIndex, 10);
      rowRange.cellStyle = currentStyle;

      sheet
          .getRangeByIndex(rowIndex, 1)
          .setText(entrada.entrada_CodFolio ?? '');

      // Código de cuenta
      String codigoCuenta = '';
      if (entrada.idProducto != null) {
        final cuenta = allCuentas.firstWhere(
          (c) => c.idProducto == entrada.idProducto,
          orElse: () => CContables(),
        );

        if (cuenta.cC_Detalle != null) {
          codigoCuenta = '${cuenta.cC_Detalle}';
        }
      }
      sheet.getRangeByIndex(rowIndex, 2).setText(codigoCuenta);

      // Estado
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setText(isCanceled ? 'Cancelado' : 'Activo');

      // Unidades
      sheet
          .getRangeByIndex(rowIndex, 4)
          .setNumber(entrada.entrada_Unidades ?? 0);

      // Costo
      sheet.getRangeByIndex(rowIndex, 5).setNumber(entrada.entrada_Costo ?? 0);

      // Fecha
      sheet.getRangeByIndex(rowIndex, 6).setText(entrada.entrada_Fecha ?? '');

      // IDs
      sheet
          .getRangeByIndex(rowIndex, 7)
          .setNumber((entrada.idProducto ?? 0).toDouble());

      sheet
          .getRangeByIndex(rowIndex, 8)
          .setNumber((entrada.id_Almacen ?? 0).toDouble());

      // Proveedor (ID - Nombre)
      final proveedorID = entrada.id_Proveedor ?? 0;
      String proveedorInfo = '';
      if (proveedorID > 0) {
        final proveedor = allProveedores.firstWhere(
          (p) => p.id_Proveedor == proveedorID,
          orElse: () => Proveedores(proveedor_Name: 'Desconocido'),
        );
        proveedorInfo =
            '$proveedorID - ${proveedor.proveedor_Name ?? 'Sin nombre'}';
      } else {
        proveedorInfo = 'Sin proveedor';
      }
      sheet.getRangeByIndex(rowIndex, 9).setText(proveedorInfo);

      // Junta (ID - Nombre)
      final juntaID = entrada.id_Junta ?? 0;
      final junta = juntas.firstWhere(
        (j) => j.id_Junta == juntaID,
        orElse: () => Juntas(junta_Name: 'Desconocido'),
      );
      sheet
          .getRangeByIndex(rowIndex, 10)
          .setText('$juntaID - ${junta.junta_Name}');

      rowIndex++;
    }

    // Totales
    final double totalUnidades =
        entradas.fold(0, (sum, item) => sum + (item.entrada_Unidades ?? 0));
    final double totalCosto =
        entradas.fold(0, (sum, item) => sum + (item.entrada_Costo ?? 0));

    sheet.getRangeByIndex(rowIndex, 3).setText('TOTALES:');
    sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 4).setNumber(totalUnidades);
    sheet.getRangeByIndex(rowIndex, 5).setNumber(totalCosto);
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
