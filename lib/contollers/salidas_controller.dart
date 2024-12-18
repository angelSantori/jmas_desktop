import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:jmas_desktop/service/auth_service.dart';

class SalidasController {
  AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<Salidas>> listSalidas() async {
    try {
      final IOClient client = _createHttpClient();
      final response = await client
          .get(Uri.parse('${_authService.apiURL}/Salidas'), headers: {
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
    final IOClient client = _createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('${_authService.apiURL}/Salidas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: salida.toJson(),
      );

      if (response.statusCode == 201) {
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
}

class Salidas {
  int? id_Salida;
  String? salida_Folio;
  double? salida_Unidades;
  double? salida_Costo;
  String? salida_Fecha;
  int? id_Producto;
  int? id_Proveedor;
  int? id_User;
  int? id_Junta;
  int? id_Entidad;
  Salidas({
    this.id_Salida,
    this.salida_Folio,
    this.salida_Unidades,
    this.salida_Costo,
    this.salida_Fecha,
    this.id_Producto,
    this.id_Proveedor,
    this.id_User,
    this.id_Junta,
    this.id_Entidad,
  });

  Salidas copyWith({
    int? id_Salida,
    String? salida_Folio,
    double? salida_Unidades,
    double? salida_Costo,
    String? salida_Fecha,
    int? id_Producto,
    int? id_Proveedor,
    int? id_User,
    int? id_Junta,
    int? id_Entidad,
  }) {
    return Salidas(
      id_Salida: id_Salida ?? this.id_Salida,
      salida_Folio: salida_Folio ?? this.salida_Folio,
      salida_Unidades: salida_Unidades ?? this.salida_Unidades,
      salida_Costo: salida_Costo ?? this.salida_Costo,
      salida_Fecha: salida_Fecha ?? this.salida_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_Proveedor: id_Proveedor ?? this.id_Proveedor,
      id_User: id_User ?? this.id_User,
      id_Junta: id_Junta ?? this.id_Junta,
      id_Entidad: id_Entidad ?? this.id_Entidad,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Salida': id_Salida,
      'salida_Folio': salida_Folio,
      'salida_Unidades': salida_Unidades,
      'salida_Costo': salida_Costo,
      'salida_Fecha': salida_Fecha,
      'id_Producto': id_Producto,
      'id_Proveedor': id_Proveedor,
      'id_User': id_User,
      'id_Junta': id_Junta,
      'id_Entidad': id_Entidad,
    };
  }

  factory Salidas.fromMap(Map<String, dynamic> map) {
    return Salidas(
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      salida_Folio:
          map['salida_Folio'] != null ? map['salida_Folio'] as String : null,
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
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_Proveedor:
          map['id_Proveedor'] != null ? map['id_Proveedor'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      id_Entidad: map['id_Entidad'] != null ? map['id_Entidad'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Salidas.fromJson(String source) =>
      Salidas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Salidas(id_Salida: $id_Salida, salida_Folio: $salida_Folio, salida_Unidades: $salida_Unidades, salida_Costo: $salida_Costo, salida_Fecha: $salida_Fecha, id_Producto: $id_Producto, id_Proveedor: $id_Proveedor, id_User: $id_User, id_Junta: $id_Junta, id_Entidad: $id_Entidad)';
  }

  @override
  bool operator ==(covariant Salidas other) {
    if (identical(this, other)) return true;

    return other.id_Salida == id_Salida &&
        other.salida_Folio == salida_Folio &&
        other.salida_Unidades == salida_Unidades &&
        other.salida_Costo == salida_Costo &&
        other.salida_Fecha == salida_Fecha &&
        other.id_Producto == id_Producto &&
        other.id_Proveedor == id_Proveedor &&
        other.id_User == id_User &&
        other.id_Junta == id_Junta &&
        other.id_Entidad == id_Entidad;
  }

  @override
  int get hashCode {
    return id_Salida.hashCode ^
        salida_Folio.hashCode ^
        salida_Unidades.hashCode ^
        salida_Costo.hashCode ^
        salida_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_Proveedor.hashCode ^
        id_User.hashCode ^
        id_Junta.hashCode ^
        id_Entidad.hashCode;
  }
}
