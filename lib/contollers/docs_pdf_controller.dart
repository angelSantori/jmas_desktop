import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class DocsPdfController {
  final AuthService _authService = AuthService();

  //List
  Future<List<DocsPdfs>> listDocPdf() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DocumentPdfs'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listDocPdf) => DocsPdfs.fromMap(listDocPdf))
            .toList();
      } else {
        print(
            'Error listDocPdf | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listDocPdf | Try | Controller: $e');
      return [];
    }
  }

  // Método para listar documentos PDF
  Future<List<Map<String, dynamic>>> listPdfDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/DocumentPdfs'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      }
      throw Exception(
          'Error al cargar documentos: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error listPdfDocuments | Try | Controller: $e');
      rethrow;
    }
  }

  //Descargar
  Future<Uint8List> downloadPdf(int idDocumentPdf) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiURL}/DocumentPdfs/download/$idDocumentPdf'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Return the raw bytes directly, no need to decode
        return response.bodyBytes;
      }
      throw Exception(
          'Error al descargar PDF: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error downloadPdf | Try | Controller: $e');
      rethrow;
    }
  }

  //Guardar PDF
  Future<bool> savePdf({
    required String nombreDocPdf,
    required String fechaDocPdf,
    required String dataDocPdf,
    required int idUser,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/DocumentPdfs/save-pdf'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nombreDocPdf': nombreDocPdf,
          'fechaDocPdf': fechaDocPdf,
          'dataDocPdf': dataDocPdf,
          'idUser': idUser,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error savePDF | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sacePdf | Try | Controller: $e');
      return false;
    }
  }

  // Agregar este nuevo método a la clase DocsPdfController
  Future<List<Map<String, dynamic>>> searchPdfDocuments({
    String? name,
    String? docType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Construir la URL con los parámetros de búsqueda
      final uri =
          Uri.parse('${_authService.apiURL}/DocumentPdfs/search').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (docType != null) 'docType': docType,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      }
      throw Exception(
          'Error al buscar documentos: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error searchPdfDocuments | Try | Controller: $e');
      rethrow;
    }
  }
}

class DocsPdfs {
  int? idDocumentPdf;
  String? nombreDocPdf;
  String? fechaDocPdf;
  String? dataDocPdf;
  int? idUser;
  DocsPdfs({
    this.idDocumentPdf,
    this.nombreDocPdf,
    this.fechaDocPdf,
    this.dataDocPdf,
    this.idUser,
  });

  DocsPdfs copyWith({
    int? idDocumentPdf,
    String? nombreDocPdf,
    String? fechaDocPdf,
    String? dataDocPdf,
    int? idUser,
  }) {
    return DocsPdfs(
      idDocumentPdf: idDocumentPdf ?? this.idDocumentPdf,
      nombreDocPdf: nombreDocPdf ?? this.nombreDocPdf,
      fechaDocPdf: fechaDocPdf ?? this.fechaDocPdf,
      dataDocPdf: dataDocPdf ?? this.dataDocPdf,
      idUser: idUser ?? this.idUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idDocumentPdf': idDocumentPdf,
      'nombreDocPdf': nombreDocPdf,
      'fechaDocPdf': fechaDocPdf,
      'dataDocPdf': dataDocPdf,
      'idUser': idUser,
    };
  }

  factory DocsPdfs.fromMap(Map<String, dynamic> map) {
    return DocsPdfs(
      idDocumentPdf:
          map['idDocumentPdf'] != null ? map['idDocumentPdf'] as int : null,
      nombreDocPdf:
          map['nombreDocPdf'] != null ? map['nombreDocPdf'] as String : null,
      fechaDocPdf:
          map['fechaDocPdf'] != null ? map['fechaDocPdf'] as String : null,
      dataDocPdf:
          map['dataDocPdf'] != null ? map['dataDocPdf'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocsPdfs.fromJson(String source) =>
      DocsPdfs.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DocsPdfs(idDocumentPdf: $idDocumentPdf, nombreDocPdf: $nombreDocPdf, fechaDocPdf: $fechaDocPdf, dataDocPdf: $dataDocPdf, idUser: $idUser)';
  }

  @override
  bool operator ==(covariant DocsPdfs other) {
    if (identical(this, other)) return true;

    return other.idDocumentPdf == idDocumentPdf &&
        other.nombreDocPdf == nombreDocPdf &&
        other.fechaDocPdf == fechaDocPdf &&
        other.dataDocPdf == dataDocPdf &&
        other.idUser == idUser;
  }

  @override
  int get hashCode {
    return idDocumentPdf.hashCode ^
        nombreDocPdf.hashCode ^
        fechaDocPdf.hashCode ^
        dataDocPdf.hashCode ^
        idUser.hashCode;
  }
}
