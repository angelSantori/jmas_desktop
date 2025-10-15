import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class PresupuestosController {
  final AuthService _authService = AuthService();

  Future<List<Presupuestos>> getPresupuestos() async {
    try {
      final response = await http.get(
          Uri.parse('${_authService.apiURL}/Presupuestos'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'});

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listPre) => Presupuestos.fromMap(listPre))
            .toList();
      } else {
        print(
            'Error listPresupuestos | Ife | PresupuestosController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listPresupuestos | Try | PresupuestosController: $e');
      return [];
    }
  }

  Future<List<Presupuestos>> getPresupuestoByFolio(String preFolio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Presupuestos/ByFolio/$preFolio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listPreFolios) => Presupuestos.fromMap(listPreFolios))
            .toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton presupuestos con el folio: $preFolio');
        return [];
      } else {
        print(
            'Error getPresupuestoByFolio | Ife | PresupuestoController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getPresupuestoByFolio | Try | PresupuestoController: $e');
      return [];
    }
  }

  Future<List<Presupuestos>?> postPresupuestosMultiple(
      List<Presupuestos> presupuestos) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Presupuestos/Multiple'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(presupuestos.map((pre) => pre.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => Presupuestos.fromMap(data)).toList();
      } else {
        print(
            'Error postPresupuestoMultiple | Ife | PresupuestosController: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error postPresupuestoMultiple | Try | PresupuestosController: $e');
      return null;
    }
  }

  Future<List<Presupuestos>?> updatePresupuestosMultiple(
      List<Presupuestos> presupuestos) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Presupuestos/UpdateMultiple'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(presupuestos.map((pre) => pre.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => Presupuestos.fromMap(data)).toList();
      } else {
        print(
            'Error updatePresupuestosMultiple | Ife | PresupuestosController: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(
          'Error updatePresupuestosMultiple | Try | PresupuestosController: $e');
      return null;
    }
  }
}

class Presupuestos {
  final int idPresupuesto;
  final String presupuestoFolio;
  final String presupuestoFecha;
  final bool presupuestoEstado;
  final double presupuestoUnidades;
  final double presupuestoTotal;
  final int idUser;
  final int idPadron;
  final int idProducto;
  Presupuestos({
    required this.idPresupuesto,
    required this.presupuestoFolio,
    required this.presupuestoFecha,
    required this.presupuestoEstado,
    required this.presupuestoUnidades,
    required this.presupuestoTotal,
    required this.idUser,
    required this.idPadron,
    required this.idProducto,
  });

  Presupuestos copyWith({
    int? idPresupuesto,
    String? presupuestoFolio,
    String? presupuestoFecha,
    bool? presupuestoEstado,
    double? presupuestoUnidades,
    double? presupuestoTotal,
    int? idUser,
    int? idPadron,
    int? idProducto,
  }) {
    return Presupuestos(
      idPresupuesto: idPresupuesto ?? this.idPresupuesto,
      presupuestoFolio: presupuestoFolio ?? this.presupuestoFolio,
      presupuestoFecha: presupuestoFecha ?? this.presupuestoFecha,
      presupuestoEstado: presupuestoEstado ?? this.presupuestoEstado,
      presupuestoUnidades: presupuestoUnidades ?? this.presupuestoUnidades,
      presupuestoTotal: presupuestoTotal ?? this.presupuestoTotal,
      idUser: idUser ?? this.idUser,
      idPadron: idPadron ?? this.idPadron,
      idProducto: idProducto ?? this.idProducto,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idPresupuesto': idPresupuesto,
      'presupuestoFolio': presupuestoFolio,
      'presupuestoFecha': presupuestoFecha,
      'presupuestoEstado': presupuestoEstado,
      'presupuestoUnidades': presupuestoUnidades,
      'presupuestoTotal': presupuestoTotal,
      'idUser': idUser,
      'idPadron': idPadron,
      'idProducto': idProducto,
    };
  }

  factory Presupuestos.fromMap(Map<String, dynamic> map) {
    return Presupuestos(
      idPresupuesto: map['idPresupuesto'] as int,
      presupuestoFolio: map['presupuestoFolio'] as String,
      presupuestoFecha: map['presupuestoFecha'] as String,
      presupuestoEstado: map['presupuestoEstado'] as bool,
      presupuestoUnidades: map['presupuestoUnidades'] as double,
      presupuestoTotal: map['presupuestoTotal'] as double,
      idUser: map['idUser'] as int,
      idPadron: map['idPadron'] as int,
      idProducto: map['idProducto'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Presupuestos.fromJson(String source) =>
      Presupuestos.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Presupuestos(idPresupuesto: $idPresupuesto, presupuestoFolio: $presupuestoFolio, presupuestoFecha: $presupuestoFecha, presupuestoEstado: $presupuestoEstado, presupuestoUnidades: $presupuestoUnidades, presupuestoTotal: $presupuestoTotal, idUser: $idUser, idPadron: $idPadron, idProducto: $idProducto)';
  }

  @override
  bool operator ==(covariant Presupuestos other) {
    if (identical(this, other)) return true;

    return other.idPresupuesto == idPresupuesto &&
        other.presupuestoFolio == presupuestoFolio &&
        other.presupuestoFecha == presupuestoFecha &&
        other.presupuestoEstado == presupuestoEstado &&
        other.presupuestoUnidades == presupuestoUnidades &&
        other.presupuestoTotal == presupuestoTotal &&
        other.idUser == idUser &&
        other.idPadron == idPadron &&
        other.idProducto == idProducto;
  }

  @override
  int get hashCode {
    return idPresupuesto.hashCode ^
        presupuestoFolio.hashCode ^
        presupuestoFecha.hashCode ^
        presupuestoEstado.hashCode ^
        presupuestoUnidades.hashCode ^
        presupuestoTotal.hashCode ^
        idUser.hashCode ^
        idPadron.hashCode ^
        idProducto.hashCode;
  }
}
