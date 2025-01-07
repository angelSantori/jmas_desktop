// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:jmas_desktop/service/auth_service.dart';

class EntradasController {
  final AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<Entradas>> listEntradas() async {
    try {
      final IOClient client = _createHttpClient();
      final response = await client.get(
        Uri.parse('${_authService.apiURL}/Entradas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

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

  Future<bool> addEntrada(Entradas entrada) async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('${_authService.apiURL}/Entradas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: entrada.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al crear la entrada: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al crear la entrada: $e');
      return false;
    }
  }

  Future<List<Entradas>> getEntradaByFolio(String folio) async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('${_authService.apiURL}/Entradas/ByFolio/$folio'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entrada) => Entradas.fromMap(entrada)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton entradas con el folio: $folio');
        return [];
      } else {
        print(
            'Error al obtener las entradas por folio: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener las entradas poe folio: $e');
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
  int? id_User;
  int? id_Junta;
  int? id_Entidad;
  int? user_Reporte;
  Entradas({
    this.id_Entradas,
    this.entrada_Folio,
    this.entrada_Unidades,
    this.entrada_Costo,
    this.entrada_Fecha,
    this.id_Producto,
    this.id_Proveedor,
    this.id_User,
    this.id_Junta,
    this.id_Entidad,
    this.user_Reporte,
  });

  Entradas copyWith({
    int? id_Entradas,
    String? entrada_Folio,
    double? entrada_Unidades,
    double? entrada_Costo,
    String? entrada_Fecha,
    int? id_Producto,
    int? id_Proveedor,
    int? id_User,
    int? id_Junta,
    int? id_Entidad,
    int? user_Reporte,
  }) {
    return Entradas(
      id_Entradas: id_Entradas ?? this.id_Entradas,
      entrada_Folio: entrada_Folio ?? this.entrada_Folio,
      entrada_Unidades: entrada_Unidades ?? this.entrada_Unidades,
      entrada_Costo: entrada_Costo ?? this.entrada_Costo,
      entrada_Fecha: entrada_Fecha ?? this.entrada_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_Proveedor: id_Proveedor ?? this.id_Proveedor,
      id_User: id_User ?? this.id_User,
      id_Junta: id_Junta ?? this.id_Junta,
      id_Entidad: id_Entidad ?? this.id_Entidad,
      user_Reporte: user_Reporte ?? this.user_Reporte,
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
      'id_User': id_User,
      'id_Junta': id_Junta,
      'id_Entidad': id_Entidad,
      'user_Reporte': user_Reporte,
    };
  }

  factory Entradas.fromMap(Map<String, dynamic> map) {
    return Entradas(
      id_Entradas:
          map['id_Entradas'] != null ? map['id_Entradas'] as int : null,
      entrada_Folio:
          map['entrada_Folio'] != null ? map['entrada_Folio'] as String : null,
      entrada_Unidades: map['entrada_Unidades'] != null
          ? (map['entrada_Unidades'] is int
              ? (map['entrada_Unidades'] as int).toDouble()
              : map['entrada_Unidades'] as double)
          : null,
      entrada_Costo: map['entrada_Costo'] != null
          ? (map['entrada_Costo'] is int
              ? (map['entrada_Costo'] as int).toDouble()
              : map['entrada_Costo'] as double)
          : null,
      entrada_Fecha:
          map['entrada_Fecha'] != null ? map['entrada_Fecha'] as String : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_Proveedor:
          map['id_Proveedor'] != null ? map['id_Proveedor'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      id_Entidad: map['id_Entidad'] != null ? map['id_Entidad'] as int : null,
      user_Reporte:
          map['user_Reporte'] != null ? map['user_Reporte'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Entradas.fromJson(String source) =>
      Entradas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Entradas(id_Entradas: $id_Entradas, entrada_Folio: $entrada_Folio, entrada_Unidades: $entrada_Unidades, entrada_Costo: $entrada_Costo, entrada_Fecha: $entrada_Fecha, id_Producto: $id_Producto, id_Proveedor: $id_Proveedor, id_User: $id_User, id_Junta: $id_Junta, id_Entidad: $id_Entidad, user_Reporte: $user_Reporte)';
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
        other.id_Proveedor == id_Proveedor &&
        other.id_User == id_User &&
        other.id_Junta == id_Junta &&
        other.id_Entidad == id_Entidad &&
        other.user_Reporte == user_Reporte;
  }

  @override
  int get hashCode {
    return id_Entradas.hashCode ^
        entrada_Folio.hashCode ^
        entrada_Unidades.hashCode ^
        entrada_Costo.hashCode ^
        entrada_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_Proveedor.hashCode ^
        id_User.hashCode ^
        id_Junta.hashCode ^
        id_Entidad.hashCode ^
        user_Reporte.hashCode;
  }
}
