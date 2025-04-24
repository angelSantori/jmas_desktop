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

  //GetByName
  Future<List<Padron>> getByNombre(String nombre) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/Padrons/BuscarPorNombre?nombre=$nombre'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Padron.fromMap(json)).toList();
      } else {
        print(
            'Error al buscar nombre Ife | GetByName | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al buscar nombre Try | GetByName | Controller: $e');
      return [];
    }
  }

  //GetByDireccion
  Future<List<Padron>> getByDireccion(String direccion) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/Padrons/BuscarPorDireccion?direccion=$direccion'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Padron.fromMap(json)).toList();
      } else {
        print(
            'Error al buscar dirección Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al buscar dirección Try | Controller: $e');
      return [];
    }
  }

  //GetBuscar
  Future<List<Padron>> getBuscar(String termino) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Padrons/Buscar?termino=$termino'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Padron.fromMap(json)).toList();
      } else {
        print(
            'Error al buscar Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al buscar Try | Controller: $e');
      return [];
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
