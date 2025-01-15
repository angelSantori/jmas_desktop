// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class UsersController {
  final AuthService _authService = AuthService();

  Future<bool> addUser(Users user, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: user.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        print(
            'Error al agregar usuario: ${response.statusCode} - ${response.body}');
        showError(context, 'ERROR: ${response.body}');
        return false;
      } else {
        print(
            'Error al agregar usuario ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al agregar httpe: $e');
      return false;
    }
  }

  Future<Users?> getUserById(int idUser) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Users/$idUser'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return Users.fromMap(jsonData);
      } else if (response.statusCode == 404) {
        print('Usuario no encontrado con ID: $idUser');
        return null;
      } else {
        print(
            'Error al obtener proveedor por ID: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener usuario por ID: $e');
      return null;
    }
  }

  Future<List<Users>> listUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((user) => Users.fromMap(user)).toList();
      } else {
        print(
            'Error al obtener lista de usuarios: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista de usuarios: $e');
      return [];
    }
  }

  Future<bool> loginUser(
      String userAccess, String userPassword, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Users/Login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json
            .encode({'userAccess': userAccess, 'userPassword': userPassword}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;

        await _authService.saveToken(token);

        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        print('Error en el login: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al intentar iniciar sesión: $e');
      showError(context, 'Error de red $e');
      return false;
    }
  }

  Future<bool> editUser(Users user, BuildContext context) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Users/${user.id_User}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: user.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar usuario: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar usuario: $e');
      return false;
    }
  }
}

class Users {
  int? id_User;
  String? user_Name;
  String? user_Contacto;
  String? user_Access;
  String? user_Password;
  String? user_Rol;
  Users({
    this.id_User,
    this.user_Name,
    this.user_Contacto,
    this.user_Access,
    this.user_Password,
    this.user_Rol,
  });

  Users copyWith({
    int? id_User,
    String? user_Name,
    String? user_Contacto,
    String? user_Access,
    String? user_Password,
    String? user_Rol,
  }) {
    return Users(
      id_User: id_User ?? this.id_User,
      user_Name: user_Name ?? this.user_Name,
      user_Contacto: user_Contacto ?? this.user_Contacto,
      user_Access: user_Access ?? this.user_Access,
      user_Password: user_Password ?? this.user_Password,
      user_Rol: user_Rol ?? this.user_Rol,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_User': id_User,
      'user_Name': user_Name,
      'user_Contacto': user_Contacto,
      'user_Access': user_Access,
      'user_Password': user_Password,
      'user_Rol': user_Rol,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      user_Name: map['user_Name'] != null ? map['user_Name'] as String : null,
      user_Contacto:
          map['user_Contacto'] != null ? map['user_Contacto'] as String : null,
      user_Access:
          map['user_Access'] != null ? map['user_Access'] as String : null,
      user_Password:
          map['user_Password'] != null ? map['user_Password'] as String : null,
      user_Rol: map['user_Rol'] != null ? map['user_Rol'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Users.fromJson(String source) =>
      Users.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Users(id_User: $id_User, user_Name: $user_Name, user_Contacto: $user_Contacto, user_Access: $user_Access, user_Password: $user_Password, user_Rol: $user_Rol)';
  }

  @override
  bool operator ==(covariant Users other) {
    if (identical(this, other)) return true;

    return other.id_User == id_User &&
        other.user_Name == user_Name &&
        other.user_Contacto == user_Contacto &&
        other.user_Access == user_Access &&
        other.user_Password == user_Password &&
        other.user_Rol == user_Rol;
  }

  @override
  int get hashCode {
    return id_User.hashCode ^
        user_Name.hashCode ^
        user_Contacto.hashCode ^
        user_Access.hashCode ^
        user_Password.hashCode ^
        user_Rol.hashCode;
  }
}
