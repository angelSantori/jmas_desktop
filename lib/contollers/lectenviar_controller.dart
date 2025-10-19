import 'dart:convert';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:http/http.dart' as http;

class LecturaEnviarController {
  final AuthService _authService = AuthService();

  Future<List<LELista>> listLectEnviar() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/LectEnviars'),
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
        Uri.parse('${_authService.apiURL}/LectEnviars/$idLectEnviar'),
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
        Uri.parse('${_authService.apiURL}/LectEnviars/leId/$leId'),
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
          '${_authService.apiURL}/LectEnviars/${lectEnviar.idLectEnviar}',
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
    };
  }

  factory LecturaEnviar.fromMap(Map<String, dynamic> map) {
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

    return LecturaEnviar(
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
      leFotoBase64:
          map['leFotoBase64'] != null ? map['leFotoBase64'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      leEstado: map['leEstado'] != null ? map['leEstado'] as bool : null,
      leCampo17: map['leCampo17'] != null ? map['leCampo17'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LecturaEnviar.fromJson(String source) =>
      LecturaEnviar.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LecturaEnviar(idLectEnviar: $idLectEnviar, leCuenta: $leCuenta, leNombre: $leNombre, leDireccion: $leDireccion, leId: $leId, lePeriodo: $lePeriodo, leFecha: $leFecha, leNumeroMedidor: $leNumeroMedidor, leLecturaAnterior: $leLecturaAnterior, leLecturaActual: $leLecturaActual, idProblemaLectura: $idProblemaLectura, leRuta: $leRuta, leFotoBase64: $leFotoBase64, idUser: $idUser, leEstado: $leEstado, leCampo17: $leCampo17)';
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
        leFotoBase64.hashCode ^
        idUser.hashCode ^
        leEstado.hashCode ^
        leCampo17.hashCode;
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
