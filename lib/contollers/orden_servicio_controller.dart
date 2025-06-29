// Librerías
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class OrdenServicioController {
  final AuthService _authService = AuthService();

  //GET
  //List
  Future<List<OrdenServicio>> listOrdenServicio() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/OrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((listOT) => OrdenServicio.fromMap(listOT)).toList();
      } else {
        print(
          'Error listOrdenServicio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listOrdenServicio | Try | Controller: $e');
      return [];
    }
  }

  Future<List<OrdenServicio>> listOTXFolio(String folio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/OrdenServicios/ByFolio/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((listOtXF) => OrdenServicio.fromMap(listOtXF))
            .toList();
      } else {
        print(
          'Error listOTXFolio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error listOTXFolio | Try | Controller: $e');
      return [];
    }
  }

  Future<String> getNextOTFolio() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/OrdenServicios/nextOTFolio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(
          'Error getNextOTFolio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return '';
      }
    } catch (e) {
      print('Error getNextOTFolio | Try | Controller: $e');
      return '';
    }
  }

  //GetXId
  Future<OrdenServicio?> getOrdenServicioXId(int idOT) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/OrdenServicios/$idOT'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return OrdenServicio.fromMap(jsonData);
      } else {
        print(
          'Error getOrdenServicioXId | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getOrdenServicioXId | Try | Controller: $e');
      return null;
    }
  }

  //POST
  //Add
  Future<bool> addOrdenServicio(OrdenServicio OrdenServicio) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/OrdenServicios'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: OrdenServicio.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
          'Error addOrdenServicio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error addOrdenServicio | Try | Controller: $e');
      return false;
    }
  }

  //Put
  //Edit
  Future<bool> editOrdenServicio(OrdenServicio OrdenServicio) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${_authService.apiURL}/OrdenServicios/${OrdenServicio.idOrdenServicio}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: OrdenServicio.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
          'Error editOrdenServicio | Ife | Controller: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error editOrdenServicio | Try | Controller: $e');
      return false;
    }
  }
}

class OrdenServicio {
  int? idOrdenServicio;
  String? folioOS;
  String? fechaOS;
  String? medioOS;
  bool? materialOS;
  String? estadoOS;
  String? prioridadOS;
  int? idUser;
  int? idPadron;
  int? idTipoProblema;
  OrdenServicio({
    this.idOrdenServicio,
    this.folioOS,
    this.fechaOS,
    this.medioOS,
    this.materialOS,
    this.estadoOS,
    this.prioridadOS,
    this.idUser,
    this.idPadron,
    this.idTipoProblema,
  });

  OrdenServicio copyWith({
    int? idOrdenServicio,
    String? folioOS,
    String? fechaOS,
    String? medioOS,
    bool? materialOS,
    String? estadoOS,
    String? prioridadOS,
    int? idUser,
    int? idPadron,
    int? idTipoProblema,
  }) {
    return OrdenServicio(
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
      folioOS: folioOS ?? this.folioOS,
      fechaOS: fechaOS ?? this.fechaOS,
      medioOS: medioOS ?? this.medioOS,
      materialOS: materialOS ?? this.materialOS,
      estadoOS: estadoOS ?? this.estadoOS,
      prioridadOS: prioridadOS ?? this.prioridadOS,
      idUser: idUser ?? this.idUser,
      idPadron: idPadron ?? this.idPadron,
      idTipoProblema: idTipoProblema ?? this.idTipoProblema,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idOrdenServicio': idOrdenServicio,
      'folioOS': folioOS,
      'fechaOS': fechaOS,
      'medioOS': medioOS,
      'materialOS': materialOS,
      'estadoOS': estadoOS,
      'prioridadOS': prioridadOS,
      'idUser': idUser,
      'idPadron': idPadron,
      'idTipoProblema': idTipoProblema,
    };
  }

  factory OrdenServicio.fromMap(Map<String, dynamic> map) {
    return OrdenServicio(
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
      folioOS: map['folioOS'] != null ? map['folioOS'] as String : null,
      fechaOS: map['fechaOS'] != null ? map['fechaOS'] as String : null,
      medioOS: map['medioOS'] != null ? map['medioOS'] as String : null,
      materialOS: map['materialOS'] != null ? map['materialOS'] as bool : null,
      estadoOS: map['estadoOS'] != null ? map['estadoOS'] as String : null,
      prioridadOS:
          map['prioridadOS'] != null ? map['prioridadOS'] as String : null,
      idUser: map['idUser'] != null ? map['idUser'] as int : null,
      idPadron: map['idPadron'] != null ? map['idPadron'] as int : null,
      idTipoProblema:
          map['idTipoProblema'] != null ? map['idTipoProblema'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrdenServicio.fromJson(String source) =>
      OrdenServicio.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrdenServicio(idOrdenServicio: $idOrdenServicio, folioOS: $folioOS, fechaOS: $fechaOS, medioOS: $medioOS, materialOS: $materialOS, estadoOS: $estadoOS, prioridadOS: $prioridadOS, idUser: $idUser, idPadron: $idPadron, idTipoProblema: $idTipoProblema)';
  }

  @override
  bool operator ==(covariant OrdenServicio other) {
    if (identical(this, other)) return true;

    return other.idOrdenServicio == idOrdenServicio &&
        other.folioOS == folioOS &&
        other.fechaOS == fechaOS &&
        other.medioOS == medioOS &&
        other.materialOS == materialOS &&
        other.estadoOS == estadoOS &&
        other.prioridadOS == prioridadOS &&
        other.idUser == idUser &&
        other.idPadron == idPadron &&
        other.idTipoProblema == idTipoProblema;
  }

  @override
  int get hashCode {
    return idOrdenServicio.hashCode ^
        folioOS.hashCode ^
        fechaOS.hashCode ^
        medioOS.hashCode ^
        materialOS.hashCode ^
        estadoOS.hashCode ^
        prioridadOS.hashCode ^
        idUser.hashCode ^
        idPadron.hashCode ^
        idTipoProblema.hashCode;
  }
}
