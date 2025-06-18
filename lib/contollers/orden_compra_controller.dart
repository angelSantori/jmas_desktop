// Librerías
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class OrdenCompraController {
  final AuthService _authService = AuthService();

  // GET
  // List OC
  Future<List<OrdenCompra>> listOrdenCompra() async {
    try {
      final response = await http
          .get(Uri.parse('${_authService.apiURL}/OrdenCompras'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((listOC) => OrdenCompra.fromMap(listOC)).toList();
      } else {
        print(
            'Error listOrdenCompra | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listOrdenCompra | Try | Controller: $e');
      return [];
    }
  }

  // OCxFolio
  Future<List<OrdenCompra>> getOCxFolio(String folioOC) async {
    try {
      final response = await http.get(
          Uri.parse('${_authService.apiURL}/OrdenCompras/ByFolio/$folioOC'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listOCxFolio) => OrdenCompra.fromMap(listOCxFolio))
            .toList();
      } else {
        print(
            'Error getOCxFolio | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getOCxFolio | Try | Controller: $e');
      return [];
    }
  }

  // NextOCFolio
  Future<String> getNextOCFolio() async {
    final response = await http.get(
        Uri.parse('${_authService.apiURL}/OrdenCompras/nextOCFolio'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Error getNextOCFolio | Ife | Controller: ${response.statusCode} - ${response.body}');
    }
  }

  // POST
  // addOC
  Future<bool> addOrdenCompra(OrdenCompra ordenCompra) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/OrdenCompras'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ordenCompra.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addOrdenCompra | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addOrdenCompra | Try | Controller: $e');
      return false;
    }
  }

  // PUT
  //editOC
  Future<bool> editOrdenCompra(OrdenCompra ordenCompra) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/OrdenCompras/${ordenCompra.idOrdenCompra}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ordenCompra.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error editOrdenCompra | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error editOrdenCompra | Try | Controller: $e');
      return false;
    }
  }
}

class OrdenCompra {
  int? idOrdenCompra;
  String? folioOC;
  String? estadoOC;
  String? fechaOC;
  int? requisicionOC;
  String? fechaEntregaOC;
  String? direccionEntregaOC;
  String? centroCostoOC;
  String? centroBeneficioOC;
  String? descripcionOC;
  double? cantidadOC;
  String? unidadMedidaOC;
  double? precioUnitarioOC;
  double? totalOC;
  String? notasOC;
  int? idProveedor;
  OrdenCompra({
    this.idOrdenCompra,
    this.folioOC,
    this.estadoOC,
    this.fechaOC,
    this.requisicionOC,
    this.fechaEntregaOC,
    this.direccionEntregaOC,
    this.centroCostoOC,
    this.centroBeneficioOC,
    this.descripcionOC,
    this.cantidadOC,
    this.unidadMedidaOC,
    this.precioUnitarioOC,
    this.totalOC,
    this.notasOC,
    this.idProveedor,
  });

  OrdenCompra copyWith({
    int? idOrdenCompra,
    String? folioOC,
    String? estadoOC,
    String? fechaOC,
    int? requisicionOC,
    String? fechaEntregaOC,
    String? direccionEntregaOC,
    String? centroCostoOC,
    String? centroBeneficioOC,
    String? descripcionOC,
    double? cantidadOC,
    String? unidadMedidaOC,
    double? precioUnitarioOC,
    double? totalOC,
    String? notasOC,
    int? idProveedor,
  }) {
    return OrdenCompra(
      idOrdenCompra: idOrdenCompra ?? this.idOrdenCompra,
      folioOC: folioOC ?? this.folioOC,
      estadoOC: estadoOC ?? this.estadoOC,
      fechaOC: fechaOC ?? this.fechaOC,
      requisicionOC: requisicionOC ?? this.requisicionOC,
      fechaEntregaOC: fechaEntregaOC ?? this.fechaEntregaOC,
      direccionEntregaOC: direccionEntregaOC ?? this.direccionEntregaOC,
      centroCostoOC: centroCostoOC ?? this.centroCostoOC,
      centroBeneficioOC: centroBeneficioOC ?? this.centroBeneficioOC,
      descripcionOC: descripcionOC ?? this.descripcionOC,
      cantidadOC: cantidadOC ?? this.cantidadOC,
      unidadMedidaOC: unidadMedidaOC ?? this.unidadMedidaOC,
      precioUnitarioOC: precioUnitarioOC ?? this.precioUnitarioOC,
      totalOC: totalOC ?? this.totalOC,
      notasOC: notasOC ?? this.notasOC,
      idProveedor: idProveedor ?? this.idProveedor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idOrdenCompra': idOrdenCompra,
      'folioOC': folioOC,
      'estadoOC': estadoOC,
      'fechaOC': fechaOC,
      'requisicionOC': requisicionOC,
      'fechaEntregaOC': fechaEntregaOC,
      'direccionEntregaOC': direccionEntregaOC,
      'centroCostoOC': centroCostoOC,
      'centroBeneficioOC': centroBeneficioOC,
      'descripcionOC': descripcionOC,
      'cantidadOC': cantidadOC,
      'unidadMedidaOC': unidadMedidaOC,
      'precioUnitarioOC': precioUnitarioOC,
      'totalOC': totalOC,
      'notasOC': notasOC,
      'idProveedor': idProveedor,
    };
  }

