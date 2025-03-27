import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class CanceladoController {
  final AuthService _authService = AuthService();

  Future<bool> addCancelacion(Cancelados cancelado) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Cancelados'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: cancelado.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al agregar cancelación|Controller|Add: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error cancelación cancelado|Controller|Add: $e');
      return false;
    }
  }

  Future<List<Cancelados>> listCancelaciones() async {
    try {
      final response = await http
          .get(Uri.parse('${_authService.apiURL}/Cancelados'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((cancelado) => Cancelados.fromMap(cancelado))
            .toList();
      } else {
        print(
            'Error al obtener lista de cancelaciones|Controller|List: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista cancelaciónes|Controller|List: $e');
      return [];
    }
  }
}

class Cancelados {
  int? idCancelacion;
  String? cancelMotivo;
  String? cancelFecha;
  int? id_Entrada;
  int? id_User;
  Cancelados({
    this.idCancelacion,
    this.cancelMotivo,
    this.cancelFecha,
    this.id_Entrada,
    this.id_User,
  });

  Cancelados copyWith({
    int? idCancelacion,
    String? cancelMotivo,
    String? cancelFecha,
    int? id_Entrada,
    int? id_User,
  }) {
    return Cancelados(
      idCancelacion: idCancelacion ?? this.idCancelacion,
      cancelMotivo: cancelMotivo ?? this.cancelMotivo,
      cancelFecha: cancelFecha ?? this.cancelFecha,
      id_Entrada: id_Entrada ?? this.id_Entrada,
      id_User: id_User ?? this.id_User,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCancelacion': idCancelacion,
      'cancelMotivo': cancelMotivo,
      'cancelFecha': cancelFecha,
      'id_Entrada': id_Entrada,
      'id_User': id_User,
    };
  }

  factory Cancelados.fromMap(Map<String, dynamic> map) {
    return Cancelados(
      idCancelacion:
          map['idCancelacion'] != null ? map['idCancelacion'] as int : null,
      cancelMotivo:
          map['cancelMotivo'] != null ? map['cancelMotivo'] as String : null,
      cancelFecha:
          map['cancelFecha'] != null ? map['cancelFecha'] as String : null,
      id_Entrada: map['id_Entrada'] != null ? map['id_Entrada'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cancelados.fromJson(String source) =>
      Cancelados.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Cancelados(idCancelacion: $idCancelacion, cancelMotivo: $cancelMotivo, cancelFecha: $cancelFecha, id_Entrada: $id_Entrada, id_User: $id_User)';
  }

  @override
  bool operator ==(covariant Cancelados other) {
    if (identical(this, other)) return true;

    return other.idCancelacion == idCancelacion &&
        other.cancelMotivo == cancelMotivo &&
        other.cancelFecha == cancelFecha &&
        other.id_Entrada == id_Entrada &&
        other.id_User == id_User;
  }

  @override
  int get hashCode {
    return idCancelacion.hashCode ^
        cancelMotivo.hashCode ^
        cancelFecha.hashCode ^
        id_Entrada.hashCode ^
        id_User.hashCode;
  }
}
