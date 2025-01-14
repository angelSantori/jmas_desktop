import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

//ListTitle
class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

//ExpansionTitle
class CustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: children,
      ),
    );
  }
}

//SubExpansionTitle
class SubCustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SubCustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: children,
        ),
      ),
    );
  }
}

// Función para generar el archivo PDF
Future<void> generateAndPrintPdf({
  required BuildContext context,
  required String movimiento,
  required String fecha,
  required String referencia,
  required String proveedor,
  required String entidad,
  required String junta,
  required String usuario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
  );

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de $movimiento',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Fecha: $fecha'),
            pw.Text('Referencia: $referencia'),
            pw.Text('Proveedor: $proveedor'),
            pw.Text('Entidad: $entidad'),
            pw.Text('Junta: $junta'),
            pw.Text('Usuario: $usuario'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Clave', 'Descripción', 'Costo', 'Cantidad', 'Total'],
              data: productos.map((producto) {
                return [
                  producto['id'].toString(),
                  producto['descripcion'] ?? '',
                  '\$${producto['costo'].toString()}',
                  producto['cantidad'].toString(),
                  '\$${producto['precio'].toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        );
      },
    ),
  );

  try {
    // Permitir al usuario seleccionar la carpeta
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // El usuario canceló la selección
      return;
    }

    // Generar nombre del archivo con la fecha actual
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'entrada_reporte_${currentDate}_$currentTime.pdf';

    // Construir la ruta completa del archivo
    final String filePath = '$selectedDirectory/$fileName';

    // Guardar el archivo PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // ignore: avoid_print
    print('PDF guardado en: $filePath');

    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar el PDF: $e');
  }
}

// Función para generar el archivo PDF
Future<void> generateAndPrintPdfEntrada({
  required BuildContext context,
  required String movimiento,
  required String fecha,
  required String referencia,
  required String proveedor,
  required String usuario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
  );

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de $movimiento',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Fecha: $fecha'),
            pw.Text('Referencia: $referencia'),
            pw.Text('Proveedor: $proveedor'),
            pw.Text('Usuario: $usuario'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Clave', 'Descripción', 'Costo', 'Cantidad', 'Total'],
              data: productos.map((producto) {
                return [
                  producto['id'].toString(),
                  producto['descripcion'] ?? '',
                  '\$${producto['costo'].toString()}',
                  producto['cantidad'].toString(),
                  '\$${producto['precio'].toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        );
      },
    ),
  );

  try {
    // Permitir al usuario seleccionar la carpeta
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // El usuario canceló la selección
      return;
    }

    // Generar nombre del archivo con la fecha actual
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'entrada_reporte_${currentDate}_$currentTime.pdf';

    // Construir la ruta completa del archivo
    final String filePath = '$selectedDirectory/$fileName';

    // Guardar el archivo PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // ignore: avoid_print
    print('PDF guardado en: $filePath');

    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar el PDF: $e');
  }
}

//Tabla de productos
Widget buildProductosAgregados(List<Map<String, dynamic>> productosAgregados) {
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
          2: FlexColumnWidth(1), //Precio
          3: FlexColumnWidth(1), //Cantidad
          4: FlexColumnWidth(1), //Precio Total
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Clave',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Descripción',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Costo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Cantidad',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Precio',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ...productosAgregados.map((producto) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['id'].toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['descripcion'] ?? 'Sin descripción'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$${producto['costo'].toString()}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['cantidad'].toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$${producto['precio'].toStringAsFixed(2)}'),
                ),
              ],
            );
          }),
          TableRow(children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) => previousValue + (producto['precio'] ?? 0.0)).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ])
        ],
      ),
    ],
  );
}

