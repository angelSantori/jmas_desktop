// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:jmas_desktop/service/auth_service.dart';

class AjusteMasController {
  final AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<AjusteMas>> listAjustesMas() async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('${_authService.apiURL}/AjustesMas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((ajusteMore) => AjusteMas.fromMap(ajusteMore))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error lista ajustes more: $e');
      return [];
    }
  }

  Future<bool> addAjusteMas(AjusteMas ajusteMore) async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('${_authService.apiURL}/AjustesMas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ajusteMore.toJson(),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        // ignore: avoid_print
        print(
            'Error al realizar el ajuste-más: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear ajusteMore: $e');
      return false;
    }
  }
}

class AjusteMas {
  int? id_AjusteMas;
  String? ajuesteMas_Descripcion;
  double? ajusteMas_Cantidad;
  String? ajusteMas_Fecha;
  int? id_Producto;
  int? id_User;
  AjusteMas({
    this.id_AjusteMas,
    this.ajuesteMas_Descripcion,
    this.ajusteMas_Cantidad,
    this.ajusteMas_Fecha,
    this.id_Producto,
    this.id_User,
  });

  AjusteMas copyWith({
    int? id_AjusteMas,
    String? ajuesteMas_Descripcion,
    double? ajusteMas_Cantidad,
    String? ajusteMas_Fecha,
    int? id_Producto,
    int? id_User,
  }) {
    return AjusteMas(
      id_AjusteMas: id_AjusteMas ?? this.id_AjusteMas,
      ajuesteMas_Descripcion:
          ajuesteMas_Descripcion ?? this.ajuesteMas_Descripcion,
      ajusteMas_Cantidad: ajusteMas_Cantidad ?? this.ajusteMas_Cantidad,
      ajusteMas_Fecha: ajusteMas_Fecha ?? this.ajusteMas_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_User: id_User ?? this.id_User,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_AjusteMas': id_AjusteMas,
      'ajuesteMas_Descripcion': ajuesteMas_Descripcion,
      'ajusteMas_Cantidad': ajusteMas_Cantidad,
      'ajusteMas_Fecha': ajusteMas_Fecha,
      'id_Producto': id_Producto,
      'id_User': id_User,
    };
  }

  factory AjusteMas.fromMap(Map<String, dynamic> map) {
    return AjusteMas(
      id_AjusteMas:
          map['id_AjusteMas'] != null ? map['id_AjusteMas'] as int : null,
      ajuesteMas_Descripcion: map['ajuesteMas_Descripcion'] != null
          ? map['ajuesteMas_Descripcion'] as String
          : null,
      ajusteMas_Cantidad: map['ajusteMas_Cantidad'] != null
          ? (map['ajusteMas_Cantidad'] is int
              ? (map['ajusteMas_Cantidad'] as int).toDouble()
              : map['ajusteMas_Cantidad'] as double)
          : null,
      ajusteMas_Fecha: map['ajusteMas_Fecha'] != null
          ? map['ajusteMas_Fecha'] as String
          : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AjusteMas.fromJson(String source) =>
      AjusteMas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AjusteMas(id_AjusteMas: $id_AjusteMas, ajuesteMas_Descripcion: $ajuesteMas_Descripcion, ajusteMas_Cantidad: $ajusteMas_Cantidad, ajusteMas_Fecha: $ajusteMas_Fecha, id_Producto: $id_Producto, id_User: $id_User)';
  }

  @override
  bool operator ==(covariant AjusteMas other) {
    if (identical(this, other)) return true;

    return other.id_AjusteMas == id_AjusteMas &&
        other.ajuesteMas_Descripcion == ajuesteMas_Descripcion &&
        other.ajusteMas_Cantidad == ajusteMas_Cantidad &&
        other.ajusteMas_Fecha == ajusteMas_Fecha &&
        other.id_Producto == id_Producto &&
        other.id_User == id_User;
  }

  @override
  int get hashCode {
    return id_AjusteMas.hashCode ^
        ajuesteMas_Descripcion.hashCode ^
        ajusteMas_Cantidad.hashCode ^
        ajusteMas_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_User.hashCode;
  }
}
