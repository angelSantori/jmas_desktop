// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class SalidasController {
  final AuthService _authService = AuthService();
  static List<Salidas>? cacheSalidas;

  Future<List<Salidas>> listSalidas() async {
    if (cacheSalidas != null) {
      return cacheSalidas!;
    }
    try {
      final response =
          await http.get(Uri.parse('${_authService.apiURL}/Salidas'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((salida) => Salidas.fromMap(salida)).toList();
      } else {
        print(
            'Error al obtener la lista de salidas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista salidas: $e');
      return [];
    }
  }

  Future<bool> addSalida(Salidas salida) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Salidas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: salida.toJson(),
      );

      if (response.statusCode == 201) {
        cacheSalidas = null;
        return true;
      } else {
        print(
            'Error al crear salida: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al crear salida: $e');
      return false;
    }
  }

  Future<List<Salidas>> getSalidaByFolio(String folio) async {
    try {
      final response = await http.get(
          Uri.parse('${_authService.apiURL}/Salidas/ByFolio/$folio'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((salida) => Salidas.fromMap(salida)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton salidas con el folio: $folio');
        return [];
      } else {
        print(
            'Error al obtener las entradas por folio: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener las salidas poe folio: $e');
      return [];
    }
  }

  Future<String> getNextSalidaCodFolio() async {
    final response = await http.get(
      Uri.parse('${_authService.apiURL}/Salidas/next-salidacodfolio'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Error al obtener el próximo SalidaCodFolio: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

class Salidas {
  int? id_Salida;
  String? salida_CodFolio;
  String? salida_Referencia;
  double? salida_Unidades;
  double? salida_Costo;
  String? salida_Fecha;
  int? idProducto;
  int? id_User;
  int? id_Junta;
  int? id_Almacen;
  int? id_User_Asignado;
  Salidas({
    this.id_Salida,
    this.salida_CodFolio,
    this.salida_Referencia,
    this.salida_Unidades,
    this.salida_Costo,
    this.salida_Fecha,
    this.idProducto,
    this.id_User,
    this.id_Junta,
    this.id_Almacen,
    this.id_User_Asignado,
  });

  Salidas copyWith({
    int? id_Salida,
    String? salida_CodFolio,
    String? salida_Referencia,
    double? salida_Unidades,
    double? salida_Costo,
    String? salida_Fecha,
    int? idProducto,
    int? id_User,
    int? id_Junta,
    int? id_Almacen,
    int? id_User_Asignado,
  }) {
    return Salidas(
      id_Salida: id_Salida ?? this.id_Salida,
      salida_CodFolio: salida_CodFolio ?? this.salida_CodFolio,
      salida_Referencia: salida_Referencia ?? this.salida_Referencia,
      salida_Unidades: salida_Unidades ?? this.salida_Unidades,
      salida_Costo: salida_Costo ?? this.salida_Costo,
      salida_Fecha: salida_Fecha ?? this.salida_Fecha,
      idProducto: idProducto ?? this.idProducto,
      id_User: id_User ?? this.id_User,
      id_Junta: id_Junta ?? this.id_Junta,
      id_Almacen: id_Almacen ?? this.id_Almacen,
      id_User_Asignado: id_User_Asignado ?? this.id_User_Asignado,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Salida': id_Salida,
      'salida_CodFolio': salida_CodFolio,
      'salida_Referencia': salida_Referencia,
      'salida_Unidades': salida_Unidades,
      'salida_Costo': salida_Costo,
      'salida_Fecha': salida_Fecha,
      'idProducto': idProducto,
      'id_User': id_User,
      'id_Junta': id_Junta,
      'id_Almacen': id_Almacen,
      'id_User_Asignado': id_User_Asignado,
    };
  }

  factory Salidas.fromMap(Map<String, dynamic> map) {
    return Salidas(
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      salida_CodFolio: map['salida_CodFolio'] != null
          ? map['salida_CodFolio'] as String
          : null,
      salida_Referencia: map['salida_Referencia'] != null
          ? map['salida_Referencia'] as String
          : null,
      salida_Unidades: map['salida_Unidades'] != null
          ? (map['salida_Unidades'] is int
              ? (map['salida_Unidades'] as int).toDouble()
              : map['salida_Unidades'] as double)
          : null,
      salida_Costo: map['salida_Costo'] != null
          ? (map['salida_Costo'] is int
              ? (map['salida_Costo'] as int).toDouble()
              : map['salida_Costo'] as double)
          : null,
      salida_Fecha:
          map['salida_Fecha'] != null ? map['salida_Fecha'] as String : null,
      idProducto: map['idProducto'] != null ? map['idProducto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
      id_User_Asignado: map['id_User_Asignado'] != null
          ? map['id_User_Asignado'] as int
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Salidas.fromJson(String source) =>
      Salidas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Salidas(id_Salida: $id_Salida, salida_CodFolio: $salida_CodFolio, salida_Referencia: $salida_Referencia, salida_Unidades: $salida_Unidades, salida_Costo: $salida_Costo, salida_Fecha: $salida_Fecha, idProducto: $idProducto, id_User: $id_User, id_Junta: $id_Junta, id_Almacen: $id_Almacen, id_User_Asignado: $id_User_Asignado)';
  }

  @override
  bool operator ==(covariant Salidas other) {
    if (identical(this, other)) return true;

    return other.id_Salida == id_Salida &&
        other.salida_CodFolio == salida_CodFolio &&
        other.salida_Referencia == salida_Referencia &&
        other.salida_Unidades == salida_Unidades &&
        other.salida_Costo == salida_Costo &&
        other.salida_Fecha == salida_Fecha &&
        other.idProducto == idProducto &&
        other.id_User == id_User &&
        other.id_Junta == id_Junta &&
        other.id_Almacen == id_Almacen &&
        other.id_User_Asignado == id_User_Asignado;
  }

  @override
  int get hashCode {
    return id_Salida.hashCode ^
        salida_CodFolio.hashCode ^
        salida_Referencia.hashCode ^
        salida_Unidades.hashCode ^
        salida_Costo.hashCode ^
        salida_Fecha.hashCode ^
        idProducto.hashCode ^
        id_User.hashCode ^
        id_Junta.hashCode ^
        id_Almacen.hashCode ^
        id_User_Asignado.hashCode;
  }
}
