import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  final String texto;
  const TableHeaderCell({required this.texto, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        texto,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TableCellText extends StatelessWidget {
  final String texto;
  const TableCellText({required this.texto, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        texto,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

Widget buildProductosAgregadosSalidaX(
  List<Map<String, dynamic>> productosAgregados,
  void Function(int) eliminarProducto,
) {
  if (productosAgregados.isEmpty) {
    return const Text(
      'No hay productos agregados.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Productos Agregados:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1), //ID
          1: FlexColumnWidth(3), //Descripción
          2: FlexColumnWidth(0.5), //Costo
          3: FlexColumnWidth(0.5), //Cantidad
          4: FlexColumnWidth(1), //Precio Total
          5: FlexColumnWidth(1) //Eliminar
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              TableHeaderCell(texto: 'Clave'),
              TableHeaderCell(texto: 'Descripción'),
              TableHeaderCell(texto: 'Costo'),
              TableHeaderCell(texto: 'Cantidad'),
              TableHeaderCell(texto: 'Total'),
              TableHeaderCell(texto: 'Eliminar'),
            ],
          ),
          ...productosAgregados.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> producto = entry.value;

            return TableRow(
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(
                    texto: producto['descripcion'] ?? 'Sin descripción'),
                TableCellText(
                  texto: producto['costo'] is double
                      ? '\$${producto['costo'].toStringAsFixed(2)}'
                      : '\$${double.tryParse(producto['costo'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                ),
                TableCellText(texto: producto['cantidad'].toString()),
                TableCellText(
                    texto:
                        '\$${producto['precio'] is double ? producto['precio'].toStringAsFixed(2) : (double.tryParse(producto['precio'].toString())?.toStringAsFixed(2) ?? '0.00')}'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarProducto(index),
                  ),
                ),
              ],
            );
          }).toList(),
          TableRow(children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) {
                  double precio = producto['precio'] is double
                      ? producto['precio']
                      : double.tryParse(producto['precio'].toString()) ?? 0.0;
                  return previousValue + precio;
                }).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          ])
        ],
      ),
    ],
  );
}
