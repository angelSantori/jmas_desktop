// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class LecturaEnviarController {
  final AuthService _authService = AuthService();

  Future<List<LELista>> listLectEnviar() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/LectEnviars'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((listLE) => LELista.fromMap(listLE)).toList();
      } else {
        print(
          'Error listLectEnviar | Ife | LEController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listLectEnviar | Try | LEController: $e');
      return [];
    }
  }

  Future<LecturaEnviar?> getLectEnviarById(int idLectEnviar) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/LectEnviars/$idLectEnviar'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return LecturaEnviar.fromMap(jsonData);
      } else {
        print(
          'Error getLectEnviarById | Ife | LEController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getLectEnviarById | Try | LEController: $e');
      return null;
    }
  }

  Future<List<LELista>> getLectEnviarByLeId(int leId) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/LectEnviars/leId/$leId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((listLE) => LELista.fromMap(listLE)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron lecturas con leId: $leId');
        return [];
      } else {
        print(
          'Error getLectEnviarByLeId | Ife | LEController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getLectEnviarByLeId | Try | LEController: $e');
      return [];
    }
  }

  Future<bool> editLectEnviar(LecturaEnviar lectEnviar) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${_authService.apiNubeURL}/LectEnviars/${lectEnviar.idLectEnviar}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: lectEnviar.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error editLectEnviar | Try | LEController: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error edit editLectEnviar | Try | LEController: $e');
      return false;
    }
  }

  Future<bool> createLectEnviar(LecturaEnviarCompleto lectEnviar) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiNubeURL}/LectEnviars'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: lectEnviar.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error createLectEnviar | Ife | LEController: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error createLectEnviar | Try | LEController: $e');
      return false;
    }
  }
}

DateTime? _parseFecha(dynamic fecha) {
  if (fecha == null) return null;

  if (fecha is int) {
    return DateTime.fromMillisecondsSinceEpoch(fecha);
  } else if (fecha is String) {
    try {
      return DateTime.parse(fecha);
    } catch (e) {
      print('Error parsing date: $fecha');
      return null;
    }
  }
  return null;
}

class LecturaEnviar {
  final int idLectEnviar;
  final String? leCuenta;
  final String? leNombre;
  final String? leDireccion;
  final int? leId;
  final String? lePeriodo;
  final DateTime? leFecha;
  final String? leNumeroMedidor;
  final int? leLecturaAnterior;
  final int? leLecturaActual;
  final int? idProblemaLectura;
  final String? leRuta;
  final String? leFotoBase64;
  final int? idUser;
  final bool? leEstado;
  final int? leCampo17;
  final String? leUbicacion;
  LecturaEnviar({
    required this.idLectEnviar,
    this.leCuenta,
    this.leNombre,
    this.leDireccion,
    this.leId,
    this.lePeriodo,
    required this.leFecha,
    this.leNumeroMedidor,
    this.leLecturaAnterior,
    required this.leLecturaActual,
    this.idProblemaLectura,
    this.leRuta,
    required this.leFotoBase64,
    required this.idUser,
    required this.leEstado,
    this.leCampo17,
    this.leUbicacion,
  });

