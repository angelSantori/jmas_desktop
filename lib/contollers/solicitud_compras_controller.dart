import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class SolicitudComprasController {
  final AuthService _authService = AuthService();

  Future<List<SolicitudCompras>> listSolicitudCompras() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/SolicitudCompras'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map(
              (listSC) => SolicitudCompras.fromMap(listSC),
            )
            .toList();
      } else {
        print(
            'Error listSolicitudes | Ife | SolicitudComprasController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listSolicitudes | Try | SolicitudComprasController: $e');
      return [];
    }
  }

  Future<List<SolicitudCompras>> getSolicitudComprasByFolio(
      String folio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/SolicitudCompras/ByFolio/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map(
              (sc) => SolicitudCompras.fromMap(sc),
            )
            .toList();
      } else {
        print(
            'Error getSolicitudComprasByFolio | Ife | SolicitudComprasController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Error getSolicitudComprasByFolio | Try | SolicitudComprasController: $e');
      return [];
    }
  }

  Future<List<SolicitudCompras>?> addMultipleSolicitudCompras(
      List<SolicitudCompras> solicitudCompra) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/SolicitudCompras/Multiple'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(solicitudCompra.map((sc) => sc.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((sc) => SolicitudCompras.fromMap(sc)).toList();
      } else {
        print(
            'Error addMultipleSolicitudCompras | Ife | SolicitudComprasController: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(
          'Error addMultipleSolicitudCompras | Try | SolicitudComprasController: $e');
      return null;
    }
  }

  Future<bool> updateSolicitudComprasEstadoValida(
      String folio, String nuevoEstado, int idUserValida) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/SolicitudCompras/UpdateEstadoByFolioValida/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'nuevoEstado': nuevoEstado, 'IdUser': idUserValida}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error updateSolicitudComprasEstadoValida | Ife | SolicitudComprasController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print(
          'Error updateSolicitudComprasEstadoValida | Try | SolicitudComprasController: $e');
      return false;
    }
  }

  Future<bool> updateSolicitudComprasEstadoAutoriza(
      String folio, String nuevoEstado, int idUserValida) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/SolicitudCompras/UpdateEstadoByFolioAutoriza/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'nuevoEstado': nuevoEstado, 'IdUser': idUserValida}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error updateSolicitudComprasEstadoAutoriza | Ife | SolicitudComprasController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print(
          'Error updateSolicitudComprasEstadoAutoriza | Try | SolicitudComprasController: $e');
      return false;
    }
  }
}

class SolicitudCompras {
  final int idSolicitudCompra;
  final String scFolio;
  final String scEstado;
  final DateTime scFecha;
  final String scObjetivo;
  final String scEspecificaciones;
  final String scObservaciones;
  final int idProducto;
  final double scCantidadProductos;
  final double scTotalCostoProductos;
  final int idUserSolicita;
  final int? idUserValida;
  final int? idUserAutoriza;
  SolicitudCompras({
    required this.idSolicitudCompra,
    required this.scFolio,
    required this.scEstado,
    required this.scFecha,
    required this.scObjetivo,
    required this.scEspecificaciones,
    required this.scObservaciones,
    required this.idProducto,
    required this.scCantidadProductos,
    required this.scTotalCostoProductos,
    required this.idUserSolicita,
    this.idUserValida,
    this.idUserAutoriza,
  });

