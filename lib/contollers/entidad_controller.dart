import 'dart:convert';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;

class EntidadController {
  final AuthService _authService = AuthService();

  Future<List<Entidad>> listEntidad() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Entidads'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entidad) => Entidad.fromMap(entidad)).toList();
      } else {
        print(
            'Error lista Entidad | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error list Entidad | TryCatch | Controller: $e');
      return [];
    }
  }
}

class Entidad {
  int? idEntidad;
  String? entidad_Nombre;
  Entidad({
    this.idEntidad,
    this.entidad_Nombre,
  });

  Entidad copyWith({
    int? idEntidad,
    String? entidad_Nombre,
  }) {
    return Entidad(
      idEntidad: idEntidad ?? this.idEntidad,
      entidad_Nombre: entidad_Nombre ?? this.entidad_Nombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idEntidad': idEntidad,
      'entidad_Nombre': entidad_Nombre,
    };
  }

  factory Entidad.fromMap(Map<String, dynamic> map) {
    return Entidad(
      idEntidad: map['idEntidad'] != null ? map['idEntidad'] as int : null,
      entidad_Nombre: map['entidad_Nombre'] != null
          ? map['entidad_Nombre'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Entidad.fromJson(String source) =>
      Entidad.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Entidad(idEntidad: $idEntidad, entidad_Nombre: $entidad_Nombre)';

  @override
  bool operator ==(covariant Entidad other) {
    if (identical(this, other)) return true;

    return other.idEntidad == idEntidad &&
        other.entidad_Nombre == entidad_Nombre;
  }

  @override
  int get hashCode => idEntidad.hashCode ^ entidad_Nombre.hashCode;
}
