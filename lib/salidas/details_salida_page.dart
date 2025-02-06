import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/generales.dart';

void showSalidaDetailsDialog(
  BuildContext context,
  Salidas salida,
  Map<int, Productos> productosCache,
  Map<int, Users> usersCache,
  Map<int, Users> userAsignadoCache,
  Map<int, Juntas> juntaCache,
  Map<int, Almacenes> almacenCache,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: SizedBox(
          width: 300,
          child: Text(
            salida.salida_CodFolio ?? 'Folio no disponible',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInfoItem('Id Salida', salida.id_Salida?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Referencia', salida.salida_Referencia?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Unidades', salida.salida_Unidades?.toString() ?? 'N/A'),
              buildInfoItem(
                  'Costo', '\$${salida.salida_Costo?.toString() ?? 'N/A'}'),
              buildInfoItem('Fecha', salida.salida_Fecha?.toString() ?? 'N/A'),
              buildInfoItem(
                'Producto',
                salida.idProducto != null
                    ? productosCache[salida.idProducto]?.prodDescripcion ??
                        'Producto no encontrado'
                    : 'Producto no disponible',
              ),
              buildInfoItem(
                'Realizado por',
                salida.id_User != null
                    ? usersCache[salida.id_User]?.user_Name ??
                        'Usuario no encontrado'
                    : 'Usuario no disponible',
              ),
              buildInfoItem(
                'Junta',
                salida.id_Junta != null
                    ? juntaCache[salida.id_Junta]?.junta_Name ??
                        'Junta no encontrada'
                    : 'Junta no disponible',
              ),
              buildInfoItem(
                'Almacen',
                salida.id_Almacen != null
                    ? almacenCache[salida.id_Almacen]?.almacen_Nombre ??
                        'Almacen no encontrado'
                    : 'Almacen no disponible',
              ),
              buildInfoItem(
                'Asignado a',
                salida.id_User_Asignado != null
                    ? usersCache[salida.id_User_Asignado]?.user_Name ??
                        'Usuario no encontrado'
                    : 'Usuario no disponible: ${salida.id_User_Asignado}',
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
