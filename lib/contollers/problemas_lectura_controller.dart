import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class ProblemasLecturaController {
  final AuthService _authService = AuthService();

  Future<List<ProblemasLectura>> listProblmeasLectura() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/ProblemasLecturas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listPL) => ProblemasLectura.fromMap(listPL))
            .toList();
      } else {
        print(
          'Error listProblmeasLectura | Ife | PLController: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listProblmeasLectura | Try | PLController: $e');
      return [];
    }
  }

  Future<ProblemasLectura?> getProblemaById(int? idProblema) async {
    if (idProblema == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/ProblemasLecturas/$idProblema'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ProblemasLectura.fromMap(jsonData);
      } else {
        print(
          'Error getProblemaById | Ife | PLController: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getProblemaById | Try | PLController: $e');
      return null;
    }
  }

// Método alternativo: obtener todos los problemas y buscar por ID
  Future<String?> getNombreProblemaById(int? idProblema) async {
    if (idProblema == null) return null;

    final problemas = await listProblmeasLectura();
    final problema = problemas.firstWhere(
      (p) => p.idProblema == idProblema,
      orElse: () =>
          ProblemasLectura(idProblema: -1, plDescripcion: 'Desconocido'),
    );

    return problema.plDescripcion;
  }
}

class ProblemasLectura {
  final int idProblema;
  final String plDescripcion;
  ProblemasLectura({required this.idProblema, required this.plDescripcion});

  ProblemasLectura copyWith({int? idProblema, String? plDescripcion}) {
    return ProblemasLectura(
      idProblema: idProblema ?? this.idProblema,
      plDescripcion: plDescripcion ?? this.plDescripcion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idProblema': idProblema,
      'plDescripcion': plDescripcion,
    };
  }

  factory ProblemasLectura.fromMap(Map<String, dynamic> map) {
    return ProblemasLectura(
      idProblema: map['idProblema'] as int,
      plDescripcion: map['plDescripcion'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProblemasLectura.fromJson(String source) =>
      ProblemasLectura.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ProblemasLectura(idProblema: $idProblema, plDescripcion: $plDescripcion)';

  @override
  bool operator ==(covariant ProblemasLectura other) {
    if (identical(this, other)) return true;

    return other.idProblema == idProblema &&
        other.plDescripcion == plDescripcion;
  }

  @override
  int get hashCode => idProblema.hashCode ^ plDescripcion.hashCode;
}