//Buscar producto
class BuscarProductoWidget extends StatelessWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final ProductosController productosController;
  final bool isLoading;
  final Productos? selectedProducto;
  final Function(Productos?) onProductoSeleccionado;
  final Function(String) onAdvertencia;

  const BuscarProductoWidget({
    Key? key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.isLoading,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
  }) : super(key: key);

  Uint8List? _decodeImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64Image);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Campo para ID del Producto
        SizedBox(
          width: 160,
          child: CustomTextFielTexto(
            controller: idProductoController,
            labelText: 'Id Producto',
          ),
        ),
        const SizedBox(width: 15),

        // Botón para buscar producto
        ElevatedButton(
          onPressed: () async {
            final id = idProductoController.text;
            if (id.isNotEmpty) {
              onProductoSeleccionado(
                  null); // Limpiar el producto antes de buscar
              final producto =
                  await productosController.getProductoById(int.parse(id));
              if (producto != null) {
                onProductoSeleccionado(producto);
              } else {
                onAdvertencia('Producto con ID: $id, no encontrado');
              }
            } else {
              onAdvertencia('Por favor, ingrese un ID de producto.');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
          ),
          child: const Text(
            'Buscar producto',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),

        // Información del Producto
        if (isLoading)
          const CircularProgressIndicator()
        else if (selectedProducto != null)
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Producto:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Descripción: ${selectedProducto!.producto_Descripcion ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Precio: \$${selectedProducto!.producto_Precio1?.toStringAsFixed(2) ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Existencia: ${selectedProducto!.producto_Existencia ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),

                //Imagen del producto
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey.shade200,
                  ),
                  child: selectedProducto!.producto_ImgBase64 != null
                      ? Image.memory(
                          _decodeImage(selectedProducto!.producto_ImgBase64)!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/sinFoto.jpg',
                          fit: BoxFit.cover,
                        ),
                )
              ],
            ),
          )
        else
          const Expanded(
            flex: 2,
            child: Text(
              'No se ha buscado un producto.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        const SizedBox(width: 50),

        // Campo para la cantidad
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: CustomTextFielTexto(
                controller: cantidadController,
                labelText: 'Cantidad',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Función para validar campos antes de imprimir
Future<bool> validarCamposAntesDeImprimir({
  required BuildContext context,
  required List productosAgregados,
  required TextEditingController referenciaController,
  required var selectedProveedor,
  required var selectedEntidad,
  required var selectedJunta,
  required var selectedUser,
}) async {
  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  if (referenciaController.text.isEmpty) {
    showAdvertence(context, 'La referencia es obligatoria.');
    return false;
  }

  if (selectedProveedor == null) {
    showAdvertence(context, 'Debe seleccionar un proveedor.');
    return false;
  }

  if (selectedEntidad == null) {
    showAdvertence(context, 'Debe seleccionar una entidad.');
    return false;
  }

  if (selectedJunta == null) {
    showAdvertence(context, 'Debe seleccionar una junta.');
    return false;
  }

  if (selectedUser == null) {
    showAdvertence(context, 'Debe seleccionar un usuario.');
    return false;
  }

  return true; // Si pasa todas las validaciones, los datos están completos
}

// Función para validar campos antes de imprimir
Future<bool> validarCamposAntesDeImprimirEntrada({
  required BuildContext context,
  required List productosAgregados,
  required TextEditingController referenciaController,
  required var selectedProveedor,
  required var selectedUser,
}) async {
  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  if (referenciaController.text.isEmpty) {
    showAdvertence(context, 'La referencia es obligatoria.');
    return false;
  }

  if (selectedProveedor == null) {
    showAdvertence(context, 'Debe seleccionar un proveedor.');
    return false;
  }

  if (selectedUser == null) {
    showAdvertence(context, 'Debe seleccionar un usuario.');
    return false;
  }

  return true; // Si pasa todas las validaciones, los datos están completos
}

Widget buildReferenciaBuscadaEntrada(List<Entradas> entradas) {
  if (entradas.isEmpty) {
    return const Text(
      'No se encontro Folio en Entradas.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Folio de Entrada',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1), // ID Producto
          1: FlexColumnWidth(1), // Unidades
          2: FlexColumnWidth(1), // Costo
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'ID Producto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Unidades',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Costo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Solo agregar filas si hay productos
          if (entradas.isNotEmpty)
            ...entradas.map((entrada) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entrada.id_Producto.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entrada.entrada_Unidades.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text('\$${entrada.entrada_Costo!.toStringAsFixed(2)}'),
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    ],
  );
}

Widget buildReferenciaBuscadaSalida(List<Salidas> salidas) {
  if (salidas.isEmpty) {
    return const Text(
      'No se encontro Folio en Salidas.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Folio de Salida',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1), // ID Producto
          1: FlexColumnWidth(1), // Unidades
          2: FlexColumnWidth(1), // Costo
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Clave de Producto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Unidades',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Costo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Solo agregar filas si hay productos
          if (salidas.isNotEmpty)
            ...salidas.map((salida) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(salida.id_Salida.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(salida.salida_Unidades.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\$${salida.salida_Costo!.toStringAsFixed(2)}'),
                  ),
                ],
              );
            }).toList(),
        ],
      ),
    ],
  );
}
