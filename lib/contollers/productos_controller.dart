// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:jmas_desktop/service/auth_service.dart';

class ProductosController {
  final AuthService _authService = AuthService();

  // Crear un IOClient que permita certificados no seguros
  IOClient _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  //Agregar Producto
  Future<bool> addProducto(Productos prodcuto) async {
    final IOClient client = _createHttpClient();
    try {
      final response = await client.post(
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
    final IOClient client = _createHttpClient();

    try {
      final response = await client.get(
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
      final IOClient client = _createHttpClient();
      final response = await client.get(
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
    final IOClient client = _createHttpClient();
    try {
      final response = await client.put(
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
  String? producto_Descripcion;
  double? producto_Costo;
  String? producto_UMedida;
  double? producto_Precio1;
  double? producto_Precio2;
  double? producto_Precio3;
  double? producto_Existencia;
  double? producto_ExistenciaInicial;
  double? producto_ExistenciaConFis;
  String? producto_QR64;
  String? producto_ImgBase64;
  Productos({
    this.id_Producto,
    this.producto_Descripcion,
    this.producto_Costo,
    this.producto_UMedida,
    this.producto_Precio1,
    this.producto_Precio2,
    this.producto_Precio3,
    this.producto_Existencia,
    this.producto_ExistenciaInicial,
    this.producto_ExistenciaConFis,
    this.producto_QR64,
    this.producto_ImgBase64,
  });

  Productos copyWith({
    int? id_Producto,
    String? producto_Descripcion,
    double? producto_Costo,
    String? producto_UMedida,
    double? producto_Precio1,
    double? producto_Precio2,
    double? producto_Precio3,
    double? producto_Existencia,
    double? producto_ExistenciaInicial,
    double? producto_ExistenciaConFis,
    String? producto_QR64,
    String? producto_ImgBase64,
  }) {
    return Productos(
      id_Producto: id_Producto ?? this.id_Producto,
      producto_Descripcion: producto_Descripcion ?? this.producto_Descripcion,
      producto_Costo: producto_Costo ?? this.producto_Costo,
      producto_UMedida: producto_UMedida ?? this.producto_UMedida,
      producto_Precio1: producto_Precio1 ?? this.producto_Precio1,
      producto_Precio2: producto_Precio2 ?? this.producto_Precio2,
      producto_Precio3: producto_Precio3 ?? this.producto_Precio3,
      producto_Existencia: producto_Existencia ?? this.producto_Existencia,
      producto_ExistenciaInicial:
          producto_ExistenciaInicial ?? this.producto_ExistenciaInicial,
      producto_ExistenciaConFis:
          producto_ExistenciaConFis ?? this.producto_ExistenciaConFis,
      producto_QR64: producto_QR64 ?? this.producto_QR64,
      producto_ImgBase64: producto_ImgBase64 ?? this.producto_ImgBase64,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_Producto': id_Producto,
      'producto_Descripcion': producto_Descripcion,
      'producto_Costo': producto_Costo,
      'producto_UMedida': producto_UMedida,
      'producto_Precio1': producto_Precio1,
      'producto_Precio2': producto_Precio2,
      'producto_Precio3': producto_Precio3,
      'producto_Existencia': producto_Existencia,
      'producto_ExistenciaInicial': producto_ExistenciaInicial,
      'producto_ExistenciaConFis': producto_ExistenciaConFis,
      'producto_QR64': producto_QR64,
      'producto_ImgBase64': producto_ImgBase64,
    };
  }

  factory Productos.fromMap(Map<String, dynamic> map) {
    return Productos(
      id_Producto:
          map['id_Producto'] != null ? map['id_Producto'] as int : null,
      producto_Descripcion: map['producto_Descripcion'] != null
          ? map['producto_Descripcion'] as String
          : null,
      producto_Costo: map['producto_Costo'] != null
          ? (map['producto_Costo'] is int
              ? (map['producto_Costo'] as int).toDouble()
              : map['producto_Costo'] as double)
          : null,
      producto_UMedida: map['producto_UMedida'] != null
          ? map['producto_UMedida'] as String
          : null,
      producto_Precio1: map['producto_Precio1'] != null
          ? (map['producto_Precio1'] is int
              ? (map['producto_Precio1'] as int).toDouble()
              : map['producto_Precio1'] as double)
          : null,
      producto_Precio2: map['producto_Precio2'] != null
          ? (map['producto_Precio2'] is int
              ? (map['producto_Precio2'] as int).toDouble()
              : map['producto_Precio2'] as double)
          : null,
      producto_Precio3: map['producto_Precio3'] != null
          ? (map['producto_Precio3'] is int
              ? (map['producto_Precio3'] as int).toDouble()
              : map['producto_Precio3'] as double)
          : null,
      producto_Existencia: map['producto_Existencia'] != null
          ? (map['producto_Existencia'] is int
              ? (map['producto_Existencia'] as int).toDouble()
              : map['producto_Existencia'] as double)
          : null,
      producto_ExistenciaInicial: map['producto_ExistenciaInicial'] != null
          ? (map['producto_ExistenciaInicial'] is int
              ? (map['producto_ExistenciaInicial'] as int).toDouble()
              : map['producto_ExistenciaInicial'] as double)
          : null,
      producto_ExistenciaConFis: map['producto_ExistenciaConFis'] != null
          ? (map['producto_ExistenciaConFis'] is int
              ? (map['producto_ExistenciaConFis'] as int).toDouble()
              : map['producto_ExistenciaConFis'] as double)
          : null,
      producto_QR64:
          map['producto_QR64'] != null ? map['producto_QR64'] as String : null,
      producto_ImgBase64: map['producto_ImgBase64'] != null
          ? map['producto_ImgBase64'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Productos.fromJson(String source) =>
      Productos.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Productos(id_Producto: $id_Producto, producto_Descripcion: $producto_Descripcion, producto_Costo: $producto_Costo, producto_UMedida: $producto_UMedida, producto_Precio1: $producto_Precio1, producto_Precio2: $producto_Precio2, producto_Precio3: $producto_Precio3, producto_Existencia: $producto_Existencia, producto_ExistenciaInicial: $producto_ExistenciaInicial, producto_ExistenciaConFis: $producto_ExistenciaConFis, producto_QR64: $producto_QR64, producto_ImgBase64: $producto_ImgBase64)';
  }

  @override
  bool operator ==(covariant Productos other) {
    if (identical(this, other)) return true;

    return other.id_Producto == id_Producto &&
        other.producto_Descripcion == producto_Descripcion &&
        other.producto_Costo == producto_Costo &&
        other.producto_UMedida == producto_UMedida &&
        other.producto_Precio1 == producto_Precio1 &&
        other.producto_Precio2 == producto_Precio2 &&
        other.producto_Precio3 == producto_Precio3 &&
        other.producto_Existencia == producto_Existencia &&
        other.producto_ExistenciaInicial == producto_ExistenciaInicial &&
        other.producto_ExistenciaConFis == producto_ExistenciaConFis &&
        other.producto_QR64 == producto_QR64 &&
        other.producto_ImgBase64 == producto_ImgBase64;
  }

  @override
  int get hashCode {
    return id_Producto.hashCode ^
        producto_Descripcion.hashCode ^
        producto_Costo.hashCode ^
        producto_UMedida.hashCode ^
        producto_Precio1.hashCode ^
        producto_Precio2.hashCode ^
        producto_Precio3.hashCode ^
        producto_Existencia.hashCode ^
        producto_ExistenciaInicial.hashCode ^
        producto_ExistenciaConFis.hashCode ^
        producto_QR64.hashCode ^
        producto_ImgBase64.hashCode;
  }
}
