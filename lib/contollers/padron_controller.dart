import 'dart:convert';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;

class PadronController {
  AuthService _authService = AuthService();
  static List<Padron>? cachePadron;

  //List padron
  Future<List<Padron>> listPadron() async {
    if (cachePadron != null) {
      return cachePadron!;
    }
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Padrons'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((padronList) => Padron.fromMap(padronList))
            .toList();
      } else {
        print(
            'Error lista Padron | Ife | Controlles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista Padron | TryCatch | Controller: $e');
      return [];
    }
  }

  //Edit padron
  Future<bool> editPadron(Padron padron) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Padrons/${padron.idPadron}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: padron.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar padron ife | editPadron | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar padron tryCatch | editPadron | Controller : $e');
      return false;
    }
  }
}

class Padron {
  int? idPadron;
  String? padronNombre;
  String? padronDireccion;
  Padron({
    this.idPadron,
    this.padronNombre,
    this.padronDireccion,
  });

  Padron copyWith({
    int? idPadron,
    String? padronNombre,
    String? padronDireccion,
  }) {
    return Padron(
      idPadron: idPadron ?? this.idPadron,
      padronNombre: padronNombre ?? this.padronNombre,
      padronDireccion: padronDireccion ?? this.padronDireccion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idPadron': idPadron,
      'padronNombre': padronNombre,
      'padronDireccion': padronDireccion,
    };
  }

  factory Padron.fromMap(Map<String, dynamic> map) {
    return Padron(
      idPadron: map['idPadron'] != null ? map['idPadron'] as int : null,
      padronNombre:
          map['padronNombre'] != null ? map['padronNombre'] as String : null,
      padronDireccion: map['padronDireccion'] != null
          ? map['padronDireccion'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Padron.fromJson(String source) =>
      Padron.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Padron(idPadron: $idPadron, padronNombre: $padronNombre, padronDireccion: $padronDireccion)';

  @override
  bool operator ==(covariant Padron other) {
    if (identical(this, other)) return true;

    return other.idPadron == idPadron &&
        other.padronNombre == padronNombre &&
        other.padronDireccion == padronDireccion;
  }

  @override
  int get hashCode =>
      idPadron.hashCode ^ padronNombre.hashCode ^ padronDireccion.hashCode;
}
