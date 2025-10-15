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
  void Function(int) eliminarProducto, {
  bool mostrarEliminar = true,
  String tipoOperacion = 'normal',
}) {
  if (productosAgregados.isEmpty) {
    return const Text(
      'No hay productos agregados.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  bool esPresupuesto = tipoOperacion.toLowerCase().contains('presupuesto');

  // Función para calcular el precio con IVA si es presupuesto
  double calcularPrecioConIVA(double costoBase, double cantidad) {
    if (esPresupuesto) {
      return (costoBase * 1.16) * cantidad; // Aplicar 16% de IVA
    }
    return costoBase * cantidad; // Precio normal sin IVA
  }

  // Función para calcular el precio sin IVA
  double calcularPrecioSinIVA(double costoBase, double cantidad) {
    return costoBase * cantidad;
  }

  // Definir columnas dinámicamente
  Map<int, TableColumnWidth> columnWidths = {
    0: FlexColumnWidth(1), // ID
    1: FlexColumnWidth(3), // Descripción
    2: FlexColumnWidth(0.5), // Costo
    3: FlexColumnWidth(0.5), // Cantidad
  };

  // Agregar columna de descuento si hay productos con descuento
  bool hayDescuentos = productosAgregados
      .any((producto) => producto['descuento_aplicado'] == true);

  if (hayDescuentos) {
    columnWidths[2] = FlexColumnWidth(0.7); // Costo con info de descuento
  }

  // Agregar columnas según si es presupuesto o no
  if (esPresupuesto) {
    columnWidths[4] = FlexColumnWidth(1); // Total sin IVA
    columnWidths[5] = FlexColumnWidth(1); // Total con IVA
  } else {
    columnWidths[4] = FlexColumnWidth(1); // Total
  }

  if (mostrarEliminar) {
    columnWidths[esPresupuesto ? 6 : 5] = FlexColumnWidth(1); // Eliminar
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Productos Agregados:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      if (esPresupuesto)
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            'IVA 16% incluido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              fontSize: 14,
            ),
          ),
        ),
      if (hayDescuentos)
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            '⚠️ Descuento del 60% aplicado a productos especiales',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
              fontSize: 14,
            ),
          ),
        ),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(),
        columnWidths: columnWidths,
        children: [
          // Fila de encabezados
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: [
              const TableHeaderCell(texto: 'Clave'),
              const TableHeaderCell(texto: 'Descripción'),
              const TableHeaderCell(texto: 'Costo'),
              const TableHeaderCell(texto: 'Cantidad'),
              // Columnas dinámicas según si es presupuesto
              if (esPresupuesto) const TableHeaderCell(texto: 'Total'),
              TableHeaderCell(
                texto: esPresupuesto ? 'Total con IVA' : 'Total',
              ),
              if (mostrarEliminar) const TableHeaderCell(texto: 'Eliminar'),
            ],
          ),
          // Filas de productos
          ...productosAgregados.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> producto = entry.value;

            double costoBase = producto['costo'] is double
                ? producto['costo']
                : double.tryParse(producto['costo'].toString()) ?? 0.0;
            double cantidad = producto['cantidad'] is double
                ? producto['cantidad']
                : double.tryParse(producto['cantidad'].toString()) ?? 0.0;

            double precioSinIVA = calcularPrecioSinIVA(costoBase, cantidad);
            double precioConIVA = calcularPrecioConIVA(costoBase, cantidad);

            bool tieneDescuento = producto['descuento_aplicado'] == true;

            return TableRow(
              decoration: tieneDescuento
                  ? BoxDecoration(color: Colors.orange.shade50)
                  : null,
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(
                    texto: producto['descripcion'] ?? 'Sin descripción'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '\$${costoBase.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                      ),
                      if (tieneDescuento)
                        Text(
                          '60% desc.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                TableCellText(texto: cantidad.toStringAsFixed(2)),
                // Mostrar total sin IVA solo si es presupuesto
                if (esPresupuesto)
                  TableCellText(
                    texto: '\$${precioSinIVA.toStringAsFixed(2)}',
                  ),
                // Mostrar total (con IVA si es presupuesto)
                TableCellText(
                  texto: '\$${precioConIVA.toStringAsFixed(2)}',
                ),
                if (mostrarEliminar)
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
          // Fila de totales
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
            // Total sin IVA (solo para presupuesto)
            if (esPresupuesto)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) {
                    double costoBase = producto['costo'] is double
                        ? producto['costo']
                        : double.tryParse(producto['costo'].toString()) ?? 0.0;
                    double cantidad = producto['cantidad'] is double
                        ? producto['cantidad']
                        : double.tryParse(producto['cantidad'].toString()) ??
                            0.0;
                    double precioProducto =
                        calcularPrecioSinIVA(costoBase, cantidad);
                    return previousValue + precioProducto;
                  }).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            // Total con IVA (o total normal)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) {
                  double costoBase = producto['costo'] is double
                      ? producto['costo']
                      : double.tryParse(producto['costo'].toString()) ?? 0.0;
                  double cantidad = producto['cantidad'] is double
                      ? producto['cantidad']
                      : double.tryParse(producto['cantidad'].toString()) ?? 0.0;
                  double precioProducto =
                      calcularPrecioConIVA(costoBase, cantidad);
                  return previousValue + precioProducto;
                }).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            if (mostrarEliminar)
              const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          ])
        ],
      ),
    ],
  );
}
