// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class EntradasController {
  final AuthService _authService = AuthService();

  // GET
  // List
  Future<List<Entradas>> listEntradas() async {
    try {
      final response = await http.get(
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

  // EntradaXProducto
  Future<List<Entradas>> listEntradaXProducto(int productoID) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Entradas/ByProducto/$productoID'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((listExP) => Entradas.fromMap(listExP)).toList();
      } else {
        print(
            'Error listEntradaXProducto | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listEntradaXProducto | Try | Controller: $e');
      return [];
    }
  }

  Future<bool> addEntrada(Entradas entrada) async {
    try {
      final response = await http.post(
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

  Future<List<Entradas>> getEntradaByReferencia(String referencia) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Entradas/ByReferencia/$referencia'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entrada) => Entradas.fromMap(entrada)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton entradas con el referencia: $referencia');
        return [];
      } else {
        print(
            'Error al obtener las entradas por referencia: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener las entradas poe referencia: $e');
      return [];
    }
  }

  Future<List<Entradas>> getEntradaByCodFolio(String codFolio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Entradas/ByCodFolio/$codFolio'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entrada) => Entradas.fromMap(entrada)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton entradas con el referencia: $codFolio');
        return [];
      } else {
        print(
            'Error al obtener las entradas por referencia: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener las entradas poe referencia: $e');
      return [];
    }
  }

  Future<String> getNextCodFolio() async {
    final response = await http.get(
      Uri.parse('${_authService.apiURL}/Entradas/next-codfolio'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Error al obtener el próximo codFolio: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> editEntrada(Entradas entrada) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Entradas/${entrada.id_Entradas}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: entrada.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar entrada | Controller | Ife: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar entrada | Controller | Try: $e');
      return false;
    }
  }
}

class Entradas {
  int? id_Entradas;
  String? entrada_CodFolio;
  double? entrada_Unidades;
  double? entrada_Costo;
  String? entrada_Fecha;
  String? entrada_ImgB64Factura;
  String? entrada_Referencia;
  String? entrada_Comentario;
  int? entrada_NumeroFactura;
  int? idProducto;
  int? id_User;
  bool? entrada_Estado;
  int? id_Almacen;
  int? id_Proveedor;
  int? id_Junta;
  int? idEntidad;
  Entradas({
    this.id_Entradas,
    this.entrada_CodFolio,
    this.entrada_Unidades,
    this.entrada_Costo,
    this.entrada_Fecha,
    this.entrada_ImgB64Factura,
    this.entrada_Referencia,
    this.entrada_Comentario,
    this.entrada_NumeroFactura,
    this.idProducto,
    this.id_User,
    this.entrada_Estado,
    this.id_Almacen,
    this.id_Proveedor,
    this.id_Junta,
    this.idEntidad,
  });

  Entradas copyWith({
    int? id_Entradas,
    String? entrada_CodFolio,
    double? entrada_Unidades,
    double? entrada_Costo,
    String? entrada_Fecha,
    String? entrada_ImgB64Factura,
    String? entrada_Referencia,
    String? entrada_Comentario,
    int? entrada_NumeroFactura,
    int? idProducto,
    int? id_User,
    bool? entrada_Estado,
    int? id_Almacen,
    int? id_Proveedor,
    int? id_Junta,
    int? idEntidad,
  }) {
    return Entradas(
      id_Entradas: id_Entradas ?? this.id_Entradas,
      entrada_CodFolio: entrada_CodFolio ?? this.entrada_CodFolio,
      entrada_Unidades: entrada_Unidades ?? this.entrada_Unidades,
      entrada_Costo: entrada_Costo ?? this.entrada_Costo,
      entrada_Fecha: entrada_Fecha ?? this.entrada_Fecha,
      entrada_ImgB64Factura:
          entrada_ImgB64Factura ?? this.entrada_ImgB64Factura,
      entrada_Referencia: entrada_Referencia ?? this.entrada_Referencia,
      entrada_Comentario: entrada_Comentario ?? this.entrada_Comentario,
      entrada_NumeroFactura:
          entrada_NumeroFactura ?? this.entrada_NumeroFactura,
      idProducto: idProducto ?? this.idProducto,
      id_User: id_User ?? this.id_User,
      entrada_Estado: entrada_Estado ?? this.entrada_Estado,
      id_Almacen: id_Almacen ?? this.id_Almacen,
      id_Proveedor: id_Proveedor ?? this.id_Proveedor,
      id_Junta: id_Junta ?? this.id_Junta,
      idEntidad: idEntidad ?? this.idEntidad,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Entradas': id_Entradas,
      'entrada_CodFolio': entrada_CodFolio,
      'entrada_Unidades': entrada_Unidades,
      'entrada_Costo': entrada_Costo,
      'entrada_Fecha': entrada_Fecha,
      'entrada_ImgB64Factura': entrada_ImgB64Factura,
      'entrada_Referencia': entrada_Referencia,
      'entrada_Comentario': entrada_Comentario,
      'entrada_NumeroFactura': entrada_NumeroFactura,
      'idProducto': idProducto,
      'id_User': id_User,
      'entrada_Estado': entrada_Estado,
      'id_Almacen': id_Almacen,
      'id_Proveedor': id_Proveedor,
      'id_Junta': id_Junta,
      'idEntidad': idEntidad,
    };
  }

