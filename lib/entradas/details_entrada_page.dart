import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';

class DetailsEntradaPage extends StatefulWidget {
  final List<Entradas> entradas;
  final Proveedores proveedor;
  final Almacenes almacen;
  final String user;

  const DetailsEntradaPage({
    super.key,
    required this.entradas,
    required this.proveedor,
    required this.almacen,
    required this.user,
  });

  @override
  State<DetailsEntradaPage> createState() => _DetailsEntradaPageState();
}

class _DetailsEntradaPageState extends State<DetailsEntradaPage> {
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
    final Map<int, Map<String, dynamic>> groupedProducts = {};

    for (var entrada in widget.entradas) {
      groupedProducts.update(
        entrada.idProducto!,
        (value) => {
          'cantidad': value['cantidad'] + entrada.entrada_Unidades,
          'total': value['total'] + entrada.entrada_Costo,
        },
        ifAbsent: () => {
          'cantidad': entrada.entrada_Unidades,
          'total': entrada.entrada_Costo,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de entrada: ${widget.entradas.first.entrada_CodFolio}',
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
                    'Referencia: ${widget.entradas.first.entrada_Referencia}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Proveedor: ${widget.proveedor.proveedor_Name}'),
                  Text('Almacén: ${widget.almacen.almacen_Nombre}'),
                  Text('Realizado por: ${widget.user}'),
                  Text('Fecha: ${widget.entradas.first.entrada_Fecha}'),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<Map<int, Productos>>(
                      future: _productosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                            border: TableBorder.all(),
                            columns: const [
                              DataColumn(label: Text('ID Producto')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Cantidad')),
                              DataColumn(label: Text('Precio unitario')),
                              DataColumn(label: Text('Total (\$)')),
                            ],
                            rows: groupedProducts.entries.map((entry) {
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
