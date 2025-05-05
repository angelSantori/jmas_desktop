//Librerías
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class HerramientasController {
  final AuthService _authService = AuthService();
  static List<Herramientas>? cacheHerramientas;

  //List
  Future<List<Herramientas>> lsitHtas() async {
    if (cacheHerramientas != null) return cacheHerramientas!;

    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Herramientas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((htaList) => Herramientas.fromMap(htaList))
            .toList();
      } else {
        print(
            'Error listHtas | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listHtas | Try | Controller: $e');
      return [];
    }
  }

  //GetXId
  Future<Herramientas?> getHtaXId(int idHta) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Herramientas/$idHta'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return Herramientas.fromMap(jsonData);
      } else if (response.statusCode == 404) {
        print('Herramienta no encontrada con ID: $idHta | Ife | Controller');
        return null;
      } else {
        print(
            'Error htaXId | Ife | Controller: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error htaXId | Try | Controller: $e');
      return null;
    }
  }

  //GetXNombre
  Future<List<Herramientas>> getHtaXNombre(String hatNombre) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/Herramientas/BuscarPorNombre?nombreHta=$hatNombre'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((hta) => Herramientas.fromMap(hta)).toList();
      } else {
        print(
            'Error htaXNombre | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error htaXNombre | Try | Controller: $e');
      return [];
    }
  }

  //AddHta
  Future<bool> addHta(Herramientas herramienta) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Herramientas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: herramienta.toJson(),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addHta | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addHta | Try | Controller: $e');
      return false;
    }
  }

  //EditHta
  Future<bool> editHta(Herramientas herramienta) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/Herramientas/${herramienta.idHerramienta}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: herramienta.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error editHta | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error editHta | Try | Controller: $e');
      return false;
    }
  }
}

class Herramientas {
  int? idHerramienta;
  String? htaNombre;
  String? htaEstado;
  Herramientas({
    this.idHerramienta,
    this.htaNombre,
    this.htaEstado,
  });

  Herramientas copyWith({
    int? idHerramienta,
    String? htaNombre,
    String? htaEstado,
  }) {
    return Herramientas(
      idHerramienta: idHerramienta ?? this.idHerramienta,
      htaNombre: htaNombre ?? this.htaNombre,
      htaEstado: htaEstado ?? this.htaEstado,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idHerramienta': idHerramienta,
      'htaNombre': htaNombre,
      'htaEstado': htaEstado,
    };
  }

  factory Herramientas.fromMap(Map<String, dynamic> map) {
    return Herramientas(
      idHerramienta:
          map['idHerramienta'] != null ? map['idHerramienta'] as int : null,
      htaNombre: map['htaNombre'] != null ? map['htaNombre'] as String : null,
      htaEstado: map['htaEstado'] != null ? map['htaEstado'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Herramientas.fromJson(String source) =>
      Herramientas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Herramientas(idHerramienta: $idHerramienta, htaNombre: $htaNombre, htaEstado: $htaEstado)';

  @override
  bool operator ==(covariant Herramientas other) {
    if (identical(this, other)) return true;

    return other.idHerramienta == idHerramienta &&
        other.htaNombre == htaNombre &&
        other.htaEstado == htaEstado;
  }

  @override
  int get hashCode =>
      idHerramienta.hashCode ^ htaNombre.hashCode ^ htaEstado.hashCode;
}
