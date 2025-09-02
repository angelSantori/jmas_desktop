// Librerías
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class ColoniasController {
  final AuthService _authService = AuthService();
  static List<Colonias>? cacheColonias;

  //List
  Future<List<Colonias>> listColonias() async {
    if (cacheColonias != null) return cacheColonias!;

    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/Colonias'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((coloniaList) => Colonias.fromMap(coloniaList))
            .toList();
      } else {
        print(
            'Error list Colonias | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error list Colonias | Try | Controller: $e');
      return [];
    }
  }

  //GetXId
  Future<Colonias?> getColoniaById(int idColonia) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/Colonias/$idColonia'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return Colonias.fromMap(jsonData);
      } else if (response.statusCode == 404) {
        print('Colonia no encontrada con ID: $idColonia | Ife | Controller');
        return null;
      } else {
        print(
            'Error get colonia x id | Ife | Controller: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error get colonia x id | Try | Controller por ID: $e');
      return null;
    }
  }

  //GetByName
  Future<List<Colonias>> coloniaByNombre(String nombreColonia) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiNubeURL}/Colonias/BuscarPorNombre?nombreColonia=$nombreColonia'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((colonia) => Colonias.fromMap(colonia)).toList();
      } else {
        print(
            'Error al buscar coloniaByNombre | ByNombre | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al buscar Try | GetByName | Controller: $e');
      return [];
    }
  }

  //Add
  Future<bool> addColonia(Colonias colonia) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Colonias'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: colonia.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error add Colonia | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al add Colonia | Try | Controller: $e');
      return false;
    }
  }

  //Edit
  Future<bool> editColonia(Colonias colonia) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Colonias/${colonia.idColonia}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: colonia.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error edit Colonia | Try | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error edit Colonia | Try | Controller: $e');
      return false;
    }
  }
}

class Colonias {
  int? idColonia;
  String? nombreColonia;
  Colonias({
    this.idColonia,
    this.nombreColonia,
  });

  Colonias copyWith({
    int? idColonia,
    String? nombreColonia,
  }) {
    return Colonias(
      idColonia: idColonia ?? this.idColonia,
      nombreColonia: nombreColonia ?? this.nombreColonia,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idColonia': idColonia,
      'nombreColonia': nombreColonia,
    };
  }

  factory Colonias.fromMap(Map<String, dynamic> map) {
    return Colonias(
      idColonia: map['idColonia'] != null ? map['idColonia'] as int : null,
      nombreColonia:
          map['nombreColonia'] != null ? map['nombreColonia'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Colonias.fromJson(String source) =>
      Colonias.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Colonias(idColonia: $idColonia, nombreColonia: $nombreColonia)';

  @override
  bool operator ==(covariant Colonias other) {
    if (identical(this, other)) return true;

    return other.idColonia == idColonia && other.nombreColonia == nombreColonia;
  }

  @override
  int get hashCode => idColonia.hashCode ^ nombreColonia.hashCode;
}
