import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/ccontables/widgets_ccontables.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:html' as html;

class ExcelServicios {
  static Future<void> generateExcelSalidasServicios({
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
      // Obtener todos los productos de tipo Servicio
      final allProductos = await productosController.listProductos();
      final productosServicio = allProductos
          .where((p) =>
              p.prodUMedSalida?.toLowerCase() == "servicio" ||
              p.prodUMedEntrada?.toLowerCase() == "servicio")
          .toList();

      if (productosServicio.isEmpty) {
        showAdvertence(context, 'No se encontraron servicios registrados');
        return;
      }

      // Obtener salidas para todos los servicios en el mes seleccionado
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, selectedMonth + 1, 0);

      final allSalidas = await salidasController.listSalidas();

      // Filtrar salidas de servicios en el periodo seleccionado
      final salidasServicios = allSalidas.where((s) {
        if (s.salida_Fecha == null ||
            s.salida_Estado != true ||
            s.id_Junta == null ||
            s.idProducto == null) {
          return false;
        }

        // Verificar que el producto sea de tipo "Servicio"
        final producto = productosServicio.firstWhere(
            (p) => p.id_Producto == s.idProducto,
            orElse: () => Productos());
        if (producto.id_Producto == null) {
          return false;
        }

        final salidaDate = parseFecha(s.salida_Fecha!);
        return salidaDate.year == currentYear &&
            salidaDate.month == selectedMonth;
      }).toList();

      if (salidasServicios.isEmpty) {
        showAdvertence(context,
            'No se encontraron salidas de servicios en el mes seleccionado');
        return;
      }

      // Agrupar salidas por servicio y junta
      final Map<int, Map<int, List<Salidas>>> salidasByServiceAndJunta = {};
      final Map<int, Map<int, double>> totalCostoByServiceAndJunta = {};

      for (var salida in salidasServicios) {
        if (salida.idProducto == null || salida.id_Junta == null) continue;

        if (!salidasByServiceAndJunta.containsKey(salida.idProducto)) {
          salidasByServiceAndJunta[salida.idProducto!] = {};
          totalCostoByServiceAndJunta[salida.idProducto!] = {};
        }

        if (!salidasByServiceAndJunta[salida.idProducto]!
            .containsKey(salida.id_Junta)) {
          salidasByServiceAndJunta[salida.idProducto]![salida.id_Junta!] = [];
          totalCostoByServiceAndJunta[salida.idProducto]![salida.id_Junta!] = 0;
        }

        salidasByServiceAndJunta[salida.idProducto]![salida.id_Junta!]!
            .add(salida);
        totalCostoByServiceAndJunta[salida.idProducto]![salida.id_Junta!] =
            (totalCostoByServiceAndJunta[salida.idProducto]![
                        salida.id_Junta!] ??
                    0) +
                (salida.salida_Costo ?? 0);
      }

      double totalCargo = 0;
      for (var productId in totalCostoByServiceAndJunta.keys) {
        for (var juntaId in totalCostoByServiceAndJunta[productId]!.keys) {
          totalCargo += totalCostoByServiceAndJunta[productId]![juntaId] ?? 0;
        }
      }

      // Crear Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      // Configuración de columnas
      sheet.getRangeByName('A1').columnWidth = 20;
      sheet.getRangeByName('B1').columnWidth = 15;
      sheet.getRangeByName('C1').columnWidth = 15;
      sheet.getRangeByName('D1').columnWidth = 50;
      sheet.getRangeByName('E1').columnWidth = 25;
      sheet.getRangeByName('F1').columnWidth = 25;
      sheet.getRangeByName('G1').columnWidth = 25;
      sheet.getRangeByName('H1').columnWidth = 25;

      // Estilos (los mismos que en los otros archivos)
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
      sheet.getRangeByName('B4').setText('');
      sheet.getRangeByName('B4').cellStyle = dataStyle;
      sheet.getRangeByName('B4').cellStyle.hAlign = HAlignType.left;

      // Concepto (modificado para servicios)
      sheet.getRangeByName('A5').setText('CONCEPTO:');
      sheet.getRangeByName('A5').cellStyle = grayBgStyle;
      sheet.getRangeByName('A5').cellStyle.hAlign = HAlignType.right;
      final concepto =
          'SERVICIOS DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear';
      sheet.getRangeByName('B5:D5').merge();
      sheet.getRangeByName('B5').setText(concepto);
      sheet.getRangeByName('B5').cellStyle = dataStyle;

      // Beneficiario
      sheet.getRangeByName('A6').setText('BENEFICIARIO:');
      sheet.getRangeByName('A6').cellStyle = grayBgStyle;
      sheet.getRangeByName('A6').cellStyle.hAlign = HAlignType.right;
      sheet.getRangeByName('B6:D6').merge();
      sheet.getRangeByName('B6').setText('');
      sheet.getRangeByName('B6').cellStyle = dataStyle;

      // SUMAS IGUALES
      int sumasIgualesRow = 7;
      sheet.getRangeByName('A$sumasIgualesRow').setText('SUMAS IGUALES');
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle = grayBgStyle;
      sheet.getRangeByName('A$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.right;

      sheet.getRangeByName('B$sumasIgualesRow').setNumber(totalCargo);
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle = styleSuma;
      sheet.getRangeByName('B$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      sheet.getRangeByName('C$sumasIgualesRow').setNumber(totalCargo);
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle = styleSuma;
      sheet.getRangeByName('C$sumasIgualesRow').cellStyle.hAlign =
          HAlignType.center;

      // Encabezados de tabla (modificados para incluir junta)
      sheet.getRangeByName('A8').setText('Cuenta');
      sheet.getRangeByName('A8').cellStyle = grayBgStyle;
      sheet.getRangeByName('A8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('B8').setText('Cargo');
      sheet.getRangeByName('B8').cellStyle = grayBgStyle;
      sheet.getRangeByName('B8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('C8').setText('Abono');
      sheet.getRangeByName('C8').cellStyle = grayBgStyle;
      sheet.getRangeByName('C8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('D8').setText('Servicio');
      sheet.getRangeByName('D8').cellStyle = grayBgStyle;
      sheet.getRangeByName('D8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('E8').setText('Junta');
      sheet.getRangeByName('E8').cellStyle = grayBgStyle;
      sheet.getRangeByName('E8').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('F8').setText('Fuente Financiamiento');
      sheet.getRangeByName('F8').cellStyle = grayBgStyle;
      sheet.getRangeByName('F8').cellStyle.hAlign = HAlignType.center;

      // Datos - ahora mostrando servicio y junta
      int currentRow = 9;

      for (var productId in salidasByServiceAndJunta.keys) {
        final product = productosServicio.firstWhere(
            (p) => p.id_Producto == productId,
            orElse: () => Productos());
        if (product.id_Producto == null) continue;

        for (var juntaId in salidasByServiceAndJunta[productId]!.keys) {
          final junta = juntas.firstWhere((j) => j.id_Junta == juntaId,
              orElse: () => Juntas());
          final totalCosto =
              totalCostoByServiceAndJunta[productId]![juntaId] ?? 0;

          // Obtener detalles contables para el producto
          final ccList = await ccontablesController.listCCxProducto(productId);
          final cc = ccList.isNotEmpty ? ccList.first : null;

          sheet
              .getRangeByName('A$currentRow')
              .setText(cc?.cC_Detalle?.toString() ?? '0');
          sheet.getRangeByName('A$currentRow').cellStyle = styleInfoData;

          sheet.getRangeByName('B$currentRow').setNumber(totalCosto);
          sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
              HAlignType.right;
          sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;

          sheet.getRangeByName('C$currentRow').setNumber(0);
          sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
              HAlignType.right;
          sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;

          sheet
              .getRangeByName('D$currentRow')
              .setText(product.prodDescripcion?.toUpperCase() ?? '');
          sheet.getRangeByName('D$currentRow').cellStyle = styleInfoData;

          sheet
              .getRangeByName('E$currentRow')
              .setText(junta.junta_Name?.toUpperCase() ?? '');
          sheet.getRangeByName('E$currentRow').cellStyle = styleInfoData;

          sheet.getRangeByName('F$currentRow').setText('149825');
          sheet.getRangeByName('F$currentRow').cellStyle = styleSuma;
          sheet.getRangeByName('F$currentRow').cellStyle.hAlign =
              HAlignType.center;

          currentRow++;
        }
      }

      // Fila final con el resumen
      sheet.getRangeByName('A$currentRow').setText('');
      sheet.getRangeByName('B$currentRow').setText('');
      sheet.getRangeByName('C$currentRow').setNumber(totalCargo);
      sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;
      sheet.getRangeByName('D$currentRow').setText(
          'SERVICIOS DEL 01 AL ${lastDay.day.toString().padLeft(2, '0')} DE ${getMonthName(selectedMonth).toUpperCase()} $currentYear');
      sheet.getRangeByName('E$currentRow').setText('');
      sheet.getRangeByName('F$currentRow').setText('149825');
      sheet.getRangeByName('F$currentRow').cellStyle.hAlign = HAlignType.center;

      // Guardar y descargar
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String fileName =
          'Salidas_Servicios_${selectedMonth}_${DateTime.now().year}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

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
