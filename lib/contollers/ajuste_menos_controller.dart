// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class AjusteMenosController {
  final AuthService _authService = AuthService();

  Future<List<AjusteMenos>> listAjusteMenos() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/AjustesMenos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((ajusteMenos) => AjusteMenos.fromMap(ajusteMenos))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error lista ajuste menos: $e');
      return [];
    }
  }

  Future<bool> addAjusteMenos(AjusteMenos ajusteMenos) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/AjustesMenos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: ajusteMenos.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // ignore: avoid_print
        print(
            'Error al realizar ajusteMenos: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al crear ajusteMenos: $e');
      return false;
    }
  }
}

class AjusteMenos {
  int? id_AjusteMenos;
  String? ajusteMenos_Descripcion;
  double? ajusteMenos_Cantidad;
  String? ajusteMenos_Fecha;
  int? id_Producto;
  int? id_User;
  AjusteMenos({
    this.id_AjusteMenos,
    this.ajusteMenos_Descripcion,
    this.ajusteMenos_Cantidad,
    this.ajusteMenos_Fecha,
    this.id_Producto,
    this.id_User,
  });

  AjusteMenos copyWith({
    int? id_AjusteMenos,
    String? ajusteMenos_Descripcion,
    double? ajusteMenos_Cantidad,
    String? ajusteMenos_Fecha,
    int? id_Producto,
    int? id_User,
  }) {
    return AjusteMenos(
      id_AjusteMenos: id_AjusteMenos ?? this.id_AjusteMenos,
      ajusteMenos_Descripcion:
          ajusteMenos_Descripcion ?? this.ajusteMenos_Descripcion,
      ajusteMenos_Cantidad: ajusteMenos_Cantidad ?? this.ajusteMenos_Cantidad,
      ajusteMenos_Fecha: ajusteMenos_Fecha ?? this.ajusteMenos_Fecha,
      id_Producto: id_Producto ?? this.id_Producto,
      id_User: id_User ?? this.id_User,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_AjusteMenos': id_AjusteMenos,
      'ajusteMenos_Descripcion': ajusteMenos_Descripcion,
      'ajusteMenos_Cantidad': ajusteMenos_Cantidad,
      'ajusteMenos_Fecha': ajusteMenos_Fecha,
      'id_Producto': id_Producto,
      'id_User': id_User,
    };
  }

  factory AjusteMenos.fromMap(Map<String, dynamic> map) {
    return AjusteMenos(
      id_AjusteMenos:
          map['id_AjusteMenos'] != null ? map['id_AjusteMenos'] as int : null,
      ajusteMenos_Descripcion: map['ajusteMenos_Descripcion'] != null
          ? map['ajusteMenos_Descripcion'] as String
          : null,
      ajusteMenos_Cantidad: map['ajusteMenos_Cantidad'] != null
          ? (map['ajusteMenos_Cantidad'] is int
              ? (map['ajusteMenos_Cantidad'] as int).toDouble()
              : map['ajusteMenos_Cantidad'] as double)
          : null,
      ajusteMenos_Fecha: map['ajusteMenos_Fecha'] != null
          ? map['ajusteMenos_Fecha'] as String
          : null,
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AjusteMenos.fromJson(String source) =>
      AjusteMenos.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AjusteMenos(id_AjusteMenos: $id_AjusteMenos, ajusteMenos_Descripcion: $ajusteMenos_Descripcion, ajusteMenos_Cantidad: $ajusteMenos_Cantidad, ajusteMenos_Fecha: $ajusteMenos_Fecha, id_Producto: $id_Producto, id_User: $id_User)';
  }

  @override
  bool operator ==(covariant AjusteMenos other) {
    if (identical(this, other)) return true;

    return other.id_AjusteMenos == id_AjusteMenos &&
        other.ajusteMenos_Descripcion == ajusteMenos_Descripcion &&
        other.ajusteMenos_Cantidad == ajusteMenos_Cantidad &&
        other.ajusteMenos_Fecha == ajusteMenos_Fecha &&
        other.id_Producto == id_Producto &&
        other.id_User == id_User;
  }

  @override
  int get hashCode {
    return id_AjusteMenos.hashCode ^
        ajusteMenos_Descripcion.hashCode ^
        ajusteMenos_Cantidad.hashCode ^
        ajusteMenos_Fecha.hashCode ^
        id_Producto.hashCode ^
        id_User.hashCode;
  }
}
