// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class AlmacenesController {
  final AuthService _authService = AuthService();

  //Add almacen
  Future<bool> addAlmacen(Almacenes almacen) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Almacenes'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: almacen.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al agregar almacen: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al agregar almacen: $e');
      return false;
    }
  }

  //List Almacenes
  Future<List<Almacenes>> listAlmacenes() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Almacenes'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entidad) => Almacenes.fromMap(entidad)).toList();
      } else {
        print(
            'Error al obtener lista de Almacenes: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista Almacenes: $e');
      return [];
    }
  }

  Future<bool> editAlmacen(Almacenes almacen) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Almacenes/${almacen.id_Almacen}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: almacen.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar almacen: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar almacen: $e');
      return false;
    }
  }
}

class Almacenes {
  int? id_Almacen;
  String? almacen_Nombre;
  Almacenes({
    this.id_Almacen,
    this.almacen_Nombre,
  });

  Almacenes copyWith({
    int? id_Almacen,
    String? almacen_Nombre,
  }) {
    return Almacenes(
      id_Almacen: id_Almacen ?? this.id_Almacen,
      almacen_Nombre: almacen_Nombre ?? this.almacen_Nombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Almacen': id_Almacen,
      'almacen_Nombre': almacen_Nombre,
    };
  }

  factory Almacenes.fromMap(Map<String, dynamic> map) {
    return Almacenes(
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
      almacen_Nombre: map['almacen_Nombre'] != null
          ? map['almacen_Nombre'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Almacenes.fromJson(String source) =>
      Almacenes.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Almacenes(id_Almacen: $id_Almacen, almacen_Nombre: $almacen_Nombre)';

  @override
  bool operator ==(covariant Almacenes other) {
    if (identical(this, other)) return true;

    return other.id_Almacen == id_Almacen &&
        other.almacen_Nombre == almacen_Nombre;
  }

  @override
  int get hashCode => id_Almacen.hashCode ^ almacen_Nombre.hashCode;
}
