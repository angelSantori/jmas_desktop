import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class SolicitudAutorizacionesController {
  final AuthService _authService = AuthService();

  Future<List<SolicitudAutorizaciones>> getSolicitudAutorizacionByFolio(
      String folio) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/SolicitudAutorizaciones/ByFolio/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listSV) => SolicitudAutorizaciones.fromMap(listSV))
            .toList();
      } else {
        print(
            'Error getSolicitudAutorizacionByFolio | Ife | SolicitudAutorizacionesController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Error getSolicitudAutorizacionByFolio | Try | SolicitudAutorizacionesController: $e');
      return [];
    }
  }

  Future<bool> addSolicitudAutorizacion(
      SolicitudAutorizaciones solicitudAutorizacion) async {
    try {
      final response = await http.post(
          Uri.parse('${_authService.apiURL}/SolicitudAutorizaciones'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: solicitudAutorizacion.toJson());

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addSolicitudAutorizacion | Ife | SolicitudAutorizacionesController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print(
          'Error addSolicitudAutorizacion | Try | SolicitudAutorizacionesController: $e');
      return false;
    }
  }
}

class SolicitudAutorizaciones {
  final int idSolicitudAutorizacion;
  final DateTime saFecha;
  final String saEstado;
  final String saComentario;
  final String solicitudCompraFolio;
  final int idUserAutoriza;
  SolicitudAutorizaciones({
    required this.idSolicitudAutorizacion,
    required this.saFecha,
    required this.saEstado,
    required this.saComentario,
    required this.solicitudCompraFolio,
    required this.idUserAutoriza,
  });

  SolicitudAutorizaciones copyWith({
    int? idSolicitudAutorizacion,
    DateTime? saFecha,
    String? saEstado,
    String? saComentario,
    String? solicitudCompraFolio,
    int? idUserAutoriza,
  }) {
    return SolicitudAutorizaciones(
      idSolicitudAutorizacion:
          idSolicitudAutorizacion ?? this.idSolicitudAutorizacion,
      saFecha: saFecha ?? this.saFecha,
      saEstado: saEstado ?? this.saEstado,
      saComentario: saComentario ?? this.saComentario,
      solicitudCompraFolio: solicitudCompraFolio ?? this.solicitudCompraFolio,
      idUserAutoriza: idUserAutoriza ?? this.idUserAutoriza,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idSolicitudAutorizacion': idSolicitudAutorizacion,
      'saFecha': saFecha.toIso8601String(),
      'saEstado': saEstado,
      'saComentario': saComentario,
      'solicitudCompraFolio': solicitudCompraFolio,
      'idUserAutoriza': idUserAutoriza,
    };
  }

  factory SolicitudAutorizaciones.fromMap(Map<String, dynamic> map) {
    return SolicitudAutorizaciones(
      idSolicitudAutorizacion: map['idSolicitudAutorizacion'] as int,
      saFecha: _parseDateTime(map['saFecha']),
      saEstado: map['saEstado'] as String,
      saComentario: map['saComentario'] as String,
      solicitudCompraFolio: map['solicitudCompraFolio'] as String,
      idUserAutoriza: map['idUserAutoriza'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SolicitudAutorizaciones.fromJson(String source) =>
      SolicitudAutorizaciones.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SolicitudAutorizaciones(idSolicitudAutorizacion: $idSolicitudAutorizacion, saFecha: $saFecha, saEstado: $saEstado, saComentario: $saComentario, solicitudCompraFolio: $solicitudCompraFolio, idUserAutoriza: $idUserAutoriza)';
  }

  @override
  bool operator ==(covariant SolicitudAutorizaciones other) {
    if (identical(this, other)) return true;

    return other.idSolicitudAutorizacion == idSolicitudAutorizacion &&
        other.saFecha == saFecha &&
        other.saEstado == saEstado &&
        other.saComentario == saComentario &&
        other.solicitudCompraFolio == solicitudCompraFolio &&
        other.idUserAutoriza == idUserAutoriza;
  }

  @override
  int get hashCode {
    return idSolicitudAutorizacion.hashCode ^
        saFecha.hashCode ^
        saEstado.hashCode ^
        saComentario.hashCode ^
        solicitudCompraFolio.hashCode ^
        idUserAutoriza.hashCode;
  }

  // Método auxiliar para parsear DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      throw FormatException('Formato de fecha no válido: $dateValue');
    }
  }
}
