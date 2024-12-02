// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:jmas_desktop/service/auth_service.dart';

class ProveedoresController {
  AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<Proveedores>> listProveedores() async {
    try {
      final IOClient client = _createHttpClient();
      final response =
          await client.get(Uri.parse('${_authService.apiURL}/Proveedores'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((proveedor) => Proveedores.fromMap(proveedor))
            .toList();
      } else {
        print(
            'Error al obtener lista de proveedores: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista de proveedores: $e');
      return [];
    }
  }
}

class Proveedores {
  int? id_Proveedor;
  String? proveedor_Name;
  String? proveedor_Address;
  String? proveedor_Phone;
  Proveedores({
    this.id_Proveedor,
    this.proveedor_Name,
    this.proveedor_Address,
    this.proveedor_Phone,
  });

  Proveedores copyWith({
    int? id_Proveedor,
    String? proveedor_Name,
    String? proveedor_Address,
    String? proveedor_Phone,
  }) {
    return Proveedores(
      id_Proveedor: id_Proveedor ?? this.id_Proveedor,
      proveedor_Name: proveedor_Name ?? this.proveedor_Name,
      proveedor_Address: proveedor_Address ?? this.proveedor_Address,
      proveedor_Phone: proveedor_Phone ?? this.proveedor_Phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Proveedor': id_Proveedor,
      'proveedor_Name': proveedor_Name,
      'proveedor_Address': proveedor_Address,
      'proveedor_Phone': proveedor_Phone,
    };
  }

  factory Proveedores.fromMap(Map<String, dynamic> map) {
    return Proveedores(
      id_Proveedor:
          map['id_Proveedor'] != null ? map['id_Proveedor'] as int : null,
      proveedor_Name: map['proveedor_Name'] != null
          ? map['proveedor_Name'] as String
          : null,
      proveedor_Address: map['proveedor_Address'] != null
          ? map['proveedor_Address'] as String
          : null,
      proveedor_Phone: map['proveedor_Phone'] != null
          ? map['proveedor_Phone'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Proveedores.fromJson(String source) =>
      Proveedores.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Proveedores(id_Proveedor: $id_Proveedor, proveedor_Name: $proveedor_Name, proveedor_Address: $proveedor_Address, proveedor_Phone: $proveedor_Phone)';
  }

  @override
  bool operator ==(covariant Proveedores other) {
    if (identical(this, other)) return true;

    return other.id_Proveedor == id_Proveedor &&
        other.proveedor_Name == proveedor_Name &&
        other.proveedor_Address == proveedor_Address &&
        other.proveedor_Phone == proveedor_Phone;
  }

  @override
  int get hashCode {
    return id_Proveedor.hashCode ^
        proveedor_Name.hashCode ^
        proveedor_Address.hashCode ^
        proveedor_Phone.hashCode;
  }
}
