import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:jmas_desktop/service/auth_service.dart';

class EntidadesController {
  final AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  //List Entidades
  Future<List<Entidades>> listEntidades() async {
    try {
      final IOClient client = _createHttpClient();
      final response = await client.get(
        Uri.parse('${_authService.apiURL}/Entidades'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((entidad) => Entidades.fromMap(entidad)).toList();
      } else {
        print(
            'Error al obtener lista de entidades: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista entidades: $e');
      return [];
    }
  }
}

class Entidades {
  int? id_Entidad;
  String? entidad_Nombre;
  Entidades({
    this.id_Entidad,
    this.entidad_Nombre,
  });

  Entidades copyWith({
    int? id_Entidad,
    String? entidad_Nombre,
  }) {
    return Entidades(
      id_Entidad: id_Entidad ?? this.id_Entidad,
      entidad_Nombre: entidad_Nombre ?? this.entidad_Nombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Entidad': id_Entidad,
      'entidad_Nombre': entidad_Nombre,
    };
  }

  factory Entidades.fromMap(Map<String, dynamic> map) {
    return Entidades(
      id_Entidad: map['id_Entidad'] != null ? map['id_Entidad'] as int : null,
      entidad_Nombre: map['entidad_Nombre'] != null
          ? map['entidad_Nombre'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Entidades.fromJson(String source) =>
      Entidades.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Entidades(id_Entidad: $id_Entidad, entidad_Nombre: $entidad_Nombre)';

  @override
  bool operator ==(covariant Entidades other) {
    if (identical(this, other)) return true;

    return other.id_Entidad == id_Entidad &&
        other.entidad_Nombre == entidad_Nombre;
  }

  @override
  int get hashCode => id_Entidad.hashCode ^ entidad_Nombre.hashCode;
}
