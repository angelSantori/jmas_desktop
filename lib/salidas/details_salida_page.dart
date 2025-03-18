import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';

class DetailsSalidaPage extends StatefulWidget {
  final List<Salidas> salidas;
  final Almacenes almacen;
  final Juntas junta;
  final Padron padron;
  final Users userAsignado;
  final String user;

  const DetailsSalidaPage({
    super.key,
    required this.salidas,
    required this.almacen,
    required this.junta,
    required this.user,
    required this.padron,
    required this.userAsignado,
  });

  @override
  State<DetailsSalidaPage> createState() => _DetailsSalidaPageState();
}

class _DetailsSalidaPageState extends State<DetailsSalidaPage> {
  final ProductosController _productosController = ProductosController();
  late Future<Map<int, Productos>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProductos();
  }

  Future<Map<int, Productos>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      return {for (var prod in productos) prod.id_Producto!: prod};
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> groupProductos = {};

    for (var salidas in widget.salidas) {
      groupProductos.update(
        salidas.idProducto!,
        (value) => {
          'cantidad': value['cantidad'] + salidas.salida_Unidades,
          'total': value['total'] + salidas.salida_Costo,
        },
        ifAbsent: () => {
          'cantidad': salidas.salida_Unidades,
          'total': salidas.salida_Costo,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de salida: ${widget.salidas.first.salida_CodFolio}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            elevation: 4,
            color: const Color.fromARGB(255, 201, 230, 242),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Referencia: ${widget.salidas.first.salida_Referencia}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Almacen: ${widget.almacen.almacen_Nombre}'),
                  Text('Junta: ${widget.junta.junta_Name}'),
                  Text('Padron: ${widget.padron.padronNombre}'),
                  Text('Realizado por: ${widget.user}'),
                  Text('Asignado a: ${widget.userAsignado.user_Name}'),
                  Text(
                      'Tipo trabajo: ${widget.salidas.first.salida_TipoTrabajo}'),
                  Text('Fecha: ${widget.salidas.first.salida_Fecha}'),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<Map<int, Productos>>(
                      future: _productosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: Colors.blue.shade900),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar productos: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final productosCache = snapshot.data ?? {};

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Id Producto')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Cantidad')),
                              DataColumn(label: Text('Precio unitario')),
                              DataColumn(label: Text('Total (\$)'))
                            ],
                            rows: groupProductos.entries.map((entry) {
                              int idProducto = entry.key;
                              double cantidad = entry.value['cantidad'];
                              double total = entry.value['total'];
                              String nombreProducto =
                                  productosCache[idProducto]?.prodDescripcion ??
                                      'Desconocido';

                              return DataRow(cells: [
                                DataCell(Text(idProducto.toString())),
                                DataCell(Text(nombreProducto)),
                                DataCell(Text(cantidad.toString())),
                                DataCell(Text(
                                    '\$${(total / cantidad).toStringAsFixed(2)}')),
                                DataCell(Text('\$${total.toStringAsFixed(2)}')),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
