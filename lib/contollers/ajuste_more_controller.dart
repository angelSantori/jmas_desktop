// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:jmas_desktop/service/auth_service.dart';

class AjusteMoreController {
  AuthService _authService = AuthService();

  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<AjusteMores>> listAjustesMore() async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.get(
        Uri.parse('${_authService.apiURL}/AjustesMores'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((ajusteMore) => AjusteMores.fromMap(ajusteMore))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error lista ajustes more: $e');
      return [];
    }
  }

  Future<bool> addAjusteMore(AjusteMores ajusteMore) async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.post(
        Uri.parse('${_authService.apiURL}/AjustesMores'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ajusteMore.toJson(),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al realizar el ajuste: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al crear ajusteMore: $e');
      return false;
    }
  }
}

class AjusteMores {
  int? id_AjusteMore;
  double? ajusteMore_Cantidad;
  String? ajusteMore_Fecha;
  int? id_Producto;
  int? id_Salida;
  int? id_Entradas;
  AjusteMores({
    this.id_AjusteMore,
    this.ajusteMore_Cantidad,
    this.ajusteMore_Fecha,
    this.id_Producto,
    this.id_Salida,
    this.id_Entradas,
  });

  AjusteMores copyWith({
    int? id_AjusteMore,
    double? ajusteMore_Cantidad,
    String? ajusteMore_Fecha,
    int? id_Producto,
    int? id_Salida,
    int? id_Entradas,
  }) {
    return AjusteMores(
      id_AjusteMore: id_AjusteMore ?? this.id_AjusteMore,
      ajusteMore_Cantidad: ajusteMore_Cantidad ?? this.ajusteMore_Cantidad,
      ajusteMore_Fecha: ajusteMore_Fecha ?? this.ajusteMore_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_Salida: id_Salida ?? this.id_Salida,
      id_Entradas: id_Entradas ?? this.id_Entradas,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_AjusteMore': id_AjusteMore,
      'ajusteMore_Cantidad': ajusteMore_Cantidad,
      'ajusteMore_Fecha': ajusteMore_Fecha,
      'id_Producto': id_Producto,
      'id_Salida': id_Salida,
      'id_Entradas': id_Entradas,
    };
  }

  factory AjusteMores.fromMap(Map<String, dynamic> map) {
    return AjusteMores(
      id_AjusteMore:
          map['id_AjusteMore'] != null ? map['id_AjusteMore'] as int : null,
      ajusteMore_Cantidad: map['ajusteMore_Cantidad'] != null
          ? map['ajusteMore_Cantidad'] as double
          : null,
      ajusteMore_Fecha: map['ajusteMore_Fecha'] != null
          ? map['ajusteMore_Fecha'] as String
          : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      id_Entradas:
          map['id_Entradas'] != null ? map['id_Entradas'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AjusteMores.fromJson(String source) =>
      AjusteMores.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AjusteMores(id_AjusteMore: $id_AjusteMore, ajusteMore_Cantidad: $ajusteMore_Cantidad, ajusteMore_Fecha: $ajusteMore_Fecha, id_Producto: $id_Producto, id_Salida: $id_Salida, id_Entradas: $id_Entradas)';
  }

  @override
  bool operator ==(covariant AjusteMores other) {
    if (identical(this, other)) return true;

    return other.id_AjusteMore == id_AjusteMore &&
        other.ajusteMore_Cantidad == ajusteMore_Cantidad &&
        other.ajusteMore_Fecha == ajusteMore_Fecha &&
        other.id_Producto == id_Producto &&
        other.id_Salida == id_Salida &&
        other.id_Entradas == id_Entradas;
  }

  @override
  int get hashCode {
    return id_AjusteMore.hashCode ^
        ajusteMore_Cantidad.hashCode ^
        ajusteMore_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_Salida.hashCode ^
        id_Entradas.hashCode;
  }
}
