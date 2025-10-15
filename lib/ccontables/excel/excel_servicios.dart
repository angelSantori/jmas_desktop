import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/ccontables/widgets_ccontables.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/contratistas_controller.dart';
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
    required ContratistasController contratistasController,
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

      // Filtrar juntas: TODAS menos las especiales
      // final juntasNoEspeciales = juntas
      //     .where((j) => j.id_Junta != null && !juntasEsp.contains(j.id_Junta))
      //     .toList();

      // Obtener salidas para todos los servicios en el mes seleccionado
      final currentYear = DateTime.now().year;
      final lastDay = DateTime(currentYear, selectedMonth + 1, 0);

      final allSalidas = await salidasController.listSalidasOptimizado();

      // Filtrar salidas de servicios en el periodo seleccionado y solo de juntas no especiales
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

        // Verificar que la junta NO sea especial
        if (juntasEsp.contains(s.id_Junta)) {
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
      final Map<int, Map<int, Map<int, List<SalidaLista>>>>
          salidasByServiceJuntaContratista = {};
      final Map<int, Map<int, Map<int, double>>>
          totalCostoByServiceJuntaContratista = {};

      for (var salida in salidasServicios) {
        if (salida.idProducto == null || salida.id_Junta == null) continue;

        final contratistaId =
            salida.idContratista ?? 0; // Usar 0 para "Sin contratista"

        if (!salidasByServiceJuntaContratista.containsKey(salida.idProducto)) {
          salidasByServiceJuntaContratista[salida.idProducto!] = {};
          totalCostoByServiceJuntaContratista[salida.idProducto!] = {};
        }

        if (!salidasByServiceJuntaContratista[salida.idProducto]!
            .containsKey(salida.id_Junta)) {
          salidasByServiceJuntaContratista[salida.idProducto]![
              salida.id_Junta!] = {};
          totalCostoByServiceJuntaContratista[salida.idProducto]![
              salida.id_Junta!] = {};
        }

        if (!salidasByServiceJuntaContratista[salida.idProducto]![
                salida.id_Junta]!
            .containsKey(contratistaId)) {
          salidasByServiceJuntaContratista[salida.idProducto]![
              salida.id_Junta]![contratistaId] = [];
          totalCostoByServiceJuntaContratista[salida.idProducto]![
              salida.id_Junta]![contratistaId] = 0;
        }

        salidasByServiceJuntaContratista[salida.idProducto]![salida.id_Junta]![
                contratistaId]!
            .add(salida);
        totalCostoByServiceJuntaContratista[salida.idProducto]![salida
            .id_Junta]![contratistaId] = (totalCostoByServiceJuntaContratista[
                    salida.idProducto]![salida.id_Junta]![contratistaId] ??
                0) +
            (salida.salida_Costo ?? 0);
      }

      double totalCargo = 0;
      for (var productId in totalCostoByServiceJuntaContratista.keys) {
        for (var juntaId
            in totalCostoByServiceJuntaContratista[productId]!.keys) {
          for (var contratistaId
              in totalCostoByServiceJuntaContratista[productId]![juntaId]!
                  .keys) {
            totalCargo += totalCostoByServiceJuntaContratista[productId]![
                    juntaId]![contratistaId] ??
                0;
          }
        }
      }

      // Crear Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = "Resumen Contable Servicios";

      final Worksheet detallesSheet = workbook.worksheets.add();
      detallesSheet.name = "Detalles Servicos";

      // ===== HOJA DE DETALLES =====
      // Configurar anchos de columna para la hoja de detalles
      detallesSheet.getRangeByName('A1').columnWidth = 15; // Folio
      detallesSheet.getRangeByName('B1').columnWidth = 10; // Unidades
      detallesSheet.getRangeByName('C1').columnWidth = 15; // Costo
      detallesSheet.getRangeByName('D1').columnWidth = 15; // Fecha
      detallesSheet.getRangeByName('E1').columnWidth = 10; // ID Servicio
      detallesSheet.getRangeByName('F1').columnWidth =
          40; // Descripción Servicio
      detallesSheet.getRangeByName('G1').columnWidth = 10; // ID Junta
      detallesSheet.getRangeByName('H1').columnWidth = 30; // Nombre Junta
      detallesSheet.getRangeByName('I1').columnWidth = 10; // ID Contratista
      detallesSheet.getRangeByName('J1').columnWidth = 30; // Nombre Contratista

      // Encabezados de la hoja de detalles
      detallesSheet.getRangeByName('A1').setText('Folio');
      detallesSheet.getRangeByName('B1').setText('Unidades');
      detallesSheet.getRangeByName('C1').setText('Costo');
      detallesSheet.getRangeByName('D1').setText('Fecha');
      detallesSheet.getRangeByName('E1').setText('ID Servicio');
      detallesSheet.getRangeByName('F1').setText('Descripción Servicio');
      detallesSheet.getRangeByName('G1').setText('ID Junta');
      detallesSheet.getRangeByName('H1').setText('Nombre Junta');
      detallesSheet.getRangeByName('I1').setText('ID Contratista');
      detallesSheet.getRangeByName('J1').setText('Nombre Contratista');

      // Aplicar estilo a los encabezados
      final rangeHeadersDetalles = detallesSheet.getRangeByName('A1:J1');
      rangeHeadersDetalles.cellStyle.hAlign = HAlignType.center;

      // Precargar contratistas para optimizar
      final allContratistas = await contratistasController.listContratistas();
      final contratistasMap = <int, String>{};
      for (var contratista in allContratistas) {
        contratistasMap[contratista.idContratista] =
            contratista.contratistaNombre;
      }

      // Llenar datos en la hoja de detalles
      int detallesRow = 2;
      for (var salida in salidasServicios) {
        final producto = productosServicio.firstWhere(
            (p) => p.id_Producto == salida.idProducto,
            orElse: () => Productos());
        final junta = juntas.firstWhere((j) => j.id_Junta == salida.id_Junta,
            orElse: () => Juntas());

        // Obtener información del contratista
        String nombreContratista = 'N/A';
        if (salida.idContratista != null && salida.idContratista! > 0) {
          nombreContratista = contratistasMap[salida.idContratista!] ?? 'N/A';
        }

        detallesSheet
            .getRangeByName('A$detallesRow')
            .setText(salida.salida_CodFolio ?? '');
        detallesSheet
            .getRangeByName('B$detallesRow')
            .setNumber(salida.salida_Unidades ?? 0);
        detallesSheet
            .getRangeByName('C$detallesRow')
            .setNumber(salida.salida_Costo ?? 0);

        // Formatear fecha
        if (salida.salida_Fecha != null) {
          final fecha = parseFecha(salida.salida_Fecha!);
          detallesSheet
              .getRangeByName('D$detallesRow')
              .setText(DateFormat('dd/MM/yyyy').format(fecha));
        }

        detallesSheet
            .getRangeByName('E$detallesRow')
            .setValue(salida.idProducto ?? 0);
        detallesSheet
            .getRangeByName('F$detallesRow')
            .setText(producto.prodDescripcion ?? '');
        detallesSheet
            .getRangeByName('G$detallesRow')
            .setValue(salida.id_Junta ?? 0);
        detallesSheet
            .getRangeByName('H$detallesRow')
            .setText(junta.junta_Name ?? '');
        detallesSheet
            .getRangeByName('I$detallesRow')
            .setValue(salida.idContratista ?? 0);
        detallesSheet
            .getRangeByName('J$detallesRow')
            .setText(nombreContratista);

        detallesRow++;
      }
      // ===== HOJA DE DETALLES =====

      // Configuración de columnas
      sheet.getRangeByName('A1').columnWidth = 20;
      sheet.getRangeByName('B1').columnWidth = 15;
      sheet.getRangeByName('C1').columnWidth = 15;
      sheet.getRangeByName('D1').columnWidth = 60; // Aumentado para concepto
      sheet.getRangeByName('E1').columnWidth = 25;
      sheet.getRangeByName('F1').columnWidth = 25;

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
      styleInfoData.numberFormat = '0.00';

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

      // Concepto
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

      // Encabezados de tabla (modificados)
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

      // Datos - ahora mostrando junta_Cuenta y concepto combinado
      int currentRow = 9;

      // Primero: Filas de juntas con sus servicios Y contratistas (cargo)
      for (var productId in salidasByServiceJuntaContratista.keys) {
        final product = productosServicio.firstWhere(
            (p) => p.id_Producto == productId,
            orElse: () => Productos());
        if (product.id_Producto == null) continue;

        for (var juntaId in salidasByServiceJuntaContratista[productId]!.keys) {
          final junta = juntas.firstWhere((j) => j.id_Junta == juntaId,
              orElse: () => Juntas());

          for (var contratistaId
              in salidasByServiceJuntaContratista[productId]![juntaId]!.keys) {
            final totalCosto = totalCostoByServiceJuntaContratista[productId]![
                    juntaId]![contratistaId] ??
                0;

            // Obtener nombre del contratista
            String nombreContratista = 'Sin contratista';
            if (contratistaId > 0) {
              nombreContratista = contratistasMap[contratistaId] ??
                  'Contratista $contratistaId';
            }

            // Usar junta_Cuenta en lugar del código contable del producto
            sheet
                .getRangeByName('A$currentRow')
                .setText(junta.junta_Cuenta ?? '0');
            sheet.getRangeByName('A$currentRow').cellStyle = styleInfoData;

            sheet.getRangeByName('B$currentRow').setNumber(totalCosto);
            sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
                HAlignType.right;
            sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;

            sheet.getRangeByName('C$currentRow').setNumber(0);
            sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
                HAlignType.right;
            sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;

            // Concepto combinado: servicio + junta + contratista
            String conceptoMovimiento =
                '${product.prodDescripcion?.toUpperCase() ?? ''} - ${junta.junta_Name?.toUpperCase() ?? ''}';
            if (contratistaId > 0) {
              conceptoMovimiento += ' - $nombreContratista';
            }
            sheet.getRangeByName('D$currentRow').setText(conceptoMovimiento);
            sheet.getRangeByName('D$currentRow').cellStyle = styleInfoData;

            sheet.getRangeByName('E$currentRow').setText('149825');
            sheet.getRangeByName('E$currentRow').cellStyle = styleSuma;
            sheet.getRangeByName('E$currentRow').cellStyle.hAlign =
                HAlignType.center;

            currentRow++;
          }
        }
      }

      // Segundo: Filas de resumen por servicio (abono) - SIN cambios aquí
// Calcular totales por servicio
      final Map<int, double> totalPorServicio = {};
      for (var productId in salidasByServiceJuntaContratista.keys) {
        double totalServicio = 0;
        for (var juntaId in salidasByServiceJuntaContratista[productId]!.keys) {
          for (var contratistaId
              in salidasByServiceJuntaContratista[productId]![juntaId]!.keys) {
            totalServicio += totalCostoByServiceJuntaContratista[productId]![
                    juntaId]![contratistaId] ??
                0;
          }
        }
        totalPorServicio[productId] = totalServicio;
      }

      // Agregar filas de abono para cada servicio (sin cambios)
      for (var productId in totalPorServicio.keys) {
        final product = productosServicio.firstWhere(
            (p) => p.id_Producto == productId,
            orElse: () => Productos());
        if (product.id_Producto == null) continue;

        // Obtener detalles contables para el producto (para el abono)
        final ccList = await ccontablesController.listCCxProducto(productId);
        final cc = ccList.isNotEmpty ? ccList.first : null;

        sheet
            .getRangeByName('A$currentRow')
            .setText(cc?.cC_Detalle?.toString() ?? '0');
        sheet.getRangeByName('A$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('B$currentRow').setNumber(0);
        sheet.getRangeByName('B$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('B$currentRow').cellStyle = styleInfoData;

        sheet
            .getRangeByName('C$currentRow')
            .setNumber(totalPorServicio[productId] ?? 0);
        sheet.getRangeByName('C$currentRow').cellStyle.hAlign =
            HAlignType.right;
        sheet.getRangeByName('C$currentRow').cellStyle = styleInfoData;

        // Solo el nombre del servicio en el concepto
        sheet
            .getRangeByName('D$currentRow')
            .setText(product.prodDescripcion?.toUpperCase() ?? '');
        sheet.getRangeByName('D$currentRow').cellStyle = styleInfoData;

        sheet.getRangeByName('E$currentRow').setText('149825');
        sheet.getRangeByName('E$currentRow').cellStyle = styleSuma;
        sheet.getRangeByName('E$currentRow').cellStyle.hAlign =
            HAlignType.center;

        currentRow++;
      }

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