  factory OrdenCompra.fromMap(Map<String, dynamic> map) {
    return OrdenCompra(
      idOrdenCompra:
          map['idOrdenCompra'] != null ? map['idOrdenCompra'] as int : null,
      folioOC: map['folioOC'] != null ? map['folioOC'] as String : null,
      estadoOC: map['estadoOC'] != null ? map['estadoOC'] as String : null,
      fechaOC: map['fechaOC'] != null ? map['fechaOC'] as String : null,
      requisicionOC:
          map['requisicionOC'] != null ? map['requisicionOC'] as int : null,
      fechaEntregaOC: map['fechaEntregaOC'] != null
          ? map['fechaEntregaOC'] as String
          : null,
      direccionEntregaOC: map['direccionEntregaOC'] != null
          ? map['direccionEntregaOC'] as String
          : null,
      centroCostoOC:
          map['centroCostoOC'] != null ? map['centroCostoOC'] as String : null,
      centroBeneficioOC: map['centroBeneficioOC'] != null
          ? map['centroBeneficioOC'] as String
          : null,
      descripcionOC:
          map['descripcionOC'] != null ? map['descripcionOC'] as String : null,
      cantidadOC: map['cantidadOC'] != null
          ? (map['cantidadOC'] is int
              ? (map['cantidadOC'] as int).toDouble()
              : map['cantidadOC'] as double)
          : null,
      unidadMedidaOC: map['unidadMedidaOC'] != null
          ? map['unidadMedidaOC'] as String
          : null,
      precioUnitarioOC: map['precioUnitarioOC'] != null
          ? (map['precioUnitarioOC'] is int
              ? (map['precioUnitarioOC'] as int).toDouble()
              : map['precioUnitarioOC'] as double)
          : null,
      totalOC: map['totalOC'] != null
          ? (map['totalOC'] is int
              ? (map['totalOC'] as int).toDouble()
              : map['totalOC'] as double)
          : null,
      notasOC: map['notasOC'] != null ? map['notasOC'] as String : null,
      idProveedor:
          map['idProveedor'] != null ? map['idProveedor'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrdenCompra.fromJson(String source) =>
      OrdenCompra.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrdenCompra(idOrdenCompra: $idOrdenCompra, folioOC: $folioOC, estadoOC: $estadoOC, fechaOC: $fechaOC, requisicionOC: $requisicionOC, fechaEntregaOC: $fechaEntregaOC, direccionEntregaOC: $direccionEntregaOC, centroCostoOC: $centroCostoOC, centroBeneficioOC: $centroBeneficioOC, descripcionOC: $descripcionOC, cantidadOC: $cantidadOC, unidadMedidaOC: $unidadMedidaOC, precioUnitarioOC: $precioUnitarioOC, totalOC: $totalOC, notasOC: $notasOC, idProveedor: $idProveedor)';
  }

  @override
  bool operator ==(covariant OrdenCompra other) {
    if (identical(this, other)) return true;

    return other.idOrdenCompra == idOrdenCompra &&
        other.folioOC == folioOC &&
        other.estadoOC == estadoOC &&
        other.fechaOC == fechaOC &&
        other.requisicionOC == requisicionOC &&
        other.fechaEntregaOC == fechaEntregaOC &&
        other.direccionEntregaOC == direccionEntregaOC &&
        other.centroCostoOC == centroCostoOC &&
        other.centroBeneficioOC == centroBeneficioOC &&
        other.descripcionOC == descripcionOC &&
        other.cantidadOC == cantidadOC &&
        other.unidadMedidaOC == unidadMedidaOC &&
        other.precioUnitarioOC == precioUnitarioOC &&
        other.totalOC == totalOC &&
        other.notasOC == notasOC &&
        other.idProveedor == idProveedor;
  }

  @override
  int get hashCode {
    return idOrdenCompra.hashCode ^
        folioOC.hashCode ^
        estadoOC.hashCode ^
        fechaOC.hashCode ^
        requisicionOC.hashCode ^
        fechaEntregaOC.hashCode ^
        direccionEntregaOC.hashCode ^
        centroCostoOC.hashCode ^
        centroBeneficioOC.hashCode ^
        descripcionOC.hashCode ^
        cantidadOC.hashCode ^
        unidadMedidaOC.hashCode ^
        precioUnitarioOC.hashCode ^
        totalOC.hashCode ^
        notasOC.hashCode ^
        idProveedor.hashCode;
  }
}
