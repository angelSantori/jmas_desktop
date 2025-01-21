// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class ProductosController {
  final AuthService _authService = AuthService();

  //Agregar Producto
  Future<bool> addProducto(Productos prodcuto) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Productos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: prodcuto.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error al agregar producto: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al agregar producto: $e');
      return false;
    }
  }

  //Producto por ID
  Future<Productos?> getProductoById(int idProdcuto) async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Productos/$idProdcuto'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return Productos.fromMap(jsonData);
      } else if (response.statusCode == 404) {
        print('Producto no encontrado con ID: $idProdcuto');
        return null;
      } else {
        print(
            'Error al obtener producto por ID: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al obtener producto por ID: $e');
      return null;
    }
  }

  //Lista Productos
  Future<List<Productos>> listProductos() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiURL}/Productos'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((producto) => Productos.fromMap(producto)).toList();
      } else {
        print(
            'Error al obtener lista de productos: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error lista de productos: $e');
      return [];
    }
  }

  Future<bool> editProducto(Productos producto) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Productos/${producto.id_Producto}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: producto.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error al editar producto: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al editar producto: $e');
      return false;
    }
  }
}

class Productos {
  int? id_Producto;
  String? prodDescripcion;
  double? prodExistencia;
  double? prodMax;
  double? prodMin;
  double? prodCosto;
  String? prodUMedSalida;
  String? prodUMedEntrada;
  double? prodPrecio;
  String? prodImgB64;
  int? idProveedor;
  Productos({
    this.id_Producto,
    this.prodDescripcion,
    this.prodExistencia,
    this.prodMax,
    this.prodMin,
    this.prodCosto,
    this.prodUMedSalida,
    this.prodUMedEntrada,
    this.prodPrecio,
    this.prodImgB64,
    this.idProveedor,
  });

  Productos copyWith({
    int? id_Producto,
    String? prodDescripcion,
    double? prodExistencia,
    double? prodMax,
    double? prodMin,
    double? prodCosto,
    String? prodUMedSalida,
    String? prodUMedEntrada,
    double? prodPrecio,
    String? prodImgB64,
    int? idProveedor,
  }) {
    return Productos(
      id_Producto: id_Producto ?? this.id_Producto,
      prodDescripcion: prodDescripcion ?? this.prodDescripcion,
      prodExistencia: prodExistencia ?? this.prodExistencia,
      prodMax: prodMax ?? this.prodMax,
      prodMin: prodMin ?? this.prodMin,
      prodCosto: prodCosto ?? this.prodCosto,
      prodUMedSalida: prodUMedSalida ?? this.prodUMedSalida,
      prodUMedEntrada: prodUMedEntrada ?? this.prodUMedEntrada,
      prodPrecio: prodPrecio ?? this.prodPrecio,
      prodImgB64: prodImgB64 ?? this.prodImgB64,
      idProveedor: idProveedor ?? this.idProveedor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Producto': id_Producto,
      'prodDescripcion': prodDescripcion,
      'prodExistencia': prodExistencia,
      'prodMax': prodMax,
      'prodMin': prodMin,
      'prodCosto': prodCosto,
      'prodUMedSalida': prodUMedSalida,
      'prodUMedEntrada': prodUMedEntrada,
      'prodPrecio': prodPrecio,
      'prodImgB64': prodImgB64,
      'idProveedor': idProveedor,
    };
  }

  factory Productos.fromMap(Map<String, dynamic> map) {
    return Productos(
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      prodDescripcion: map['prodDescripcion'] != null
          ? map['prodDescripcion'] as String
          : null,
      prodExistencia: map['prodExistencia'] != null
          ? (map['prodExistencia'] is int
              ? (map['prodExistencia'] as int).toDouble()
              : map['prodExistencia'] as double)
          : null,
      prodMax: map['prodMax'] != null
          ? (map['prodMax'] is int
              ? (map['prodMax'] as int).toDouble()
              : map['prodMax'] as double)
          : null,
      prodMin: map['prodMin'] != null
          ? (map['prodMin'] is int
              ? (map['prodMin'] as int).toDouble()
              : map['prodMin'] as double)
          : null,
      prodCosto: map['prodCosto'] != null
          ? (map['prodCosto'] is int
              ? (map['prodCosto'] as int).toDouble()
              : map['prodCosto'] as double)
          : null,
      prodUMedSalida: map['prodUMedSalida'] != null
          ? map['prodUMedSalida'] as String
          : null,
      prodUMedEntrada: map['prodUMedEntrada'] != null
          ? map['prodUMedEntrada'] as String
          : null,
      prodPrecio: map['prodPrecio'] != null
          ? (map['prodPrecio'] is int
              ? (map['prodPrecio'] as int).toDouble()
              : map['prodPrecio'] as double)
          : null,
      prodImgB64:
          map['prodImgB64'] != null ? map['prodImgB64'] as String : null,
      idProveedor:
          map['idProveedor'] != null ? map['idProveedor'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Productos.fromJson(String source) =>
      Productos.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Productos(id_Producto: $id_Producto, prodDescripcion: $prodDescripcion, prodExistencia: $prodExistencia, prodMax: $prodMax, prodMin: $prodMin, prodCosto: $prodCosto, prodUMedSalida: $prodUMedSalida, prodUMedEntrada: $prodUMedEntrada, prodPrecio: $prodPrecio, prodImgB64: $prodImgB64, idProveedor: $idProveedor)';
  }

  @override
  bool operator ==(covariant Productos other) {
    if (identical(this, other)) return true;

    return other.id_Producto == id_Producto &&
        other.prodDescripcion == prodDescripcion &&
        other.prodExistencia == prodExistencia &&
        other.prodMax == prodMax &&
        other.prodMin == prodMin &&
        other.prodCosto == prodCosto &&
        other.prodUMedSalida == prodUMedSalida &&
        other.prodUMedEntrada == prodUMedEntrada &&
        other.prodPrecio == prodPrecio &&
        other.prodImgB64 == prodImgB64 &&
        other.idProveedor == idProveedor;
  }

  @override
  int get hashCode {
    return id_Producto.hashCode ^
        prodDescripcion.hashCode ^
        prodExistencia.hashCode ^
        prodMax.hashCode ^
        prodMin.hashCode ^
        prodCosto.hashCode ^
        prodUMedSalida.hashCode ^
        prodUMedEntrada.hashCode ^
        prodPrecio.hashCode ^
        prodImgB64.hashCode ^
        idProveedor.hashCode;
  }
}
