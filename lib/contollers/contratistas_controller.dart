import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class ContratistasController {
  final AuthService _authService = AuthService();

  Future<List<Contratistas>> listContratistas() async {
    try {
      final response = await http.get(
          Uri.parse('${_authService.apiURL}/Contratistas'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'});

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listContra) => Contratistas.fromMap(listContra))
            .toList();
      } else {
        print(
            'Error getContratistas | Ife | ContratistasController: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getContratistas | Try | ContratistasController: $e');
      return [];
    }
  }

  Future<Contratistas?> getContratistaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Contratistas/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Contratistas.fromMap(jsonData);
      } else {
        print(
            'Error getContratistaById | Ife | ContratistasController: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getContratistaById | Try | ContratistasController: $e');
      return null;
    }
  }

  Future<bool> addContratista(Contratistas contratista) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Contratistas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: contratista.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addContratista | Ife | ContratistasController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addContratista | Try | ContratistasController: $e');
      return false;
    }
  }

  Future<bool> editContratista(Contratistas contratista) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${_authService.apiURL}/Contratistas/${contratista.idContratista}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: contratista.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error editContratista | Ife | ContratistasController: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error editContratista | Try | ContratistasController: $e');
      return false;
    }
  }
}

class Contratistas {
  final int idContratista;
  final String contratistaNombre;
  final String contratistaDireccion;
  final String contratistaTelefono;
  final String contratistaNumeroCuenta;
  Contratistas({
    required this.idContratista,
    required this.contratistaNombre,
    required this.contratistaDireccion,
    required this.contratistaTelefono,
    required this.contratistaNumeroCuenta,
  });

  Contratistas copyWith({
    int? idContratista,
    String? contratistaNombre,
    String? contratistaDireccion,
    String? contratistaTelefono,
    String? contratistaNumeroCuenta,
  }) {
    return Contratistas(
      idContratista: idContratista ?? this.idContratista,
      contratistaNombre: contratistaNombre ?? this.contratistaNombre,
      contratistaDireccion: contratistaDireccion ?? this.contratistaDireccion,
      contratistaTelefono: contratistaTelefono ?? this.contratistaTelefono,
      contratistaNumeroCuenta:
          contratistaNumeroCuenta ?? this.contratistaNumeroCuenta,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idContratista': idContratista,
      'contratistaNombre': contratistaNombre,
      'contratistaDireccion': contratistaDireccion,
      'contratistaTelefono': contratistaTelefono,
      'contratistaNumeroCuenta': contratistaNumeroCuenta,
    };
  }

  factory Contratistas.fromMap(Map<String, dynamic> map) {
    return Contratistas(
      idContratista: map['idContratista'] as int,
      contratistaNombre: map['contratistaNombre'] as String,
      contratistaDireccion: map['contratistaDireccion'] as String,
      contratistaTelefono: map['contratistaTelefono'] as String,
      contratistaNumeroCuenta: map['contratistaNumeroCuenta'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Contratistas.fromJson(String source) =>
      Contratistas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Contratistas(idContratista: $idContratista, contratistaNombre: $contratistaNombre, contratistaDireccion: $contratistaDireccion, contratistaTelefono: $contratistaTelefono, contratistaNumeroCuenta: $contratistaNumeroCuenta)';
  }

  @override
  bool operator ==(covariant Contratistas other) {
    if (identical(this, other)) return true;

    return other.idContratista == idContratista &&
        other.contratistaNombre == contratistaNombre &&
        other.contratistaDireccion == contratistaDireccion &&
        other.contratistaTelefono == contratistaTelefono &&
        other.contratistaNumeroCuenta == contratistaNumeroCuenta;
  }

  @override
  int get hashCode {
    return idContratista.hashCode ^
        contratistaNombre.hashCode ^
        contratistaDireccion.hashCode ^
        contratistaTelefono.hashCode ^
        contratistaNumeroCuenta.hashCode;
  }
}
