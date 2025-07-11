import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class CapturainviniController {
  AuthService _authService = AuthService();
  static List<Capturainvini>? cacheCapturaIni;

  //List captura inicial
  Future<List<Capturainvini>> listCapturaI() async {
    if (cacheCapturaIni != null) {
      return cacheCapturaIni!;
    }
    try {
      final response = await http
          .get(Uri.parse('${_authService.apiURL}/CapturaInvInis'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((capturaIni) => Capturainvini.fromMap(capturaIni))
            .toList();
      } else {
        print(
            'Error lista Captura Inicial | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista Captura Iniciaal | TryCatch | Controller: $e');
      return [];
    }
  }

  Future<List<Capturainvini>> listCiiXProducto(int productoId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/CapturaInvInis/ByProducto/$productoId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listCiiXProdcuto) => Capturainvini.fromMap(listCiiXProdcuto))
            .toList();
      } else {
        print(
            'Error listCiiXProducto | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listCiiXProducto | Try | Controller: $e');
      return [];
    }
  }

  Future<bool> editCapturaI(Capturainvini captura) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/CapturaInvInis/${captura.idInvIni}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: captura.toJson(),
      );
      if (response.statusCode == 204) {
        cacheCapturaIni = null;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al editar Captura | TryCatch | Controller: $e');
      return false;
    }
  }

  Future<List<Capturainvini>> getConteoInicialByMonth(
      int month, int year) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/CapturaInvInis/ByMonth/$month/$year'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((capturaIni) => Capturainvini.fromMap(capturaIni))
            .toList();
      } else {
        print(
            'Error al obtener conteo inicial por mes: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener conteo inicial por mes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> generateConteoInicialExcel({
    required int month,
    required int year,
    required EntradasController entradasController,
    required SalidasController salidasController,
    required ProductosController productosController,
  }) async {
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

      final conteoAnterior =
          await getConteoInicialByMonth(previousMonth, previousYear);

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
}

class Capturainvini {
  int? idInvIni;
  String? invIniFecha;
  double? invIniConteo;
  int? id_Producto;
  int? id_Almacen;
  Capturainvini({
    this.idInvIni,
    this.invIniFecha,
    this.invIniConteo,
    this.id_Producto,
    this.id_Almacen,
  });

  Capturainvini copyWith({
    int? idInvIni,
    String? invIniFecha,
    double? invIniConteo,
    int? id_Producto,
    int? id_Almacen,
  }) {
    return Capturainvini(
      idInvIni: idInvIni ?? this.idInvIni,
      invIniFecha: invIniFecha ?? this.invIniFecha,
      invIniConteo: invIniConteo ?? this.invIniConteo,
      id_Producto: id_Producto ?? this.id_Producto,
      id_Almacen: id_Almacen ?? this.id_Almacen,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idInvIni': idInvIni,
      'invIniFecha': invIniFecha,
      'invIniConteo': invIniConteo,
      'id_Producto': id_Producto,
      'id_Almacen': id_Almacen,
    };
  }

  factory Capturainvini.fromMap(Map<String, dynamic> map) {
    return Capturainvini(
      idInvIni: map['idInvIni'] != null ? map['idInvIni'] as int : null,
      invIniFecha:
          map['invIniFecha'] != null ? map['invIniFecha'] as String : null,
      invIniConteo: map['invIniConteo'] != null
          ? (map['invIniConteo'] is int
              ? (map['invIniConteo'] as int).toDouble()
              : map['invIniConteo'] as double)
          : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Capturainvini.fromJson(String source) =>
      Capturainvini.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Capturainvini(idInvIni: $idInvIni, invIniFecha: $invIniFecha, invIniConteo: $invIniConteo, id_Producto: $id_Producto, id_Almacen: $id_Almacen)';
  }

  @override
  bool operator ==(covariant Capturainvini other) {
    if (identical(this, other)) return true;

    return other.idInvIni == idInvIni &&
        other.invIniFecha == invIniFecha &&
        other.invIniConteo == invIniConteo &&
        other.id_Producto == id_Producto &&
        other.id_Almacen == id_Almacen;
  }

  @override
  int get hashCode {
    return idInvIni.hashCode ^
        invIniFecha.hashCode ^
        invIniConteo.hashCode ^
        id_Producto.hashCode ^
        id_Almacen.hashCode;
  }
}
