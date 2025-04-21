import 'dart:convert';
import 'dart:io';
import 'package:jmas_desktop/service/auth_service.dart';

class ProblemasController {
  final AuthService _authService = AuthService();

  Future<List<Problemas>> listProblemas() async {
    try {
      final client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final request = await client
          .getUrl(Uri.parse('${_authService.apiURL}/ProblemasLecturas'));

      request.headers.add('Content-Type', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(responseBody);
        return jsonData.map((problema) => Problemas.fromMap(problema)).toList();
      } else {
        print(
            'Error Lista Problemas | Ife | Controller: ${response.statusCode} - ${responseBody}');
        return [];
      }
    } catch (e) {
      print('Error Lista Problemas | TryCatch | Controller: $e');
      return [];
    }
  }
}

class Problemas {
  int? idProblema;
  String? descripcionProb;
  Problemas({
    this.idProblema,
    this.descripcionProb,
  });

  Problemas copyWith({
    int? idProblema,
    String? descripcionProb,
  }) {
    return Problemas(
      idProblema: idProblema ?? this.idProblema,
      descripcionProb: descripcionProb ?? this.descripcionProb,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idProblema': idProblema,
      'descripcionProb': descripcionProb,
    };
  }

  factory Problemas.fromMap(Map<String, dynamic> map) {
    return Problemas(
      idProblema: map['idProblema'] != null ? map['idProblema'] as int : null,
      descripcionProb: map['descripcionProb'] != null
          ? map['descripcionProb'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Problemas.fromJson(String source) =>
      Problemas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Problemas(idProblema: $idProblema, descripcionProb: $descripcionProb)';

  @override
  bool operator ==(covariant Problemas other) {
    if (identical(this, other)) return true;

    return other.idProblema == idProblema &&
        other.descripcionProb == descripcionProb;
  }

  @override
  int get hashCode => idProblema.hashCode ^ descripcionProb.hashCode;
}
