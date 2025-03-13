// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class CcontablesController {
  AuthService _authService = AuthService();

  Future<List<CContables>> listCcontables() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/CContables'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((ccontable) => CContables.fromMap(ccontable))
            .toList();
      } else {
        print(
            'Error lista CC | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista CC | TryCatch | Controller: $e');
      return [];
    }
  }
}

class CContables {
  int? id_CConTable;
  int? cC_Cuenta;
  int? cC_SCTA;
  String? cC_Detalle;
  BigInt? cC_CVEPROD;
  int? idProducto;
  CContables({
    this.id_CConTable,
    this.cC_Cuenta,
    this.cC_SCTA,
    this.cC_Detalle,
    this.cC_CVEPROD,
    this.idProducto,
  });

  CContables copyWith({
    int? id_CConTable,
    int? cC_Cuenta,
    int? cC_SCTA,
    String? cC_Detalle,
    BigInt? cC_CVEPROD,
    int? idProducto,
  }) {
    return CContables(
      id_CConTable: id_CConTable ?? this.id_CConTable,
      cC_Cuenta: cC_Cuenta ?? this.cC_Cuenta,
      cC_SCTA: cC_SCTA ?? this.cC_SCTA,
      cC_Detalle: cC_Detalle ?? this.cC_Detalle,
      cC_CVEPROD: cC_CVEPROD ?? this.cC_CVEPROD,
      idProducto: idProducto ?? this.idProducto,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_CConTable': id_CConTable,
      'cC_Cuenta': cC_Cuenta,
      'cC_SCTA': cC_SCTA,
      'cC_Detalle': cC_Detalle,
      'cC_CVEPROD': cC_CVEPROD?.toString(),
      'idProducto': idProducto,
    };
  }

  factory CContables.fromMap(Map<String, dynamic> map) {
    return CContables(
      id_CConTable:
          map['id_CConTable'] != null ? map['id_CConTable'] as int : null,
      cC_Cuenta: map['cC_Cuenta'] != null ? map['cC_Cuenta'] as int : null,
      cC_SCTA: map['cC_SCTA'] != null ? map['cC_SCTA'] as int : null,
      cC_Detalle:
          map['cC_Detalle'] != null ? map['cC_Detalle'] as String : null,
      cC_CVEPROD: map['cC_CVEPROD'] != null
          ? (map['cC_CVEPROD'] is int
              ? BigInt.from(map[
                  'cC_CVEPROD']) // Si ya es un int, conviértelo a BigInt directamente
              : BigInt.parse(map['cC_CVEPROD']
                  as String)) // Si es String, conviértelo a BigInt
          : null,
      idProducto: map['idProducto'] != null ? map['idProducto'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CContables.fromJson(String source) =>
      CContables.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CContables(id_CConTable: $id_CConTable, cC_Cuenta: $cC_Cuenta, cC_SCTA: $cC_SCTA, cC_Detalle: $cC_Detalle, cC_CVEPROD: $cC_CVEPROD, idProducto: $idProducto)';
  }

  @override
  bool operator ==(covariant CContables other) {
    if (identical(this, other)) return true;

    return other.id_CConTable == id_CConTable &&
        other.cC_Cuenta == cC_Cuenta &&
        other.cC_SCTA == cC_SCTA &&
        other.cC_Detalle == cC_Detalle &&
        other.cC_CVEPROD == cC_CVEPROD &&
        other.idProducto == idProducto;
  }

  @override
  int get hashCode {
    return id_CConTable.hashCode ^
        cC_Cuenta.hashCode ^
        cC_SCTA.hashCode ^
        cC_Detalle.hashCode ^
        cC_CVEPROD.hashCode ^
        idProducto.hashCode;
  }
}
