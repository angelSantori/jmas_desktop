// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:jmas_desktop/service/auth_service.dart';

class EntradasController {
  AuthService _authService = AuthService();  

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<Entradas>> listEntradas() async {
    try {
      final IOClient client = _createHttpClient();
      final response =
          await client.get(Uri.parse('${_authService.apiURL}/Entradas'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entrada) => Entradas.fromMap(entrada)).toList();
      } else {
        print(
            'Error al obtener la lista de entrdas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista de entradas: $e');
      return [];
    }
  }
}

class Entradas {
  int? id_Entradas;
  String? entrada_Folio;
  double? entrada_Unidades;
  double? entrada_Costo;
  String? entrada_Fecha;
  int? id_Producto;
  int? id_Proveedor;
  Entradas({
    this.id_Entradas,
    this.entrada_Folio,
    this.entrada_Unidades,
    this.entrada_Costo,
    this.entrada_Fecha,
    this.id_Producto,
    this.id_Proveedor,
  });

  Entradas copyWith({
    int? id_Entradas,
    String? entrada_Folio,
    double? entrada_Unidades,
    double? entrada_Costo,
    String? entrada_Fecha,
    int? id_Producto,
    int? id_Proveedor,
  }) {
    return Entradas(
      id_Entradas: id_Entradas ?? this.id_Entradas,
      entrada_Folio: entrada_Folio ?? this.entrada_Folio,
      entrada_Unidades: entrada_Unidades ?? this.entrada_Unidades,
      entrada_Costo: entrada_Costo ?? this.entrada_Costo,
      entrada_Fecha: entrada_Fecha ?? this.entrada_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_Proveedor: id_Proveedor ?? this.id_Proveedor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Entradas': id_Entradas,
      'entrada_Folio': entrada_Folio,
      'entrada_Unidades': entrada_Unidades,
      'entrada_Costo': entrada_Costo,
      'entrada_Fecha': entrada_Fecha,
      'id_Producto': id_Producto,
      'id_Proveedor': id_Proveedor,
    };
  }

  factory Entradas.fromMap(Map<String, dynamic> map) {
    return Entradas(
      id_Entradas:
          map['id_Entradas'] != null ? map['id_Entradas'] as int : null,
      entrada_Folio:
          map['entrada_Folio'] != null ? map['entrada_Folio'] as String : null,
      entrada_Unidades: map['entrada_Unidades'] != null
          ? (map['entrada_Unidades'] as num).toDouble()
          : null,
      entrada_Costo: map['entrada_Costo'] != null
          ? (map['entrada_Costo'] as num).toDouble()
          : null,
      entrada_Fecha:
          map['entrada_Fecha'] != null ? map['entrada_Fecha'] as String : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_Proveedor:
          map['id_Proveedor'] != null ? map['id_Proveedor'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Entradas.fromJson(String source) =>
      Entradas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Entradas(id_Entradas: $id_Entradas, entrada_Folio: $entrada_Folio, entrada_Unidades: $entrada_Unidades, entrada_Costo: $entrada_Costo, entrada_Fecha: $entrada_Fecha, id_Producto: $id_Producto, id_Proveedor: $id_Proveedor)';
  }

  @override
  bool operator ==(covariant Entradas other) {
    if (identical(this, other)) return true;

    return other.id_Entradas == id_Entradas &&
        other.entrada_Folio == entrada_Folio &&
        other.entrada_Unidades == entrada_Unidades &&
        other.entrada_Costo == entrada_Costo &&
        other.entrada_Fecha == entrada_Fecha &&
        other.id_Producto == id_Producto &&
        other.id_Proveedor == id_Proveedor;
  }

  @override
  int get hashCode {
    return id_Entradas.hashCode ^
        entrada_Folio.hashCode ^
        entrada_Unidades.hashCode ^
        entrada_Costo.hashCode ^
        entrada_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_Proveedor.hashCode;
  }
}
