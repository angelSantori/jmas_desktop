// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:jmas_desktop/service/auth_service.dart';
//import 'package:http/http.dart' as http;

class LectenviarController {
  final AuthService _authService = AuthService();

  Future<List<LectEnviar>> listLecturas() async {
    try {
      final client =
          HttpClient()
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;

      final request = await client.getUrl(
        Uri.parse('${_authService.apiURL}/LectEnviars'),
      );

      request.headers.add('Content-Type', 'application/json; charset=UTF-8');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // ignore: avoid_print
      print(responseBody);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(responseBody);
        return jsonData.map((lectura) => LectEnviar.fromMap(lectura)).toList();
      } else {
        // ignore: avoid_print
        print('Error: ${response.statusCode} - $responseBody');
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      return [];
    }
  }

  Future<bool> updateLectura(LectEnviar lectura, File? imageFile) async {
    try {
      final client =
          HttpClient()
            ..badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;

      final request = await client.putUrl(
        Uri.parse('${_authService.apiURL}/LectEnviars/${lectura.idLectEnviar}'),
      );

      request.headers.add('Content-Type', 'application/json; charset=UTF-8');

      String? img64;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        img64 = base64Encode(bytes);
      }

      // Crear copia de la lectura con la imagen actualizada
      final updatedLectura = lectura.copyWith(
        lecact: lectura.lecact,
        idProblema: lectura.idProblema,
        observ: lectura.observ,
        img64: img64 ?? lectura.img64,
        estado: true, // Marcar como editado
      );

      // Convertir a JSON y enviar
      final jsonData = updatedLectura.toMap();
      request.write(json.encode(jsonData));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 204) {
        // ignore: avoid_print
        print('Registro actualizado exitosamente');
        return true;
      } else {
        // ignore: avoid_print
        print(
          'Error al actualizar registro | Update | Ife: ${response.statusCode} - $responseBody',
        );
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar registro | Update | TryCatch: $e');
      return false;
    }
  }
}

class IOClient {}

class LectEnviar {
  int? idLectEnviar;
  String? junta;
  String? lecturista;
  String? fecven;
  String? feccor;
  int? cuenta;
  String? nombre;
  String? direccion;
  String? colonia;
  int? contrato;
  int? mesade;
  String? felean;
  String? servicio;
  String? tarifa;
  String? medidor;
  int? lecant;
  String? observ;
  int? lecact;
  int? ruta;
  int? promedio;
  String? leansn;
  String? zona;
  int? idUsuario;
  bool? estado;
  String? img64;
  String? ubicacion;
  int? conteo;
  int? idProblema;
  LectEnviar({
    this.idLectEnviar,
    this.junta,
    this.lecturista,
    this.fecven,
    this.feccor,
    this.cuenta,
    this.nombre,
    this.direccion,
    this.colonia,
    this.contrato,
    this.mesade,
    this.felean,
    this.servicio,
    this.tarifa,
    this.medidor,
    this.lecant,
    this.observ,
    this.lecact,
    this.ruta,
    this.promedio,
    this.leansn,
    this.zona,
    this.idUsuario,
    this.estado,
    this.img64,
    this.ubicacion,
    this.conteo,
    this.idProblema,
  });

  LectEnviar copyWith({
    int? idLectEnviar,
    String? junta,
    String? lecturista,
    String? fecven,
    String? feccor,
    int? cuenta,
    String? nombre,
    String? direccion,
    String? colonia,
    int? contrato,
    int? mesade,
    String? felean,
    String? servicio,
    String? tarifa,
    String? medidor,
    int? lecant,
    String? observ,
    int? lecact,
    int? ruta,
    int? promedio,
    String? leansn,
    String? zona,
    int? idUsuario,
    bool? estado,
    String? img64,
    String? ubicacion,
    int? conteo,
    int? idProblema,
  }) {
    return LectEnviar(
      idLectEnviar: idLectEnviar ?? this.idLectEnviar,
      junta: junta ?? this.junta,
      lecturista: lecturista ?? this.lecturista,
      fecven: fecven ?? this.fecven,
      feccor: feccor ?? this.feccor,
      cuenta: cuenta ?? this.cuenta,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      colonia: colonia ?? this.colonia,
      contrato: contrato ?? this.contrato,
      mesade: mesade ?? this.mesade,
      felean: felean ?? this.felean,
      servicio: servicio ?? this.servicio,
      tarifa: tarifa ?? this.tarifa,
      medidor: medidor ?? this.medidor,
      lecant: lecant ?? this.lecant,
      observ: observ ?? this.observ,
      lecact: lecact ?? this.lecact,
      ruta: ruta ?? this.ruta,
      promedio: promedio ?? this.promedio,
      leansn: leansn ?? this.leansn,
      zona: zona ?? this.zona,
      idUsuario: idUsuario ?? this.idUsuario,
      estado: estado ?? this.estado,
      img64: img64 ?? this.img64,
      ubicacion: ubicacion ?? this.ubicacion,
      conteo: conteo ?? this.conteo,
      idProblema: idProblema ?? this.idProblema,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idLectEnviar': idLectEnviar,
      'junta': junta,
      'lecturista': lecturista,
      'fecven': fecven,
      'feccor': feccor,
      'cuenta': cuenta,
      'nombre': nombre,
      'direccion': direccion,
      'colonia': colonia,
      'contrato': contrato,
      'mesade': mesade,
      'felean': felean,
      'servicio': servicio,
      'tarifa': tarifa,
      'medidor': medidor,
      'lecant': lecant,
      'observ': observ,
      'lecact': lecact,
      'ruta': ruta,
      'promedio': promedio,
      'leansn': leansn,
      'zona': zona,
      'idUsuario': idUsuario,
      'estado': estado,
      'img64': img64,
      'ubicacion': ubicacion,
      'conteo': conteo,
      'idProblema': idProblema,
    };
  }

