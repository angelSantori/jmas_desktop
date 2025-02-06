import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/generales.dart';

void showEntradaDetailsDialog(
  BuildContext context,
  Entradas entrada,
  Map<int, Productos> productosCache,
  Map<int, Almacenes> almacenCache,
  Map<int, Users> userCache,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: SizedBox(
          width: 300,
          child: Text(
            entrada.entrada_CodFolio ?? 'Código no disponible',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInfoItem(
                  'Id Entrada', entrada.id_Entradas?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Unidades', entrada.entrada_Unidades?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Costo', '\$${entrada.entrada_Costo?.toString() ?? 'N/A'}'),
              buildInfoItem(
                  'Fecha', entrada.entrada_Fecha?.toString() ?? 'N/A'),
              buildInfoItem('Referencia',
                  entrada.entrada_Referencia?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Producto',
                  productosCache[entrada.idProducto!]?.prodDescripcion ??
                      'Producto no encontrado'),
              buildInfoItem(
                  'Almacen',
                  almacenCache[entrada.id_Almacen!]?.almacen_Nombre ??
                      'Almacen no encontrado'),
              buildInfoItem(
                  'Realizado por',
                  userCache[entrada.id_User!]?.user_Name ??
                      'Usuario no encontrado'),
              buildInfoItem(
                  'Estado', entrada.entrada_Estado! ? 'Aprovado' : 'Cancelado'),
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
