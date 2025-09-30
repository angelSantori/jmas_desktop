import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

//TODO: Crear aquí y en back la busqueda de salida x idproducto

class SalidasController {
  final AuthService _authService = AuthService();
  static List<Salidas>? cacheSalidas;

  Future<List<Salidas>> listSalidas() async {
    try {
      final response =
          await http.get(Uri.parse('${_authService.apiURL}/Salidas'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((salida) => Salidas.fromMap(salida)).toList();
      } else {
        print(
            'Error al obtener la lista de salidas: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista salidas: $e');
      return [];
    }
  }

  Future<List<SalidaLista>> listSalidasOptimizado() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Salidas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((salida) => SalidaLista.fromMap(salida)).toList();
      } else {
        print(
            'Error listSalidasOptimizadas | Ife | SalidasController: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error listSalidasOptimizadas | Try | SalidasController: $e');
      return [];
    }
  }

  Future<Salidas?> getSalidaDetalles(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Salidas/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Salidas.fromMap(jsonData);
      } else {
        print('Error al obtener detalles de salida: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error detalles salida: $e');
      return null;
    }
  }

  Future<List<Salidas>?> addMultipleSalidas(List<Salidas> salidas) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Salidas/Multiple'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(salidas.map((s) => s.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        cacheSalidas = null;
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => Salidas.fromMap(data)).toList();
      } else {
        print(
            'Error addMultipleSalidas: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error addMultipleSalidas: $e');
      return null;
    }
  }

  Future<Salidas?> addSalida(Salidas salida) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Salidas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: salida.toJson(),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Salidas.fromMap(responseData);
      } else {
        print(
            'Error addSalida | Ife | SalidasController: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error addSalida | Try | SalidasController: $e');
      return null;
    }
  }

  Future<List<Salidas>> getSalidaByFolio(String folio) async {
    try {
      final response = await http.get(
          Uri.parse('${_authService.apiURL}/Salidas/ByFolio/$folio'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((salida) => Salidas.fromMap(salida)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraton salidas con el folio: $folio');
        return [];
      } else {
        print(
            'Error al obtener las entradas por folio: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener las salidas poe folio: $e');
      return [];
    }
  }

  Future<bool> editSalida(Salidas salida) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Salidas/${salida.id_Salida}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: salida.toJson(),
      );
      if (response.statusCode == 204) {
        cacheSalidas = null;
        return true;
      } else {
        print(
            'Error al editar salida | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar salida | TryCatch | Controller: $e');
      return false;
    }
  }

  Future<bool> uploadDocumentoFirmas(String folio, Uint8List documento) async {
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${_authService.apiURL}/Salidas/UploadDocumentoFirmas/$folio'));

      request.files.add(http.MultipartFile.fromBytes('file', documento,
          filename: 'documento_firmas_$folio.pdf'));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error uploadDocumentoFirmas | Ife | SalidasController: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      print('Error uploadDocumentoFirmas | Try | SalidasController: $e');
      return false;
    }
  }

  Future<bool> uploadDocumentoPago(String folio, Uint8List documento) async {
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${_authService.apiURL}/Salidas/UploadDocumentoPago/$folio'));

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        documento,
        filename: 'documento_pago_$folio.pdf',
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Error uploadDocumentoPago | Ife | SalidasController: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      print('Error uploadDocumentoPago | Try | SalidasController: $e');
      return false;
    }
  }

  Future<Uint8List?> getDocumentoFirmas(String folio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Salidas/GetDocumentoFirmas/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final base64Documento = jsonData['documentoBase64'];
        return base64Decode(base64Documento);
      } else if (response.statusCode == 404) {
        return null; // No hay documento
      } else {
        print(
            'Error al obtener documento: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getDocumentoFirmas | Try | SalidasController: $e');
      return null;
    }
  }

  Future<Uint8List?> getDocumentoPago(String folio) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Salidas/GetDocumentoPago/$folio'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final base64Doc = jsonData['documentoBase64'];
        return base64Decode(base64Doc);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print(
            'Error getDocumentoPago | Ife | SalidasController: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getDocumentoPago | Try | SalidasController: $e');
      return null;
    }
  }
}