  LecturaEnviar copyWith({
    int? idLectEnviar,
    String? leCuenta,
    String? leNombre,
    String? leDireccion,
    int? leId,
    String? lePeriodo,
    DateTime? leFecha,
    String? leNumeroMedidor,
    int? leLecturaAnterior,
    int? leLecturaActual,
    int? idProblemaLectura,
    String? leRuta,
    String? leFotoBase64,
    int? idUser,
    bool? leEstado,
    int? leCampo17,
    String? leUbicacion,
  }) {
    return LecturaEnviar(
      idLectEnviar: idLectEnviar ?? this.idLectEnviar,
      leCuenta: leCuenta ?? this.leCuenta,
      leNombre: leNombre ?? this.leNombre,
      leDireccion: leDireccion ?? this.leDireccion,
      leId: leId ?? this.leId,
      lePeriodo: lePeriodo ?? this.lePeriodo,
      leFecha: leFecha ?? this.leFecha,
      leNumeroMedidor: leNumeroMedidor ?? this.leNumeroMedidor,
      leLecturaAnterior: leLecturaAnterior ?? this.leLecturaAnterior,
      leLecturaActual: leLecturaActual ?? this.leLecturaActual,
      idProblemaLectura: idProblemaLectura ?? this.idProblemaLectura,
      leRuta: leRuta ?? this.leRuta,
      leFotoBase64: leFotoBase64 ?? this.leFotoBase64,
      idUser: idUser ?? this.idUser,
      leEstado: leEstado ?? this.leEstado,
      leCampo17: leCampo17 ?? this.leCampo17,
      leUbicacion: leUbicacion ?? this.leUbicacion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idLectEnviar': idLectEnviar,
      'leCuenta': leCuenta,
      'leNombre': leNombre,
      'leDireccion': leDireccion,
      'leId': leId,
      'lePeriodo': lePeriodo,
      'leFecha': leFecha?.toIso8601String(),
      'leNumeroMedidor': leNumeroMedidor,
      'leLecturaAnterior': leLecturaAnterior,
      'leLecturaActual': leLecturaActual,
      'idProblemaLectura': idProblemaLectura,
      'leRuta': leRuta,
      'leFotoBase64': leFotoBase64,
      'idUser': idUser,
      'leEstado': leEstado,
      'leCampo17': leCampo17,
      'leUbicacion': leUbicacion,
    };
  }