  factory Entradas.fromMap(Map<String, dynamic> map) {
    return Entradas(
      id_Entradas:
          map['id_Entradas'] != null ? map['id_Entradas'] as int : null,
      entrada_CodFolio: map['entrada_CodFolio'] != null
          ? map['entrada_CodFolio'] as String
          : null,
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
      entrada_ImgB64Factura: map['entrada_ImgB64Factura'] != null
          ? map['entrada_ImgB64Factura'] as String
          : null,
      entrada_Referencia: map['entrada_Referencia'] != null
          ? map['entrada_Referencia'] as String
          : null,
      entrada_Comentario: map['entrada_Comentario'] != null
          ? map['entrada_Comentario'] as String
          : null,
      entrada_NumeroFactura: map['entrada_NumeroFactura'] != null
          ? map['entrada_NumeroFactura'] as int
          : null,
      idProducto: map['idProducto'] != null ? map['idProducto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      entrada_Estado:
          map['entrada_Estado'] != null ? map['entrada_Estado'] as bool : null,
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
      id_Proveedor:
          map['id_Proveedor'] != null ? map['id_Proveedor'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      idEntidad: map['idEntidad'] != null ? map['idEntidad'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Entradas.fromJson(String source) =>
      Entradas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Entradas(id_Entradas: $id_Entradas, entrada_CodFolio: $entrada_CodFolio, entrada_Unidades: $entrada_Unidades, entrada_Costo: $entrada_Costo, entrada_Fecha: $entrada_Fecha, entrada_ImgB64Factura: $entrada_ImgB64Factura, entrada_Referencia: $entrada_Referencia, entrada_Comentario: $entrada_Comentario, entrada_NumeroFactura: $entrada_NumeroFactura, idProducto: $idProducto, id_User: $id_User, entrada_Estado: $entrada_Estado, id_Almacen: $id_Almacen, id_Proveedor: $id_Proveedor, id_Junta: $id_Junta, idEntidad: $idEntidad)';
  }

  @override
  bool operator ==(covariant Entradas other) {
    if (identical(this, other)) return true;

    return other.id_Entradas == id_Entradas &&
        other.entrada_CodFolio == entrada_CodFolio &&
        other.entrada_Unidades == entrada_Unidades &&
        other.entrada_Costo == entrada_Costo &&
        other.entrada_Fecha == entrada_Fecha &&
        other.entrada_ImgB64Factura == entrada_ImgB64Factura &&
        other.entrada_Referencia == entrada_Referencia &&
        other.entrada_Comentario == entrada_Comentario &&
        other.entrada_NumeroFactura == entrada_NumeroFactura &&
        other.idProducto == idProducto &&
        other.id_User == id_User &&
        other.entrada_Estado == entrada_Estado &&
        other.id_Almacen == id_Almacen &&
        other.id_Proveedor == id_Proveedor &&
        other.id_Junta == id_Junta &&
        other.idEntidad == idEntidad;
  }

  @override
  int get hashCode {
    return id_Entradas.hashCode ^
        entrada_CodFolio.hashCode ^
        entrada_Unidades.hashCode ^
        entrada_Costo.hashCode ^
        entrada_Fecha.hashCode ^
        entrada_ImgB64Factura.hashCode ^
        entrada_Referencia.hashCode ^
        entrada_Comentario.hashCode ^
        entrada_NumeroFactura.hashCode ^
        idProducto.hashCode ^
        id_User.hashCode ^
        entrada_Estado.hashCode ^
        id_Almacen.hashCode ^
        id_Proveedor.hashCode ^
        id_Junta.hashCode ^
        idEntidad.hashCode;
  }
}