class Salidas {
  int? id_Salida;
  String? salida_CodFolio;
  String? salida_Referencia;
  bool? salida_Estado;
  double? salida_Unidades;
  double? salida_Costo;
  String? salida_Fecha;
  String? salida_TipoTrabajo;
  String? salida_Comentario;
  String? salida_Imag64Orden;
  String? salida_DocumentoFirmas;
  String? salida_DocumentoPago;
  bool? salida_DocumentoFirma;
  bool? salida_Pagado;
  int? idProducto;
  int? id_User;
  int? id_Junta;
  int? id_Almacen;
  int? id_User_Asignado;
  int? idPadron;
  int? idCalle;
  int? idColonia;
  int? idOrdenServicio;
  int? idUserAutoriza;
  Salidas({
    this.id_Salida,
    this.salida_CodFolio,
    this.salida_Referencia,
    this.salida_Estado,
    this.salida_Unidades,
    this.salida_Costo,
    this.salida_Fecha,
    this.salida_TipoTrabajo,
    this.salida_Comentario,
    this.salida_Imag64Orden,
    this.salida_DocumentoFirmas,
    this.salida_DocumentoPago,
    this.salida_DocumentoFirma,
    this.salida_Pagado,
    this.idProducto,
    this.id_User,
    this.id_Junta,
    this.id_Almacen,
    this.id_User_Asignado,
    this.idPadron,
    this.idCalle,
    this.idColonia,
    this.idOrdenServicio,
    this.idUserAutoriza,
  });

  Salidas copyWith({
    int? id_Salida,
    String? salida_CodFolio,
    String? salida_Referencia,
    bool? salida_Estado,
    double? salida_Unidades,
    double? salida_Costo,
    String? salida_Fecha,
    String? salida_TipoTrabajo,
    String? salida_Comentario,
    String? salida_Imag64Orden,
    String? salida_DocumentoFirmas,
    String? salida_DocumentoPago,
    bool? salida_DocumentoFirma,
    bool? salida_Pagado,
    int? idProducto,
    int? id_User,
    int? id_Junta,
    int? id_Almacen,
    int? id_User_Asignado,
    int? idPadron,
    int? idCalle,
    int? idColonia,
    int? idOrdenServicio,
    int? idUserAutoriza,
  }) {
    return Salidas(
      id_Salida: id_Salida ?? this.id_Salida,
      salida_CodFolio: salida_CodFolio ?? this.salida_CodFolio,
      salida_Referencia: salida_Referencia ?? this.salida_Referencia,
      salida_Estado: salida_Estado ?? this.salida_Estado,
      salida_Unidades: salida_Unidades ?? this.salida_Unidades,
      salida_Costo: salida_Costo ?? this.salida_Costo,
      salida_Fecha: salida_Fecha ?? this.salida_Fecha,
      salida_TipoTrabajo: salida_TipoTrabajo ?? this.salida_TipoTrabajo,
      salida_Comentario: salida_Comentario ?? this.salida_Comentario,
      salida_Imag64Orden: salida_Imag64Orden ?? this.salida_Imag64Orden,
      salida_DocumentoFirmas:
          salida_DocumentoFirmas ?? this.salida_DocumentoFirmas,
      salida_DocumentoPago: salida_DocumentoPago ?? this.salida_DocumentoPago,
      salida_DocumentoFirma:
          salida_DocumentoFirma ?? this.salida_DocumentoFirma,
      salida_Pagado: salida_Pagado ?? this.salida_Pagado,
      idProducto: idProducto ?? this.idProducto,
      id_User: id_User ?? this.id_User,
      id_Junta: id_Junta ?? this.id_Junta,
      id_Almacen: id_Almacen ?? this.id_Almacen,
      id_User_Asignado: id_User_Asignado ?? this.id_User_Asignado,
      idPadron: idPadron ?? this.idPadron,
      idCalle: idCalle ?? this.idCalle,
      idColonia: idColonia ?? this.idColonia,
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
      idUserAutoriza: idUserAutoriza ?? this.idUserAutoriza,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Salida': id_Salida,
      'salida_CodFolio': salida_CodFolio,
      'salida_Referencia': salida_Referencia,
      'salida_Estado': salida_Estado,
      'salida_Unidades': salida_Unidades,
      'salida_Costo': salida_Costo,
      'salida_Fecha': salida_Fecha,
      'salida_TipoTrabajo': salida_TipoTrabajo,
      'salida_Comentario': salida_Comentario,
      'salida_Imag64Orden': salida_Imag64Orden,
      'salida_DocumentoFirmas': salida_DocumentoFirmas,
      'salida_DocumentoPago': salida_DocumentoPago,
      'salida_DocumentoFirma': salida_DocumentoFirma,
      'salida_Pagado': salida_Pagado,
      'idProducto': idProducto,
      'id_User': id_User,
      'id_Junta': id_Junta,
      'id_Almacen': id_Almacen,
      'id_User_Asignado': id_User_Asignado,
      'idPadron': idPadron,
      'idCalle': idCalle,
      'idColonia': idColonia,
      'idOrdenServicio': idOrdenServicio,
      'idUserAutoriza': idUserAutoriza,
    };
  }

