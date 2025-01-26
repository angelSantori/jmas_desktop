// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class JuntasController {
  final AuthService _authService = AuthService();

  //Add junta
  Future<bool> addJunta(Juntas junta) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Juntas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: junta.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Errir al agregar junta: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al agregar junta desde controller: $e');
      return false;
    }
  }

  //Lista Juntas
  Future<List<Juntas>> listJuntas() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Juntas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((junta) => Juntas.fromMap(junta)).toList();
      } else {
        print(
            'Error al obtener lista de juntas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista de juntas: $e');
      return [];
    }
  }

  Future<bool> editJunta(Juntas junta) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Juntas/${junta.id_Junta}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: junta.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar junta: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar junta desde controller: $e');
      return false;
    }
  }
}

class Juntas {
  int? id_Junta;
  String? junta_Name;
  Juntas({
    this.id_Junta,
    this.junta_Name,
  });

  Juntas copyWith({
    int? id_Junta,
    String? junta_Name,
  }) {
    return Juntas(
      id_Junta: id_Junta ?? this.id_Junta,
      junta_Name: junta_Name ?? this.junta_Name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Junta': id_Junta,
      'junta_Name': junta_Name,
    };
  }

  factory Juntas.fromMap(Map<String, dynamic> map) {
    return Juntas(
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      junta_Name:
          map['junta_Name'] != null ? map['junta_Name'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Juntas.fromJson(String source) =>
      Juntas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Juntas(id_Junta: $id_Junta, junta_Name: $junta_Name)';

  @override
  bool operator ==(covariant Juntas other) {
    if (identical(this, other)) return true;

    return other.id_Junta == id_Junta && other.junta_Name == junta_Name;
  }

  @override
  int get hashCode => id_Junta.hashCode ^ junta_Name.hashCode;
}