  SolicitudCompras copyWith({
    int? idSolicitudCompra,
    String? scFolio,
    String? scEstado,
    DateTime? scFecha,
    String? scObjetivo,
    String? scEspecificaciones,
    String? scObservaciones,
    int? idProducto,
    double? scCantidadProductos,
    double? scTotalCostoProductos,
    int? idUserSolicita,
    int? idUserValida,
    int? idUserAutoriza,
  }) {
    return SolicitudCompras(
      idSolicitudCompra: idSolicitudCompra ?? this.idSolicitudCompra,
      scFolio: scFolio ?? this.scFolio,
      scEstado: scEstado ?? this.scEstado,
      scFecha: scFecha ?? this.scFecha,
      scObjetivo: scObjetivo ?? this.scObjetivo,
      scEspecificaciones: scEspecificaciones ?? this.scEspecificaciones,
      scObservaciones: scObservaciones ?? this.scObservaciones,
      idProducto: idProducto ?? this.idProducto,
      scCantidadProductos: scCantidadProductos ?? this.scCantidadProductos,
      scTotalCostoProductos:
          scTotalCostoProductos ?? this.scTotalCostoProductos,
      idUserSolicita: idUserSolicita ?? this.idUserSolicita,
      idUserValida: idUserValida ?? this.idUserValida,
      idUserAutoriza: idUserAutoriza ?? this.idUserAutoriza,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idSolicitudCompra': idSolicitudCompra,
      'scFolio': scFolio,
      'scEstado': scEstado,
      'scFecha': scFecha.toIso8601String(),
      'scObjetivo': scObjetivo,
      'scEspecificaciones': scEspecificaciones,
      'scObservaciones': scObservaciones,
      'idProducto': idProducto,
      'scCantidadProductos': scCantidadProductos,
      'scTotalCostoProductos': scTotalCostoProductos,
      'idUserSolicita': idUserSolicita,
      'idUserValida': idUserValida,
      'idUserAutoriza': idUserAutoriza,
    };
  }

  factory SolicitudCompras.fromMap(Map<String, dynamic> map) {
    return SolicitudCompras(
      idSolicitudCompra: map['idSolicitudCompra'] as int,
      scFolio: map['scFolio'] as String,
      scEstado: map['scEstado'] as String,
      scFecha: _parseDateTime(map['scFecha']),
      scObjetivo: map['scObjetivo'] as String,
      scEspecificaciones: map['scEspecificaciones'] as String,
      scObservaciones: map['scObservaciones'] as String,
      idProducto: map['idProducto'] as int,
      scCantidadProductos: map['scCantidadProductos'] as double,
      scTotalCostoProductos: map['scTotalCostoProductos'] as double,
      idUserSolicita: map['idUserSolicita'] as int,
      idUserValida:
          map['idUserValida'] != null ? map['idUserValida'] as int : null,
      idUserAutoriza:
          map['idUserAutoriza'] != null ? map['idUserAutoriza'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SolicitudCompras.fromJson(String source) =>
      SolicitudCompras.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SolicitudCompras(idSolicitudCompra: $idSolicitudCompra, scFolio: $scFolio, scEstado: $scEstado, scFecha: $scFecha, scObjetivo: $scObjetivo, scEspecificaciones: $scEspecificaciones, scObservaciones: $scObservaciones, idProducto: $idProducto, scCantidadProductos: $scCantidadProductos, scTotalCostoProductos: $scTotalCostoProductos, idUserSolicita: $idUserSolicita, idUserValida: $idUserValida, idUserAutoriza: $idUserAutoriza)';
  }

  @override
  bool operator ==(covariant SolicitudCompras other) {
    if (identical(this, other)) return true;

    return other.idSolicitudCompra == idSolicitudCompra &&
        other.scFolio == scFolio &&
        other.scEstado == scEstado &&
        other.scFecha == scFecha &&
        other.scObjetivo == scObjetivo &&
        other.scEspecificaciones == scEspecificaciones &&
        other.scObservaciones == scObservaciones &&
        other.idProducto == idProducto &&
        other.scCantidadProductos == scCantidadProductos &&
        other.scTotalCostoProductos == scTotalCostoProductos &&
        other.idUserSolicita == idUserSolicita &&
        other.idUserValida == idUserValida &&
        other.idUserAutoriza == idUserAutoriza;
  }

  @override
  int get hashCode {
    return idSolicitudCompra.hashCode ^
        scFolio.hashCode ^
        scEstado.hashCode ^
        scFecha.hashCode ^
        scObjetivo.hashCode ^
        scEspecificaciones.hashCode ^
        scObservaciones.hashCode ^
        idProducto.hashCode ^
        scCantidadProductos.hashCode ^
        scTotalCostoProductos.hashCode ^
        idUserSolicita.hashCode ^
        idUserValida.hashCode ^
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