  factory LecturaEnviar.fromMap(Map<String, dynamic> map) {
    return LecturaEnviar(
      idLectEnviar: map['idLectEnviar'] as int,
      leCuenta: map['leCuenta'] != null ? map['leCuenta'] as String : null,
      leNombre: map['leNombre'] != null ? map['leNombre'] as String : null,
      leDireccion:
          map['leDireccion'] != null ? map['leDireccion'] as String : null,
      leId: map['leId'] != null ? map['leId'] as int : null,
      lePeriodo: map['lePeriodo'] != null ? map['lePeriodo'] as String : null,
      leFecha: map['leFecha'] != null ? _parseFecha(map['leFecha']) : null,
      leNumeroMedidor: map['leNumeroMedidor'] != null
          ? map['leNumeroMedidor'] as String
          : null,
      leLecturaAnterior: map['leLecturaAnterior'] != null
          ? map['leLecturaAnterior'] as int
          : null,
      leLecturaActual:
          map['leLecturaActual'] != null ? map['leLecturaActual'] as int : null,
      idProblemaLectura: map['idProblemaLectura'] != null
          ? map['idProblemaLectura'] as int
          : null,
      leRuta: map['leRuta'] != null ? map['leRuta'] as String : null,
      leFotoBase64:
          map['leFotoBase64'] != null ? map['leFotoBase64'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      leEstado: map['leEstado'] != null ? map['leEstado'] as bool : null,
      leCampo17: map['leCampo17'] != null ? map['leCampo17'] as int : null,
      leUbicacion:
          map['leUbicacion'] != null ? map['leUbicacion'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LecturaEnviar.fromJson(String source) =>
      LecturaEnviar.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LecturaEnviar(idLectEnviar: $idLectEnviar, leCuenta: $leCuenta, leNombre: $leNombre, leDireccion: $leDireccion, leId: $leId, lePeriodo: $lePeriodo, leFecha: $leFecha, leNumeroMedidor: $leNumeroMedidor, leLecturaAnterior: $leLecturaAnterior, leLecturaActual: $leLecturaActual, idProblemaLectura: $idProblemaLectura, leRuta: $leRuta, leFotoBase64: $leFotoBase64, idUser: $idUser, leEstado: $leEstado, leCampo17: $leCampo17, leUbicacion: $leUbicacion)';
  }

  @override
  bool operator ==(covariant LecturaEnviar other) {
    if (identical(this, other)) return true;

    return other.idLectEnviar == idLectEnviar &&
        other.leCuenta == leCuenta &&
        other.leNombre == leNombre &&
        other.leDireccion == leDireccion &&
        other.leId == leId &&
        other.lePeriodo == lePeriodo &&
        other.leFecha == leFecha &&
        other.leNumeroMedidor == leNumeroMedidor &&
        other.leLecturaAnterior == leLecturaAnterior &&
        other.leLecturaActual == leLecturaActual &&
        other.idProblemaLectura == idProblemaLectura &&
        other.leRuta == leRuta &&
        other.leFotoBase64 == leFotoBase64 &&
        other.idUser == idUser &&
        other.leEstado == leEstado &&
        other.leCampo17 == leCampo17 &&
        other.leUbicacion == leUbicacion;
  }

  @override
  int get hashCode {
    return idLectEnviar.hashCode ^
        leCuenta.hashCode ^
        leNombre.hashCode ^
        leDireccion.hashCode ^
        leId.hashCode ^
        lePeriodo.hashCode ^
        leFecha.hashCode ^
        leNumeroMedidor.hashCode ^
        leLecturaAnterior.hashCode ^
        leLecturaActual.hashCode ^
        idProblemaLectura.hashCode ^
        leRuta.hashCode ^
        leFotoBase64.hashCode ^
        idUser.hashCode ^
        leEstado.hashCode ^
        leCampo17.hashCode ^
        leUbicacion.hashCode;
  }
}

class LELista {
  final int idLectEnviar;
  final String? leCuenta;
  final String? leNombre;
  final String? leDireccion;
  final int? leId;
  final String? lePeriodo;
  final DateTime? leFecha;
  final String? leNumeroMedidor;
  final int? leLecturaAnterior;
  final int? leLecturaActual;
  final int? idProblemaLectura;
  final String? leRuta;
  final int? idUser;
  final bool? leEstado;
  final int? leCampo17;
  LELista({
    required this.idLectEnviar,
    this.leCuenta,
    this.leNombre,
    this.leDireccion,
    this.leId,
    this.lePeriodo,
    required this.leFecha,
    this.leNumeroMedidor,
    this.leLecturaAnterior,
    required this.leLecturaActual,
    this.idProblemaLectura,
    this.leRuta,
    required this.idUser,
    required this.leEstado,
    this.leCampo17,
  });

  LELista copyWith({
    int? idLectEnviar,
    String? leCuenta,
    String? leNombre,
    String? leDireccion,
    int? leId,
    String? lePeriodo,
    DateTime? leFecha,
    String? leNumeroMedidor,
    int? leLecturaAnterior,
    int? leLecturaActual,
    int? idProblemaLectura,
    String? leRuta,
    int? idUser,
    bool? leEstado,
    int? leCampo17,
  }) {
    return LELista(
      idLectEnviar: idLectEnviar ?? this.idLectEnviar,
      leCuenta: leCuenta ?? this.leCuenta,
      leNombre: leNombre ?? this.leNombre,
      leDireccion: leDireccion ?? this.leDireccion,
      leId: leId ?? this.leId,
      lePeriodo: lePeriodo ?? this.lePeriodo,
      leFecha: leFecha ?? this.leFecha,
      leNumeroMedidor: leNumeroMedidor ?? this.leNumeroMedidor,
      leLecturaAnterior: leLecturaAnterior ?? this.leLecturaAnterior,
      leLecturaActual: leLecturaActual ?? this.leLecturaActual,
      idProblemaLectura: idProblemaLectura ?? this.idProblemaLectura,
      leRuta: leRuta ?? this.leRuta,
      idUser: idUser ?? this.idUser,
      leEstado: leEstado ?? this.leEstado,
      leCampo17: leCampo17 ?? this.leCampo17,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idLectEnviar': idLectEnviar,
      'leCuenta': leCuenta,
      'leNombre': leNombre,
      'leDireccion': leDireccion,
      'leId': leId,
      'lePeriodo': lePeriodo,
      'leFecha': leFecha?.toIso8601String(),
      'leNumeroMedidor': leNumeroMedidor,
      'leLecturaAnterior': leLecturaAnterior,
      'leLecturaActual': leLecturaActual,
      'idProblemaLectura': idProblemaLectura,
      'leRuta': leRuta,
      'idUser': idUser,
      'leEstado': leEstado,
      'leCampo17': leCampo17,
    };
  }

  factory LELista.fromMap(Map<String, dynamic> map) {
    DateTime? parseFecha(dynamic fecha) {
      if (fecha == null) return null;

      if (fecha is int) {
        return DateTime.fromMillisecondsSinceEpoch(fecha);
      } else if (fecha is String) {
        try {
          return DateTime.parse(fecha);
        } catch (e) {
          print('Error parsing date: $fecha');
          return null;
        }
      }
      return null;
    }

    return LELista(
      idLectEnviar: map['idLectEnviar'] as int,
      leCuenta: map['leCuenta'] != null ? map['leCuenta'] as String : null,
      leNombre: map['leNombre'] != null ? map['leNombre'] as String : null,
      leDireccion:
          map['leDireccion'] != null ? map['leDireccion'] as String : null,
      leId: map['leId'] != null ? map['leId'] as int : null,
      lePeriodo: map['lePeriodo'] != null ? map['lePeriodo'] as String : null,
      leFecha: parseFecha(map['leFecha']),
      leNumeroMedidor: map['leNumeroMedidor'] != null
          ? map['leNumeroMedidor'] as String
          : null,
      leLecturaAnterior: map['leLecturaAnterior'] != null
          ? map['leLecturaAnterior'] as int
          : null,
      leLecturaActual:
          map['leLecturaActual'] != null ? map['leLecturaActual'] as int : null,
      idProblemaLectura: map['idProblemaLectura'] != null
          ? map['idProblemaLectura'] as int
          : null,
      leRuta: map['leRuta'] != null ? map['leRuta'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      leEstado: map['leEstado'] != null ? map['leEstado'] as bool : null,
      leCampo17: map['leCampo17'] != null ? map['leCampo17'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LELista.fromJson(String source) =>
      LELista.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LELista(idLectEnviar: $idLectEnviar, leCuenta: $leCuenta, leNombre: $leNombre, leDireccion: $leDireccion, leId: $leId, lePeriodo: $lePeriodo, leFecha: $leFecha, leNumeroMedidor: $leNumeroMedidor, leLecturaAnterior: $leLecturaAnterior, leLecturaActual: $leLecturaActual, idProblemaLectura: $idProblemaLectura, leRuta: $leRuta, idUser: $idUser, leEstado: $leEstado, leCampo17: $leCampo17)';
  }

  @override
  bool operator ==(covariant LELista other) {
    if (identical(this, other)) return true;

    return other.idLectEnviar == idLectEnviar &&
        other.leCuenta == leCuenta &&
        other.leNombre == leNombre &&
        other.leDireccion == leDireccion &&
        other.leId == leId &&
        other.lePeriodo == lePeriodo &&
        other.leFecha == leFecha &&
        other.leNumeroMedidor == leNumeroMedidor &&
        other.leLecturaAnterior == leLecturaAnterior &&
        other.leLecturaActual == leLecturaActual &&
        other.idProblemaLectura == idProblemaLectura &&
        other.leRuta == leRuta &&
        other.idUser == idUser &&
        other.leEstado == leEstado &&
        other.leCampo17 == leCampo17;
  }

  @override
  int get hashCode {
    return idLectEnviar.hashCode ^
        leCuenta.hashCode ^
        leNombre.hashCode ^
        leDireccion.hashCode ^
        leId.hashCode ^
        lePeriodo.hashCode ^
        leFecha.hashCode ^
        leNumeroMedidor.hashCode ^
        leLecturaAnterior.hashCode ^
        leLecturaActual.hashCode ^
        idProblemaLectura.hashCode ^
        leRuta.hashCode ^
        idUser.hashCode ^
        leEstado.hashCode ^
        leCampo17.hashCode;
  }
}

class LecturaEnviarCompleto {
  final int idLectEnviar;
  final String? leCampo1;
  final String? leCampo2;
  final int? leCampo3;
  final int? leCampo4;
  final String? leCampo5;
  final int? leCampo6;
  final int? leCampo7;
  final int? leCampo8;
  final String? leCampo9;
  final String? leCampo10;
  final String? leCuenta;
  final String? leNombre;
  final String? leDireccion;
  final String? leCampo11;
  final int? leId;
  final String? lePeriodo;
  final DateTime? leFecha;
  final String? leCampo12;
  final String? leCampo13;
  final String? leCampo14;
  final String? leNumeroMedidor;
  final int? leLecturaAnterior;
  final int? leLecturaActual;
  final int? idProblemaLectura;
  final String? leRuta;
  final String? leCampo15;
  final String? leCampo16;
  final int? leCampo17;
  final String? leCampo18;
  final String? leCampo19;
  final int? leCampo20;
  final int? leCampo21;
  final String? leFotoBase64;
  final int? idUser;
  final bool? leEstado;
  final String? leUbicacion;
  LecturaEnviarCompleto({
    required this.idLectEnviar,
    this.leCampo1,
    this.leCampo2,
    this.leCampo3,
    this.leCampo4,
    this.leCampo5,
    this.leCampo6,
    this.leCampo7,
    this.leCampo8,
    this.leCampo9,
    this.leCampo10,
    this.leCuenta,
    this.leNombre,
    this.leDireccion,
    this.leCampo11,
    this.leId,
    this.lePeriodo,
    this.leFecha,
    this.leCampo12,
    this.leCampo13,
    this.leCampo14,
    this.leNumeroMedidor,
    this.leLecturaAnterior,
    this.leLecturaActual,
    this.idProblemaLectura,
    this.leRuta,
    this.leCampo15,
    this.leCampo16,
    this.leCampo17,
    this.leCampo18,
    this.leCampo19,
    this.leCampo20,
    this.leCampo21,
    this.leFotoBase64,
    this.idUser,
    this.leEstado,
    this.leUbicacion,
  });

  LecturaEnviarCompleto copyWith({
    int? idLectEnviar,
    String? leCampo1,
    String? leCampo2,
    int? leCampo3,
    int? leCampo4,
    String? leCampo5,
    int? leCampo6,
    int? leCampo7,
    int? leCampo8,
    String? leCampo9,
    String? leCampo10,
    String? leCuenta,
    String? leNombre,
    String? leDireccion,
    String? leCampo11,
    int? leId,
    String? lePeriodo,
    DateTime? leFecha,
    String? leCampo12,
    String? leCampo13,
    String? leCampo14,
    String? leNumeroMedidor,
    int? leLecturaAnterior,
    int? leLecturaActual,
    int? idProblemaLectura,
    String? leRuta,
    String? leCampo15,
    String? leCampo16,
    int? leCampo17,
    String? leCampo18,
    String? leCampo19,
    int? leCampo20,
    int? leCampo21,
    String? leFotoBase64,
    int? idUser,
    bool? leEstado,
    String? leUbicacion,
  }) {
    return LecturaEnviarCompleto(
      idLectEnviar: idLectEnviar ?? this.idLectEnviar,
      leCampo1: leCampo1 ?? this.leCampo1,
      leCampo2: leCampo2 ?? this.leCampo2,
      leCampo3: leCampo3 ?? this.leCampo3,
      leCampo4: leCampo4 ?? this.leCampo4,
      leCampo5: leCampo5 ?? this.leCampo5,
      leCampo6: leCampo6 ?? this.leCampo6,
      leCampo7: leCampo7 ?? this.leCampo7,
      leCampo8: leCampo8 ?? this.leCampo8,
      leCampo9: leCampo9 ?? this.leCampo9,
      leCampo10: leCampo10 ?? this.leCampo10,
      leCuenta: leCuenta ?? this.leCuenta,
      leNombre: leNombre ?? this.leNombre,
      leDireccion: leDireccion ?? this.leDireccion,
      leCampo11: leCampo11 ?? this.leCampo11,
      leId: leId ?? this.leId,
      lePeriodo: lePeriodo ?? this.lePeriodo,
      leFecha: leFecha ?? this.leFecha,
      leCampo12: leCampo12 ?? this.leCampo12,
      leCampo13: leCampo13 ?? this.leCampo13,
      leCampo14: leCampo14 ?? this.leCampo14,
      leNumeroMedidor: leNumeroMedidor ?? this.leNumeroMedidor,
      leLecturaAnterior: leLecturaAnterior ?? this.leLecturaAnterior,
      leLecturaActual: leLecturaActual ?? this.leLecturaActual,
      idProblemaLectura: idProblemaLectura ?? this.idProblemaLectura,
      leRuta: leRuta ?? this.leRuta,
      leCampo15: leCampo15 ?? this.leCampo15,
      leCampo16: leCampo16 ?? this.leCampo16,
      leCampo17: leCampo17 ?? this.leCampo17,
      leCampo18: leCampo18 ?? this.leCampo18,
      leCampo19: leCampo19 ?? this.leCampo19,
      leCampo20: leCampo20 ?? this.leCampo20,
      leCampo21: leCampo21 ?? this.leCampo21,
      leFotoBase64: leFotoBase64 ?? this.leFotoBase64,
      idUser: idUser ?? this.idUser,
      leEstado: leEstado ?? this.leEstado,
      leUbicacion: leUbicacion ?? this.leUbicacion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idLectEnviar': idLectEnviar,
      'leCampo1': leCampo1,
      'leCampo2': leCampo2,
      'leCampo3': leCampo3,
      'leCampo4': leCampo4,
      'leCampo5': leCampo5,
      'leCampo6': leCampo6,
      'leCampo7': leCampo7,
      'leCampo8': leCampo8,
      'leCampo9': leCampo9,
      'leCampo10': leCampo10,
      'leCuenta': leCuenta,
      'leNombre': leNombre,
      'leDireccion': leDireccion,
      'leCampo11': leCampo11,
      'leId': leId,
      'lePeriodo': lePeriodo,
      'leFecha': leFecha?.toIso8601String(),
      'leCampo12': leCampo12,
      'leCampo13': leCampo13,
      'leCampo14': leCampo14,
      'leNumeroMedidor': leNumeroMedidor,
      'leLecturaAnterior': leLecturaAnterior,
      'leLecturaActual': leLecturaActual,
      'idProblemaLectura': idProblemaLectura,
      'leRuta': leRuta,
      'leCampo15': leCampo15,
      'leCampo16': leCampo16,
      'leCampo17': leCampo17,
      'leCampo18': leCampo18,
      'leCampo19': leCampo19,
      'leCampo20': leCampo20,
      'leCampo21': leCampo21,
      'leFotoBase64': leFotoBase64,
      'idUser': idUser,
      'leEstado': leEstado,
      'leUbicacion': leUbicacion,
    };
  }

  factory LecturaEnviarCompleto.fromMap(Map<String, dynamic> map) {
    return LecturaEnviarCompleto(
      idLectEnviar: map['idLectEnviar'] as int,
      leCampo1: map['leCampo1'] != null ? map['leCampo1'] as String : null,
      leCampo2: map['leCampo2'] != null ? map['leCampo2'] as String : null,
      leCampo3: map['leCampo3'] != null ? map['leCampo3'] as int : null,
      leCampo4: map['leCampo4'] != null ? map['leCampo4'] as int : null,
      leCampo5: map['leCampo5'] != null ? map['leCampo5'] as String : null,
      leCampo6: map['leCampo6'] != null ? map['leCampo6'] as int : null,
      leCampo7: map['leCampo7'] != null ? map['leCampo7'] as int : null,
      leCampo8: map['leCampo8'] != null ? map['leCampo8'] as int : null,
      leCampo9: map['leCampo9'] != null ? map['leCampo9'] as String : null,
      leCampo10: map['leCampo10'] != null ? map['leCampo10'] as String : null,
      leCuenta: map['leCuenta'] != null ? map['leCuenta'] as String : null,
      leNombre: map['leNombre'] != null ? map['leNombre'] as String : null,
      leDireccion:
          map['leDireccion'] != null ? map['leDireccion'] as String : null,
      leCampo11: map['leCampo11'] != null ? map['leCampo11'] as String : null,
      leId: map['leId'] != null ? map['leId'] as int : null,
      lePeriodo: map['lePeriodo'] != null ? map['lePeriodo'] as String : null,
      leFecha: map['leFecha'] != null ? _parseFecha(map['leFecha']) : null,
      leCampo12: map['leCampo12'] != null ? map['leCampo12'] as String : null,
      leCampo13: map['leCampo13'] != null ? map['leCampo13'] as String : null,
      leCampo14: map['leCampo14'] != null ? map['leCampo14'] as String : null,
      leNumeroMedidor: map['leNumeroMedidor'] != null
          ? map['leNumeroMedidor'] as String
          : null,
      leLecturaAnterior: map['leLecturaAnterior'] != null
          ? map['leLecturaAnterior'] as int
          : null,
      leLecturaActual:
          map['leLecturaActual'] != null ? map['leLecturaActual'] as int : null,
      idProblemaLectura: map['idProblemaLectura'] != null
          ? map['idProblemaLectura'] as int
          : null,
      leRuta: map['leRuta'] != null ? map['leRuta'] as String : null,
      leCampo15: map['leCampo15'] != null ? map['leCampo15'] as String : null,
      leCampo16: map['leCampo16'] != null ? map['leCampo16'] as String : null,
      leCampo17: map['leCampo17'] != null ? map['leCampo17'] as int : null,
      leCampo18: map['leCampo18'] != null ? map['leCampo18'] as String : null,
      leCampo19: map['leCampo19'] != null ? map['leCampo19'] as String : null,
      leCampo20: map['leCampo20'] != null ? map['leCampo20'] as int : null,
      leCampo21: map['leCampo21'] != null ? map['leCampo21'] as int : null,
      leFotoBase64:
          map['leFotoBase64'] != null ? map['leFotoBase64'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      leEstado: map['leEstado'] != null ? map['leEstado'] as bool : null,
      leUbicacion:
          map['leUbicacion'] != null ? map['leUbicacion'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LecturaEnviarCompleto.fromJson(String source) =>
      LecturaEnviarCompleto.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LecturaEnviarCompleto(idLectEnviar: $idLectEnviar, leCampo1: $leCampo1, leCampo2: $leCampo2, leCampo3: $leCampo3, leCampo4: $leCampo4, leCampo5: $leCampo5, leCampo6: $leCampo6, leCampo7: $leCampo7, leCampo8: $leCampo8, leCampo9: $leCampo9, leCampo10: $leCampo10, leCuenta: $leCuenta, leNombre: $leNombre, leDireccion: $leDireccion, leCampo11: $leCampo11, leId: $leId, lePeriodo: $lePeriodo, leFecha: $leFecha, leCampo12: $leCampo12, leCampo13: $leCampo13, leCampo14: $leCampo14, leNumeroMedidor: $leNumeroMedidor, leLecturaAnterior: $leLecturaAnterior, leLecturaActual: $leLecturaActual, idProblemaLectura: $idProblemaLectura, leRuta: $leRuta, leCampo15: $leCampo15, leCampo16: $leCampo16, leCampo17: $leCampo17, leCampo18: $leCampo18, leCampo19: $leCampo19, leCampo20: $leCampo20, leCampo21: $leCampo21, leFotoBase64: $leFotoBase64, idUser: $idUser, leEstado: $leEstado, leUbicacion: $leUbicacion)';
  }

  @override
  bool operator ==(covariant LecturaEnviarCompleto other) {
    if (identical(this, other)) return true;

    return other.idLectEnviar == idLectEnviar &&
        other.leCampo1 == leCampo1 &&
        other.leCampo2 == leCampo2 &&
        other.leCampo3 == leCampo3 &&
        other.leCampo4 == leCampo4 &&
        other.leCampo5 == leCampo5 &&
        other.leCampo6 == leCampo6 &&
        other.leCampo7 == leCampo7 &&
        other.leCampo8 == leCampo8 &&
        other.leCampo9 == leCampo9 &&
        other.leCampo10 == leCampo10 &&
        other.leCuenta == leCuenta &&
        other.leNombre == leNombre &&
        other.leDireccion == leDireccion &&
        other.leCampo11 == leCampo11 &&
        other.leId == leId &&
        other.lePeriodo == lePeriodo &&
        other.leFecha == leFecha &&
        other.leCampo12 == leCampo12 &&
        other.leCampo13 == leCampo13 &&
        other.leCampo14 == leCampo14 &&
        other.leNumeroMedidor == leNumeroMedidor &&
        other.leLecturaAnterior == leLecturaAnterior &&
        other.leLecturaActual == leLecturaActual &&
        other.idProblemaLectura == idProblemaLectura &&
        other.leRuta == leRuta &&
        other.leCampo15 == leCampo15 &&
        other.leCampo16 == leCampo16 &&
        other.leCampo17 == leCampo17 &&
        other.leCampo18 == leCampo18 &&
        other.leCampo19 == leCampo19 &&
        other.leCampo20 == leCampo20 &&
        other.leCampo21 == leCampo21 &&
        other.leFotoBase64 == leFotoBase64 &&
        other.idUser == idUser &&
        other.leEstado == leEstado &&
        other.leUbicacion == leUbicacion;
  }

  @override
  int get hashCode {
    return idLectEnviar.hashCode ^
        leCampo1.hashCode ^
        leCampo2.hashCode ^
        leCampo3.hashCode ^
        leCampo4.hashCode ^
        leCampo5.hashCode ^
        leCampo6.hashCode ^
        leCampo7.hashCode ^
        leCampo8.hashCode ^
        leCampo9.hashCode ^
        leCampo10.hashCode ^
        leCuenta.hashCode ^
        leNombre.hashCode ^
        leDireccion.hashCode ^
        leCampo11.hashCode ^
        leId.hashCode ^
        lePeriodo.hashCode ^
        leFecha.hashCode ^
        leCampo12.hashCode ^
        leCampo13.hashCode ^
        leCampo14.hashCode ^
        leNumeroMedidor.hashCode ^
        leLecturaAnterior.hashCode ^
        leLecturaActual.hashCode ^
        idProblemaLectura.hashCode ^
        leRuta.hashCode ^
        leCampo15.hashCode ^
        leCampo16.hashCode ^
        leCampo17.hashCode ^
        leCampo18.hashCode ^
        leCampo19.hashCode ^
        leCampo20.hashCode ^
        leCampo21.hashCode ^
        leFotoBase64.hashCode ^
        idUser.hashCode ^
        leEstado.hashCode ^
        leUbicacion.hashCode;
  }
}
