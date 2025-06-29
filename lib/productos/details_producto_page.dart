import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/generales.dart';

void showProductDetailsDialog(
  BuildContext context,
  Productos producto,
  Map<int, Proveedores> proveedoresCache,
  List<Productos> allProductos,
) {
  //Buscar el invIniconteo del producto
  // ignore: unused_local_variable
  double? totalExistencias = allProductos
      .firstWhere(
        (captura) => captura.id_Producto == producto.id_Producto,
        orElse: () => Productos(prodExistencia: null),
      )
      .prodExistencia;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: SizedBox(
          width: 300,
          child: Text(
            producto.prodDescripcion!,
            maxLines: 2,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: 300, // Ajusta el ancho según sea necesario
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInfoItem('Clave', producto.id_Producto.toString()),
              //buildInfoItem('Existencias', esInvIniConteo?.toString() ?? 'No disponible'),
              buildInfoItem(
                  'Existencias actuales:', producto.prodExistencia.toString()),
              buildInfoItem('Existencias máximas', producto.prodMax.toString()),
              buildInfoItem('Existencias mínimas', producto.prodMin.toString()),
              buildInfoItem('Costo', '\$${producto.prodCosto}'),
              buildInfoItem(
                  'Ubicación física', producto.prodUbFisica ?? 'Sin ubicación'),
              buildInfoItem('Unidad de medida de entrada',
                  producto.prodUMedEntrada ?? 'N/A'),
              buildInfoItem('Unidad de medida de salida',
                  producto.prodUMedSalida ?? 'N/A'),
              buildInfoItem('Precio', '\$${producto.prodPrecio}'),
              buildInfoItem(
                  'Proveedor',
                  proveedoresCache[producto.idProveedor]?.proveedor_Name ??
                      'No disponible'),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: producto.prodImgB64 != null &&
                        producto.prodImgB64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(producto.prodImgB64!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/sinFoto.jpg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
