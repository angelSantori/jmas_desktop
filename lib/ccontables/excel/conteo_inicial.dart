import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Future<Map<String, dynamic>> generateConteoInicialExcel(
    {required int month,
    required int year,
    required EntradasController entradasController,
    required SalidasController salidasController,
    required ProductosController productosController,
    required CapturainviniController capturainviniController}) async {
  try {
    // Obtener todos los productos
    final productos = await productosController.listProductos();

    // Obtener el conteo inicial del mes anterior (si existe)
    int previousMonth = month - 1;
    int previousYear = year;
    if (previousMonth == 0) {
      previousMonth = 12;
      previousYear = year - 1;
    }

    final conteoAnterior = await capturainviniController
        .getConteoInicialByMonth(previousMonth, previousYear);

    // Obtener todas las entradas del mes actual
    final allEntradas = await entradasController.listEntradas();
    final entradasMes = allEntradas.where((e) {
      if (e.entrada_Fecha == null || e.entrada_Estado != true) {
        return false;
      }
      final entradaDate = parseFecha(e.entrada_Fecha!);
      return entradaDate.year == year && entradaDate.month == month;
    }).toList();

    // Obtener todas las salidas del mes actual
    final allSalidas = await salidasController.listSalidas();
    final salidasMes = allSalidas.where((s) {
      if (s.salida_Fecha == null || s.salida_Estado != true) {
        return false;
      }
      final salidaDate = parseFecha(s.salida_Fecha!);
      return salidaDate.year == year && salidaDate.month == month;
    }).toList();

    // Crear mapa para almacenar el conteo por producto (inicializar todos los productos con 0)
    final Map<int, double> conteoPorProducto = {};
    for (var producto in productos) {
      if (producto.id_Producto != null) {
        conteoPorProducto[producto.id_Producto!] = 0;
      }
    }

    // Procesar conteo anterior (si existe)
    for (var conteo in conteoAnterior) {
      if (conteo.id_Producto != null) {
        conteoPorProducto[conteo.id_Producto!] = conteo.invIniConteo ?? 0;
      }
    }

    // Sumar entradas del mes actual
    for (var entrada in entradasMes) {
      if (entrada.idProducto != null) {
        final unidades = entrada.entrada_Unidades ?? 0;
        conteoPorProducto[entrada.idProducto!] =
            (conteoPorProducto[entrada.idProducto!] ?? 0) + unidades;
      }
    }

    // Restar salidas del mes actual
    for (var salida in salidasMes) {
      if (salida.idProducto != null) {
        final unidades = salida.salida_Unidades ?? 0;
        conteoPorProducto[salida.idProducto!] =
            (conteoPorProducto[salida.idProducto!] ?? 0) - unidades;
      }
    }

    // Crear Excel workbook
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Configurar columnas
    sheet.getRangeByName('A1').columnWidth = 15; // Código
    sheet.getRangeByName('B1').columnWidth = 50; // Artículo
    sheet.getRangeByName('C1').columnWidth = 20; // Existencia total
    sheet.getRangeByName('D1').columnWidth = 15; // Fecha

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

    // Encabezados
    sheet.getRangeByName('A1').setText('Código');
    sheet.getRangeByName('A1').cellStyle = headerStyle;
    sheet.getRangeByName('B1').setText('Artículo');
    sheet.getRangeByName('B1').cellStyle = headerStyle;
    sheet.getRangeByName('C1').setText('Existencia total');
    sheet.getRangeByName('C1').cellStyle = headerStyle;
    sheet.getRangeByName('D1').setText('Fecha');
    sheet.getRangeByName('D1').cellStyle = headerStyle;

    // Llenar datos
    int currentRow = 2;
    final lastDay = DateTime(year, month + 1, 0);
    final fechaReporte = DateFormat('dd/MM/yyyy').format(lastDay);

    // Ordenar productos por código
    productos
        .sort((a, b) => (a.id_Producto ?? 0).compareTo(b.id_Producto ?? 0));

    for (var producto in productos) {
      if (producto.id_Producto == null) continue;

      final existencia = conteoPorProducto[producto.id_Producto!] ?? 0;

      sheet
          .getRangeByName('A$currentRow')
          .setNumber(producto.id_Producto!.toDouble());
      sheet
          .getRangeByName('B$currentRow')
          .setText(producto.prodDescripcion ?? '');
      sheet.getRangeByName('C$currentRow').setNumber(existencia);
      sheet.getRangeByName('D$currentRow').setText(fechaReporte);

      currentRow++;
    }

    // Guardar el workbook
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return {
      'bytes': bytes,
      'fileName':
          'Conteo_Inicial_${month}_${year}_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.xlsx',
    };
  } catch (e) {
    print('Error al generar Excel de conteo inicial: $e');
    rethrow;
  }
}

// Función auxiliar para parsear fechas
DateTime parseFecha(String fecha) {
  try {
    return DateFormat('dd/MM/yyyy').parse(fecha);
  } catch (e) {
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      print('Error al parsear fecha: $fecha');
      return DateTime.now();
    }
  }
}
