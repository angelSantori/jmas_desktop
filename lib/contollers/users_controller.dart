// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:jmas_desktop/service/auth_service.dart';

class UsersController {
  final AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<Users>> listUsers() async {
    try {
      final IOClient client = _createHttpClient();
      final response =
          await client.get(Uri.parse('${_authService.apiURL}/Users'));

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
}

class Users {
  int? id_User;
  String? user_Name;
  String? user_Contacto;
  String? user_Access;
  String? user_Password;
  Users({
    this.id_User,
    this.user_Name,
    this.user_Contacto,
    this.user_Access,
    this.user_Password,
  });

  Users copyWith({
    int? id_User,
    String? user_Name,
    String? user_Contacto,
    String? user_Access,
    String? user_Password,
  }) {
    return Users(
      id_User: id_User ?? this.id_User,
      user_Name: user_Name ?? this.user_Name,
      user_Contacto: user_Contacto ?? this.user_Contacto,
      user_Access: user_Access ?? this.user_Access,
      user_Password: user_Password ?? this.user_Password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_User': id_User,
      'user_Name': user_Name,
      'user_Contacto': user_Contacto,
      'user_Access': user_Access,
      'user_Password': user_Password,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory Users.fromJson(String source) =>
      Users.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Users(id_User: $id_User, user_Name: $user_Name, user_Contacto: $user_Contacto, user_Access: $user_Access, user_Password: $user_Password)';
  }

  @override
  bool operator ==(covariant Users other) {
    if (identical(this, other)) return true;

    return other.id_User == id_User &&
        other.user_Name == user_Name &&
        other.user_Contacto == user_Contacto &&
        other.user_Access == user_Access &&
        other.user_Password == user_Password;
  }

  @override
  int get hashCode {
    return id_User.hashCode ^
        user_Name.hashCode ^
        user_Contacto.hashCode ^
        user_Access.hashCode ^
        user_Password.hashCode;
  }
}
