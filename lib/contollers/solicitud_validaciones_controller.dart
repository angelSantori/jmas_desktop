import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class SolicitudValidacionesController {
  final AuthService _authService = AuthService();

  Future<List<SolicitudValidaciones>> getSolicitudValidacionByFolio(
      String folio) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/SolicitudValidaciones/ByFolio/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listSV) => SolicitudValidaciones.fromMap(listSV))
            .toList();
      } else {
        print(
            'Error getSolicitudValidacionByFolio | Ife | SolicitudValidacionesController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Error getSolicitudValidacionByFolio | Try | SolicitudValidacionesController: $e');
      return [];
    }
  }

  Future<bool> addSolicitudValidacion(
      SolicitudValidaciones solicitudValidacion) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/SolicitudValidaciones'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: solicitudValidacion.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addSolicitudValidacion | Ife | SolicitudValidacionesController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print(
          'Error addSolicitudValidacion | Try | SolicitudValidacionesController: $e');
      return false;
    }
  }
}

class SolicitudValidaciones {
  final int idSolicitudValidacion;
  final DateTime svFecha;
  final String svEstado;
  final String svComentario;
  final String solicitudCompraFolio;
  final int idUserValida;
  SolicitudValidaciones({
    required this.idSolicitudValidacion,
    required this.svFecha,
    required this.svEstado,
    required this.svComentario,
    required this.solicitudCompraFolio,
    required this.idUserValida,
  });

  SolicitudValidaciones copyWith({
    int? idSolicitudValidacion,
    DateTime? svFecha,
    String? svEstado,
    String? svComentario,
    String? solicitudCompraFolio,
    int? idUserValida,
  }) {
    return SolicitudValidaciones(
      idSolicitudValidacion:
          idSolicitudValidacion ?? this.idSolicitudValidacion,
      svFecha: svFecha ?? this.svFecha,
      svEstado: svEstado ?? this.svEstado,
      svComentario: svComentario ?? this.svComentario,
      solicitudCompraFolio: solicitudCompraFolio ?? this.solicitudCompraFolio,
      idUserValida: idUserValida ?? this.idUserValida,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idSolicitudValidacion': idSolicitudValidacion,
      'svFecha': svFecha.toIso8601String(),
      'svEstado': svEstado,
      'svComentario': svComentario,
      'solicitudCompraFolio': solicitudCompraFolio,
      'idUserValida': idUserValida,
    };
  }

  factory SolicitudValidaciones.fromMap(Map<String, dynamic> map) {
    return SolicitudValidaciones(
      idSolicitudValidacion: map['idSolicitudValidacion'] as int,
      svFecha: _parseDateTime(map['svFecha']),
      svEstado: map['svEstado'] as String,
      svComentario: map['svComentario'] as String,
      solicitudCompraFolio: map['solicitudCompraFolio'] as String,
      idUserValida: map['idUserValida'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SolicitudValidaciones.fromJson(String source) =>
      SolicitudValidaciones.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SolicitudValidaciones(idSolicitudValidacion: $idSolicitudValidacion, svFecha: $svFecha, svEstado: $svEstado, svComentario: $svComentario, solicitudCompraFolio: $solicitudCompraFolio, idUserValida: $idUserValida)';
  }

  @override
  bool operator ==(covariant SolicitudValidaciones other) {
    if (identical(this, other)) return true;

    return other.idSolicitudValidacion == idSolicitudValidacion &&
        other.svFecha == svFecha &&
        other.svEstado == svEstado &&
        other.svComentario == svComentario &&
        other.solicitudCompraFolio == solicitudCompraFolio &&
        other.idUserValida == idUserValida;
  }

  @override
  int get hashCode {
    return idSolicitudValidacion.hashCode ^
        svFecha.hashCode ^
        svEstado.hashCode ^
        svComentario.hashCode ^
        solicitudCompraFolio.hashCode ^
        idUserValida.hashCode;
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
