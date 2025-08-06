import 'dart:convert';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;

class CapturainviniController {
  final AuthService _authService = AuthService();
  static List<Capturainvini>? cacheCapturaIni;

  //Add
  Future<bool> addCapturaFisica(Capturainvini captura) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/CapturaInvInis'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: captura.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addCapturaFisica | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addCapturaFisica | Try | Controller: $e');
      return false;
    }
  }

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
            'Error getConteoInicialByMonth | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getConteoInicialByMonth | Try | Controller: $e');
      return [];
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
