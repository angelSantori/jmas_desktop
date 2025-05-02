//Librerías
import 'dart:convert';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;

class CallesController {
  final AuthService _authService = AuthService();
  static List<Calles>? cacheCalles;

  //Lista calles
  Future<List<Calles>> listCalles() async {
    if (cacheCalles != null) return cacheCalles!;

    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Calles'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((calleList) => Calles.fromMap(calleList)).toList();
      } else {
        print(
            'Error lista Calle | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista Calles | Try | Controller: $e');
      return [];
    }
  }

  //Add
  Future<bool> addCalles(Calles calle) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Calles'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: calle.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al add Calle | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al add Calle | Try | Controller: $e');
      return false;
    }
  }

  //Edit
  Future<bool> editCalles(Calles calle) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Calles/${calle.idCalle}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: calle.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al edit Calle | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al edit Calle | Try | Controller: $e');
      return false;
    }
  }
}

class Calles {
  int? idCalle;
  String? calleNombre;
  Calles({
    this.idCalle,
    this.calleNombre,
  });

  Calles copyWith({
    int? idCalle,
    String? calleNombre,
  }) {
    return Calles(
      idCalle: idCalle ?? this.idCalle,
      calleNombre: calleNombre ?? this.calleNombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCalle': idCalle,
      'calleNombre': calleNombre,
    };
  }

  factory Calles.fromMap(Map<String, dynamic> map) {
    return Calles(
      idCalle: map['idCalle'] != null ? map['idCalle'] as int : null,
      calleNombre:
          map['calleNombre'] != null ? map['calleNombre'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Calles.fromJson(String source) =>
      Calles.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Calles(idCalle: $idCalle, calleNombre: $calleNombre)';

  @override
  bool operator ==(covariant Calles other) {
    if (identical(this, other)) return true;

    return other.idCalle == idCalle && other.calleNombre == calleNombre;
  }

  @override
  int get hashCode => idCalle.hashCode ^ calleNombre.hashCode;
}
