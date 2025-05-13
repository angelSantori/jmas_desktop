// ignore_for_file: public_member_api_docs, sort_constructors_first
//Librerías
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class HtaprestamoController {
  final AuthService _authService = AuthService();

  //ListHtaPrest
  Future<List<HtaPrestamo>> listHtaPrest() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/htaPrestamos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((htaPrestList) => HtaPrestamo.fromMap(htaPrestList))
            .toList();
      } else {
        print(
            'Error listHtaPrest | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listHtaPrest | Try | Controller: $e');
      return [];
    }
  }

  //AddHtaPrest
  Future<bool> addHtaPrest(HtaPrestamo htaPrest) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/htaPrestamos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: htaPrest.toJson(),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addHtaPrest | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addHtaPrest | Try | Controller: $e');
      return false;
    }
  }

  //Edit
  Future<bool> editHtaPrest(HtaPrestamo htaPrest) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/htaPrestamos/${htaPrest.idHtaPrestamo}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: htaPrest.toJson(),
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error editHtaPrest | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error editHtaPrest | Try | Controller: $e');
      return false;
    }
  }

  //NextFolio
  Future<String> nextPrestCodFolio() async {
    final response = await http.get(
      Uri.parse('${_authService.apiURL}/htaPrestamos/nextPrestCodFolio'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Error al obtener el próximo codFolio: ${response.statusCode} - ${response.body}');
    }
  }
}

class HtaPrestamo {
  int? idHtaPrestamo;
  String? prestCodFolio;
  String? prestFechaPrest;
  String? prestFechaDevol;
  String? externoNombre;
  String? externoContacto;
  int? idHerramienta;
  int? id_UserAsignado;
  int? idUserResponsable;
  HtaPrestamo({
    this.idHtaPrestamo,
    this.prestCodFolio,
    this.prestFechaPrest,
    this.prestFechaDevol,
    this.externoNombre,
    this.externoContacto,
    this.idHerramienta,
    this.id_UserAsignado,
    this.idUserResponsable,
  });

  HtaPrestamo copyWith({
    int? idHtaPrestamo,
    String? prestCodFolio,
    String? prestFechaPrest,
    String? prestFechaDevol,
    String? externoNombre,
    String? externoContacto,
    int? idHerramienta,
    int? id_UserAsignado,
    int? idUserResponsable,
  }) {
    return HtaPrestamo(
      idHtaPrestamo: idHtaPrestamo ?? this.idHtaPrestamo,
      prestCodFolio: prestCodFolio ?? this.prestCodFolio,
      prestFechaPrest: prestFechaPrest ?? this.prestFechaPrest,
      prestFechaDevol: prestFechaDevol ?? this.prestFechaDevol,
      externoNombre: externoNombre ?? this.externoNombre,
      externoContacto: externoContacto ?? this.externoContacto,
      idHerramienta: idHerramienta ?? this.idHerramienta,
      id_UserAsignado: id_UserAsignado ?? this.id_UserAsignado,
      idUserResponsable: idUserResponsable ?? this.idUserResponsable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idHtaPrestamo': idHtaPrestamo,
      'prestCodFolio': prestCodFolio,
      'prestFechaPrest': prestFechaPrest,
      'prestFechaDevol': prestFechaDevol,
      'externoNombre': externoNombre,
      'externoContacto': externoContacto,
      'idHerramienta': idHerramienta,
      'id_UserAsignado': id_UserAsignado,
      'idUserResponsable': idUserResponsable,
    };
  }

  factory HtaPrestamo.fromMap(Map<String, dynamic> map) {
    return HtaPrestamo(
      idHtaPrestamo:
          map['idHtaPrestamo'] != null ? map['idHtaPrestamo'] as int : null,
      prestCodFolio:
          map['prestCodFolio'] != null ? map['prestCodFolio'] as String : null,
      prestFechaPrest: map['prestFechaPrest'] != null
          ? map['prestFechaPrest'] as String
          : null,
      prestFechaDevol: map['prestFechaDevol'] != null
          ? map['prestFechaDevol'] as String
          : null,
      externoNombre:
          map['externoNombre'] != null ? map['externoNombre'] as String : null,
      externoContacto: map['externoContacto'] != null
          ? map['externoContacto'] as String
          : null,
      idHerramienta:
          map['idHerramienta'] != null ? map['idHerramienta'] as int : null,
      id_UserAsignado:
          map['id_UserAsignado'] != null ? map['id_UserAsignado'] as int : null,
      idUserResponsable: map['idUserResponsable'] != null
          ? map['idUserResponsable'] as int
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory HtaPrestamo.fromJson(String source) =>
      HtaPrestamo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HtaPrestamo(idHtaPrestamo: $idHtaPrestamo, prestCodFolio: $prestCodFolio, prestFechaPrest: $prestFechaPrest, prestFechaDevol: $prestFechaDevol, externoNombre: $externoNombre, externoContacto: $externoContacto, idHerramienta: $idHerramienta, id_UserAsignado: $id_UserAsignado, idUserResponsable: $idUserResponsable)';
  }

  @override
  bool operator ==(covariant HtaPrestamo other) {
    if (identical(this, other)) return true;

    return other.idHtaPrestamo == idHtaPrestamo &&
        other.prestCodFolio == prestCodFolio &&
        other.prestFechaPrest == prestFechaPrest &&
        other.prestFechaDevol == prestFechaDevol &&
        other.externoNombre == externoNombre &&
        other.externoContacto == externoContacto &&
        other.idHerramienta == idHerramienta &&
        other.id_UserAsignado == id_UserAsignado &&
        other.idUserResponsable == idUserResponsable;
  }

  @override
  int get hashCode {
    return idHtaPrestamo.hashCode ^
        prestCodFolio.hashCode ^
        prestFechaPrest.hashCode ^
        prestFechaDevol.hashCode ^
        externoNombre.hashCode ^
        externoContacto.hashCode ^
        idHerramienta.hashCode ^
        id_UserAsignado.hashCode ^
        idUserResponsable.hashCode;
  }
}