  factory LectEnviar.fromMap(Map<String, dynamic> map) {
    return LectEnviar(
      idLectEnviar:
          map['idLectEnviar'] != null ? map['idLectEnviar'] as int : null,
      junta: map['junta'] != null ? map['junta'] as String : null,
      lecturista:
          map['lecturista'] != null ? map['lecturista'] as String : null,
      fecven: map['fecven'] != null ? map['fecven'] as String : null,
      feccor: map['feccor'] != null ? map['feccor'] as String : null,
      cuenta: map['cuenta'] != null ? map['cuenta'] as int : null,
      nombre: map['nombre'] != null ? map['nombre'] as String : null,
      direccion: map['direccion'] != null ? map['direccion'] as String : null,
      colonia: map['colonia'] != null ? map['colonia'] as String : null,
      contrato: map['contrato'] != null ? map['contrato'] as int : null,
      mesade: map['mesade'] != null ? map['mesade'] as int : null,
      felean: map['felean'] != null ? map['felean'] as String : null,
      servicio: map['servicio'] != null ? map['servicio'] as String : null,
      tarifa: map['tarifa'] != null ? map['tarifa'] as String : null,
      medidor: map['medidor'] != null ? map['medidor'] as String : null,
      lecant: map['lecant'] != null ? map['lecant'] as int : null,
      observ: map['observ'] != null ? map['observ'] as String : null,
      lecact: map['lecact'] != null ? map['lecact'] as int : null,
      ruta: map['ruta'] != null ? map['ruta'] as int : null,
      promedio: map['promedio'] != null ? map['promedio'] as int : null,
      leansn: map['leansn'] != null ? map['leansn'] as String : null,
      zona: map['zona'] != null ? map['zona'] as String : null,
      idUsuario: map['idUsuario'] != null ? map['idUsuario'] as int : null,
      estado: map['estado'] != null ? map['estado'] as bool : null,
      img64: map['img64'] != null ? map['img64'] as String : null,
      ubicacion: map['ubicacion'] != null ? map['ubicacion'] as String : null,
      conteo: map['conteo'] != null ? map['conteo'] as int : null,
      idProblema: map['idProblema'] != null ? map['idProblema'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LectEnviar.fromJson(String source) =>
      LectEnviar.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LectEnviar(idLectEnviar: $idLectEnviar, junta: $junta, lecturista: $lecturista, fecven: $fecven, feccor: $feccor, cuenta: $cuenta, nombre: $nombre, direccion: $direccion, colonia: $colonia, contrato: $contrato, mesade: $mesade, felean: $felean, servicio: $servicio, tarifa: $tarifa, medidor: $medidor, lecant: $lecant, observ: $observ, lecact: $lecact, ruta: $ruta, promedio: $promedio, leansn: $leansn, zona: $zona, idUsuario: $idUsuario, estado: $estado, img64: $img64, ubicacion: $ubicacion, conteo: $conteo, idProblema: $idProblema)';
  }

  @override
  bool operator ==(covariant LectEnviar other) {
    if (identical(this, other)) return true;

    return other.idLectEnviar == idLectEnviar &&
        other.junta == junta &&
        other.lecturista == lecturista &&
        other.fecven == fecven &&
        other.feccor == feccor &&
        other.cuenta == cuenta &&
        other.nombre == nombre &&
        other.direccion == direccion &&
        other.colonia == colonia &&
        other.contrato == contrato &&
        other.mesade == mesade &&
        other.felean == felean &&
        other.servicio == servicio &&
        other.tarifa == tarifa &&
        other.medidor == medidor &&
        other.lecant == lecant &&
        other.observ == observ &&
        other.lecact == lecact &&
        other.ruta == ruta &&
        other.promedio == promedio &&
        other.leansn == leansn &&
        other.zona == zona &&
        other.idUsuario == idUsuario &&
        other.estado == estado &&
        other.img64 == img64 &&
        other.ubicacion == ubicacion &&
        other.conteo == conteo &&
        other.idProblema == idProblema;
  }

  @override
  int get hashCode {
    return idLectEnviar.hashCode ^
        junta.hashCode ^
        lecturista.hashCode ^
        fecven.hashCode ^
        feccor.hashCode ^
        cuenta.hashCode ^
        nombre.hashCode ^
        direccion.hashCode ^
        colonia.hashCode ^
        contrato.hashCode ^
        mesade.hashCode ^
        felean.hashCode ^
        servicio.hashCode ^
        tarifa.hashCode ^
        medidor.hashCode ^
        lecant.hashCode ^
        observ.hashCode ^
        lecact.hashCode ^
        ruta.hashCode ^
        promedio.hashCode ^
        leansn.hashCode ^
        zona.hashCode ^
        idUsuario.hashCode ^
        estado.hashCode ^
        img64.hashCode ^
        ubicacion.hashCode ^
        conteo.hashCode ^
        idProblema.hashCode;
  }
}
