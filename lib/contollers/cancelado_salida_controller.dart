import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class CanceladoSalidaController {
  final AuthService _authService = AuthService();

  Future<bool> addCancelSalida(CanceladoSalidas cancelSalida) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/CanceladoSalidas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: cancelSalida.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al agregar cancelación salida | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al agregar canclación Salida | TryCatch | Controller: $e');
      return false;
    }
  }

  Future<List<CanceladoSalidas>> listCanceladoSalida() async {
    try {
      final response = await http
          .get(Uri.parse('${_authService.apiNubeURL}/CanceladoSalidas'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((canceladoSalida) => CanceladoSalidas.fromMap(canceladoSalida))
            .toList();
      } else {
        print(
            'Error al obtener lista cancelaciones salida | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Error al obtener lista cancelaciones salida | TryCatch | Controller: $e');
      return [];
    }
  }
}

class CanceladoSalidas {
  int? idCanceladoSalida;
  String? cancelSalidaMotivo;
  String? cancelSalidaFecha;
  int? id_Salida;
  int? id_User;
  CanceladoSalidas({
    this.idCanceladoSalida,
    this.cancelSalidaMotivo,
    this.cancelSalidaFecha,
    this.id_Salida,
    this.id_User,
  });

  CanceladoSalidas copyWith({
    int? idCanceladoSalida,
    String? cancelSalidaMotivo,
    String? cancelSalidaFecha,
    int? id_Salida,
    int? id_User,
  }) {
    return CanceladoSalidas(
      idCanceladoSalida: idCanceladoSalida ?? this.idCanceladoSalida,
      cancelSalidaMotivo: cancelSalidaMotivo ?? this.cancelSalidaMotivo,
      cancelSalidaFecha: cancelSalidaFecha ?? this.cancelSalidaFecha,
      id_Salida: id_Salida ?? this.id_Salida,
      id_User: id_User ?? this.id_User,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCanceladoSalida': idCanceladoSalida,
      'cancelSalidaMotivo': cancelSalidaMotivo,
      'cancelSalidaFecha': cancelSalidaFecha,
      'id_Salida': id_Salida,
      'id_User': id_User,
    };
  }

  factory CanceladoSalidas.fromMap(Map<String, dynamic> map) {
    return CanceladoSalidas(
      idCanceladoSalida: map['idCanceladoSalida'] != null
          ? map['idCanceladoSalida'] as int
          : null,
      cancelSalidaMotivo: map['cancelSalidaMotivo'] != null
          ? map['cancelSalidaMotivo'] as String
          : null,
      cancelSalidaFecha: map['cancelSalidaFecha'] != null
          ? map['cancelSalidaFecha'] as String
          : null,
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CanceladoSalidas.fromJson(String source) =>
      CanceladoSalidas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CanceladoSalidas(idCanceladoSalida: $idCanceladoSalida, cancelSalidaMotivo: $cancelSalidaMotivo, cancelSalidaFecha: $cancelSalidaFecha, id_Salida: $id_Salida, id_User: $id_User)';
  }

  @override
  bool operator ==(covariant CanceladoSalidas other) {
    if (identical(this, other)) return true;

    return other.idCanceladoSalida == idCanceladoSalida &&
        other.cancelSalidaMotivo == cancelSalidaMotivo &&
        other.cancelSalidaFecha == cancelSalidaFecha &&
        other.id_Salida == id_Salida &&
        other.id_User == id_User;
  }

  @override
  int get hashCode {
    return idCanceladoSalida.hashCode ^
        cancelSalidaMotivo.hashCode ^
        cancelSalidaFecha.hashCode ^
        id_Salida.hashCode ^
        id_User.hashCode;
  }
}