  factory Salidas.fromMap(Map<String, dynamic> map) {
    return Salidas(
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      salida_CodFolio: map['salida_CodFolio'] != null
          ? map['salida_CodFolio'] as String
          : null,
      salida_Referencia: map['salida_Referencia'] != null
          ? map['salida_Referencia'] as String
          : null,
      salida_Estado:
          map['salida_Estado'] != null ? map['salida_Estado'] as bool : null,
      salida_Unidades: map['salida_Unidades'] != null
          ? map['salida_Unidades'] as double
          : null,
      salida_Costo:
          map['salida_Costo'] != null ? map['salida_Costo'] as double : null,
      salida_Fecha:
          map['salida_Fecha'] != null ? map['salida_Fecha'] as String : null,
      salida_TipoTrabajo: map['salida_TipoTrabajo'] != null
          ? map['salida_TipoTrabajo'] as String
          : null,
      salida_Comentario: map['salida_Comentario'] != null
          ? map['salida_Comentario'] as String
          : null,
      salida_Imag64Orden: map['salida_Imag64Orden'] != null
          ? map['salida_Imag64Orden'] as String
          : null,
      salida_DocumentoFirmas: map['salida_DocumentoFirmas'] != null
          ? map['salida_DocumentoFirmas'] as String
          : null,
      salida_DocumentoPago: map['salida_DocumentoPago'] != null
          ? map['salida_DocumentoPago'] as String
          : null,
      salida_DocumentoFirma: map['salida_DocumentoFirma'] != null
          ? map['salida_DocumentoFirma'] as bool
          : null,
      salida_Pagado:
          map['salida_Pagado'] != null ? map['salida_Pagado'] as bool : null,
      idProducto: map['idProducto'] != null ? map['idProducto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
      id_User_Asignado: map['id_User_Asignado'] != null
          ? map['id_User_Asignado'] as int
          : null,
      idPadron: map['idPadron'] != null ? map['idPadron'] as int : null,
      idCalle: map['idCalle'] != null ? map['idCalle'] as int : null,
      idColonia: map['idColonia'] != null ? map['idColonia'] as int : null,
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
      idUserAutoriza:
          map['idUserAutoriza'] != null ? map['idUserAutoriza'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Salidas.fromJson(String source) =>
      Salidas.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Salidas(id_Salida: $id_Salida, salida_CodFolio: $salida_CodFolio, salida_Referencia: $salida_Referencia, salida_Estado: $salida_Estado, salida_Unidades: $salida_Unidades, salida_Costo: $salida_Costo, salida_Fecha: $salida_Fecha, salida_TipoTrabajo: $salida_TipoTrabajo, salida_Comentario: $salida_Comentario, salida_Imag64Orden: $salida_Imag64Orden, salida_DocumentoFirmas: $salida_DocumentoFirmas, salida_DocumentoPago: $salida_DocumentoPago, salida_DocumentoFirma: $salida_DocumentoFirma, salida_Pagado: $salida_Pagado, idProducto: $idProducto, id_User: $id_User, id_Junta: $id_Junta, id_Almacen: $id_Almacen, id_User_Asignado: $id_User_Asignado, idPadron: $idPadron, idCalle: $idCalle, idColonia: $idColonia, idOrdenServicio: $idOrdenServicio, idUserAutoriza: $idUserAutoriza)';
  }

  @override
  bool operator ==(covariant Salidas other) {
    if (identical(this, other)) return true;

    return other.id_Salida == id_Salida &&
        other.salida_CodFolio == salida_CodFolio &&
        other.salida_Referencia == salida_Referencia &&
        other.salida_Estado == salida_Estado &&
        other.salida_Unidades == salida_Unidades &&
        other.salida_Costo == salida_Costo &&
        other.salida_Fecha == salida_Fecha &&
        other.salida_TipoTrabajo == salida_TipoTrabajo &&
        other.salida_Comentario == salida_Comentario &&
        other.salida_Imag64Orden == salida_Imag64Orden &&
        other.salida_DocumentoFirmas == salida_DocumentoFirmas &&
        other.salida_DocumentoPago == salida_DocumentoPago &&
        other.salida_DocumentoFirma == salida_DocumentoFirma &&
        other.salida_Pagado == salida_Pagado &&
        other.idProducto == idProducto &&
        other.id_User == id_User &&
        other.id_Junta == id_Junta &&
        other.id_Almacen == id_Almacen &&
        other.id_User_Asignado == id_User_Asignado &&
        other.idPadron == idPadron &&
        other.idCalle == idCalle &&
        other.idColonia == idColonia &&
        other.idOrdenServicio == idOrdenServicio &&
        other.idUserAutoriza == idUserAutoriza;
  }

  @override
  int get hashCode {
    return id_Salida.hashCode ^
        salida_CodFolio.hashCode ^
        salida_Referencia.hashCode ^
        salida_Estado.hashCode ^
        salida_Unidades.hashCode ^
        salida_Costo.hashCode ^
        salida_Fecha.hashCode ^
        salida_TipoTrabajo.hashCode ^
        salida_Comentario.hashCode ^
        salida_Imag64Orden.hashCode ^
        salida_DocumentoFirmas.hashCode ^
        salida_DocumentoPago.hashCode ^
        salida_DocumentoFirma.hashCode ^
        salida_Pagado.hashCode ^
        idProducto.hashCode ^
        id_User.hashCode ^
        id_Junta.hashCode ^
        id_Almacen.hashCode ^
        id_User_Asignado.hashCode ^
        idPadron.hashCode ^
        idCalle.hashCode ^
        idColonia.hashCode ^
        idOrdenServicio.hashCode ^
        idUserAutoriza.hashCode;
  }
}

class SalidaLista {
  int? id_Salida;
  String? salida_CodFolio;
  String? salida_Referencia;
  bool? salida_Estado;
  double? salida_Unidades;
  double? salida_Costo;
  String? salida_Fecha;
  String? salida_TipoTrabajo;
  String? salida_Comentario;
  bool? salida_DocumentoFirma;
  bool? salida_Pagado;
  int? idProducto;
  int? id_User;
  int? id_Junta;
  int? id_Almacen;
  int? id_User_Asignado;
  int? idPadron;
  int? idCalle;
  int? idColonia;
  int? idOrdenServicio;
  int? idUserAutoriza;
  SalidaLista({
    this.id_Salida,
    this.salida_CodFolio,
    this.salida_Referencia,
    this.salida_Estado,
    this.salida_Unidades,
    this.salida_Costo,
    this.salida_Fecha,
    this.salida_TipoTrabajo,
    this.salida_Comentario,
    this.salida_DocumentoFirma,
    this.salida_Pagado,
    this.idProducto,
    this.id_User,
    this.id_Junta,
    this.id_Almacen,
    this.id_User_Asignado,
    this.idPadron,
    this.idCalle,
    this.idColonia,
    this.idOrdenServicio,
    this.idUserAutoriza,
  });

  SalidaLista copyWith({
    int? id_Salida,
    String? salida_CodFolio,
    String? salida_Referencia,
    bool? salida_Estado,
    double? salida_Unidades,
    double? salida_Costo,
    String? salida_Fecha,
    String? salida_TipoTrabajo,
    String? salida_Comentario,
    bool? salida_DocumentoFirma,
    bool? salida_Pagado,
    int? idProducto,
    int? id_User,
    int? id_Junta,
    int? id_Almacen,
    int? id_User_Asignado,
    int? idPadron,
    int? idCalle,
    int? idColonia,
    int? idOrdenServicio,
    int? idUserAutoriza,
  }) {
    return SalidaLista(
      id_Salida: id_Salida ?? this.id_Salida,
      salida_CodFolio: salida_CodFolio ?? this.salida_CodFolio,
      salida_Referencia: salida_Referencia ?? this.salida_Referencia,
      salida_Estado: salida_Estado ?? this.salida_Estado,
      salida_Unidades: salida_Unidades ?? this.salida_Unidades,
      salida_Costo: salida_Costo ?? this.salida_Costo,
      salida_Fecha: salida_Fecha ?? this.salida_Fecha,
      salida_TipoTrabajo: salida_TipoTrabajo ?? this.salida_TipoTrabajo,
      salida_Comentario: salida_Comentario ?? this.salida_Comentario,
      salida_DocumentoFirma:
          salida_DocumentoFirma ?? this.salida_DocumentoFirma,
      salida_Pagado: salida_Pagado ?? this.salida_Pagado,
      idProducto: idProducto ?? this.idProducto,
      id_User: id_User ?? this.id_User,
      id_Junta: id_Junta ?? this.id_Junta,
      id_Almacen: id_Almacen ?? this.id_Almacen,
      id_User_Asignado: id_User_Asignado ?? this.id_User_Asignado,
      idPadron: idPadron ?? this.idPadron,
      idCalle: idCalle ?? this.idCalle,
      idColonia: idColonia ?? this.idColonia,
      idOrdenServicio: idOrdenServicio ?? this.idOrdenServicio,
      idUserAutoriza: idUserAutoriza ?? this.idUserAutoriza,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Salida': id_Salida,
      'salida_CodFolio': salida_CodFolio,
      'salida_Referencia': salida_Referencia,
      'salida_Estado': salida_Estado,
      'salida_Unidades': salida_Unidades,
      'salida_Costo': salida_Costo,
      'salida_Fecha': salida_Fecha,
      'salida_TipoTrabajo': salida_TipoTrabajo,
      'salida_Comentario': salida_Comentario,
      'salida_DocumentoFirma': salida_DocumentoFirma,
      'salida_Pagado': salida_Pagado,
      'idProducto': idProducto,
      'id_User': id_User,
      'id_Junta': id_Junta,
      'id_Almacen': id_Almacen,
      'id_User_Asignado': id_User_Asignado,
      'idPadron': idPadron,
      'idCalle': idCalle,
      'idColonia': idColonia,
      'idOrdenServicio': idOrdenServicio,
      'idUserAutoriza': idUserAutoriza,
    };
  }

  factory SalidaLista.fromMap(Map<String, dynamic> map) {
    return SalidaLista(
      id_Salida: map['id_Salida'] != null ? map['id_Salida'] as int : null,
      salida_CodFolio: map['salida_CodFolio'] != null
          ? map['salida_CodFolio'] as String
          : null,
      salida_Referencia: map['salida_Referencia'] != null
          ? map['salida_Referencia'] as String
          : null,
      salida_Estado:
          map['salida_Estado'] != null ? map['salida_Estado'] as bool : null,
      salida_Unidades: map['salida_Unidades'] != null
          ? map['salida_Unidades'] as double
          : null,
      salida_Costo:
          map['salida_Costo'] != null ? map['salida_Costo'] as double : null,
      salida_Fecha:
          map['salida_Fecha'] != null ? map['salida_Fecha'] as String : null,
      salida_TipoTrabajo: map['salida_TipoTrabajo'] != null
          ? map['salida_TipoTrabajo'] as String
          : null,
      salida_Comentario: map['salida_Comentario'] != null
          ? map['salida_Comentario'] as String
          : null,
      salida_DocumentoFirma: map['salida_DocumentoFirma'] != null
          ? map['salida_DocumentoFirma'] as bool
          : null,
      salida_Pagado:
          map['salida_Pagado'] != null ? map['salida_Pagado'] as bool : null,
      idProducto: map['idProducto'] != null ? map['idProducto'] as int : null,
      id_User: map['id_User'] != null ? map['id_User'] as int : null,
      id_Junta: map['id_Junta'] != null ? map['id_Junta'] as int : null,
      id_Almacen: map['id_Almacen'] != null ? map['id_Almacen'] as int : null,
      id_User_Asignado: map['id_User_Asignado'] != null
          ? map['id_User_Asignado'] as int
          : null,
      idPadron: map['idPadron'] != null ? map['idPadron'] as int : null,
      idCalle: map['idCalle'] != null ? map['idCalle'] as int : null,
      idColonia: map['idColonia'] != null ? map['idColonia'] as int : null,
      idOrdenServicio:
          map['idOrdenServicio'] != null ? map['idOrdenServicio'] as int : null,
      idUserAutoriza:
          map['idUserAutoriza'] != null ? map['idUserAutoriza'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SalidaLista.fromJson(String source) =>
      SalidaLista.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SalidaLista(id_Salida: $id_Salida, salida_CodFolio: $salida_CodFolio, salida_Referencia: $salida_Referencia, salida_Estado: $salida_Estado, salida_Unidades: $salida_Unidades, salida_Costo: $salida_Costo, salida_Fecha: $salida_Fecha, salida_TipoTrabajo: $salida_TipoTrabajo, salida_Comentario: $salida_Comentario, salida_DocumentoFirma: $salida_DocumentoFirma, salida_Pagado: $salida_Pagado, idProducto: $idProducto, id_User: $id_User, id_Junta: $id_Junta, id_Almacen: $id_Almacen, id_User_Asignado: $id_User_Asignado, idPadron: $idPadron, idCalle: $idCalle, idColonia: $idColonia, idOrdenServicio: $idOrdenServicio, idUserAutoriza: $idUserAutoriza)';
  }

  @override
  bool operator ==(covariant SalidaLista other) {
    if (identical(this, other)) return true;

    return other.id_Salida == id_Salida &&
        other.salida_CodFolio == salida_CodFolio &&
        other.salida_Referencia == salida_Referencia &&
        other.salida_Estado == salida_Estado &&
        other.salida_Unidades == salida_Unidades &&
        other.salida_Costo == salida_Costo &&
        other.salida_Fecha == salida_Fecha &&
        other.salida_TipoTrabajo == salida_TipoTrabajo &&
        other.salida_Comentario == salida_Comentario &&
        other.salida_DocumentoFirma == salida_DocumentoFirma &&
        other.salida_Pagado == salida_Pagado &&
        other.idProducto == idProducto &&
        other.id_User == id_User &&
        other.id_Junta == id_Junta &&
        other.id_Almacen == id_Almacen &&
        other.id_User_Asignado == id_User_Asignado &&
        other.idPadron == idPadron &&
        other.idCalle == idCalle &&
        other.idColonia == idColonia &&
        other.idOrdenServicio == idOrdenServicio &&
        other.idUserAutoriza == idUserAutoriza;
  }

  @override
  int get hashCode {
    return id_Salida.hashCode ^
        salida_CodFolio.hashCode ^
        salida_Referencia.hashCode ^
        salida_Estado.hashCode ^
        salida_Unidades.hashCode ^
        salida_Costo.hashCode ^
        salida_Fecha.hashCode ^
        salida_TipoTrabajo.hashCode ^
        salida_Comentario.hashCode ^
        salida_DocumentoFirma.hashCode ^
        salida_Pagado.hashCode ^
        idProducto.hashCode ^
        id_User.hashCode ^
        id_Junta.hashCode ^
        id_Almacen.hashCode ^
        id_User_Asignado.hashCode ^
        idPadron.hashCode ^
        idCalle.hashCode ^
        idColonia.hashCode ^
        idOrdenServicio.hashCode ^
        idUserAutoriza.hashCode;
  }
}
