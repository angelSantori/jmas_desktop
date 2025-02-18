import 'dart:convert';
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
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

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
  required String movimiento,
  required String fecha,
  required String salidaCodFolio,
  required String referencia,
  required String entidad,
  required String junta,
  required String usuario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  //QR
  final qrBytes = await generateQrCode(salidaCodFolio);
  final qrImage = pw.MemoryImage(qrBytes);

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
        return pw.Stack(
          //Contenido principal
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reporte de $movimiento',
                    style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Text('Fecha: $fecha'),
                pw.Text('Folio: $salidaCodFolio'),
                pw.Text('Referencia: $referencia'),
                pw.Text('Entidad: $entidad'),
                pw.Text('Junta: $junta'),
                pw.Text('Realizado por: $usuario'),
                pw.SizedBox(height: 30),
                pw.Table.fromTextArray(
                  headers: [
                    'Clave',
                    'Descripción',
                    'Costo',
                    'Cantidad',
                    'Total'
                  ],
                  data: [
                    ...productos.map((producto) {
                      return [
                        producto['id'].toString(),
                        producto['descripcion'] ?? '',
                        '\$${producto['costo'].toString()}',
                        producto['cantidad'].toString(),
                        '\$${producto['precio'].toStringAsFixed(2)}',
                      ];
                    }).toList(),
                    [
                      '',
                      '',
                      '',
                      '',
                      '',
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                    ]
                  ],
                ),
              ],
            ),
            //QR
            pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 100,
                  height: 100,
                  child: pw.Image(qrImage),
                ))
          ],
        );
      },
    ),
  );

  try {
    // Generar nombre del archivo con la fecha actual
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'Salida_Reporte_${currentDate}_$currentTime.pdf';

    // Convertir el PDF en bytes
    final bytes = await pdf.save();

    // Crear un Blob para descargarlo en el navegador
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crear un link para descargar el archivo
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    // Liberar el objeto URL después de descargar
    html.Url.revokeObjectUrl(url);

    print('PDF Reporte salida descargado exitosamente.');
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar el PDF: $e');
  }
}

Future<Uint8List> generateQrCode(String data) async {
  final qrCode = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
  );
  final image = await qrCode.toImage(200);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

// Función para generar el archivo PDF
Future<void> generateAndPrintPdfEntrada({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String referencia,
  required String almacen,
  required String proveedor,
  required Uint8List factura,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  //Generar código QR
  final qrBytes = await generateQrCode(folio);
  final qrImage = pw.MemoryImage(qrBytes);

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
        return pw.Stack(
          children: [
            //Contenido principal
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reporte de $movimiento',
                    style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Text('Fecha: $fecha'),
                pw.Text('Folio: $folio'),
                pw.Text('Referencia: $referencia'),
                pw.Text('Almacen: $almacen'),
                pw.Text('Proveedor: $proveedor'),
                pw.Text('Realizado por: $userName'),
                pw.SizedBox(height: 30),
                pw.Table.fromTextArray(
                  headers: [
                    'Clave',
                    'Descripción',
                    'Costo',
                    'Cantidad',
                    'Total'
                  ],
                  data: [
                    ...productos.map((producto) {
                      return [
                        producto['id'].toString(),
                        producto['descripcion'] ?? '',
                        '\$${producto['costo'].toString()}',
                        producto['cantidad'].toString(),
                        '\$${producto['precio'].toStringAsFixed(2)}',
                      ];
                    }).toList(),
                    [
                      '',
                      '',
                      '',
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                    ]
                  ],
                ),
                pw.SizedBox(height: 30),
              ],
            ),
            //QR
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 100,
                height: 100,
                child: pw.Image(qrImage),
              ),
            ),
          ],
        );
      },
    ),
  );

  final image = pw.MemoryImage(factura);
  final imageWidth = 600.0;
  final imageHeight = 600.0;

  // Verificar si la imagen cabe en la página
  if (imageHeight > PdfPageFormat.a4.height - 100) {
    // 100 es un margen
    // Si la imagen es demasiado alta, dividirla en varias páginas
    int pages = (imageHeight / (PdfPageFormat.a4.height - 100)).ceil();
    for (int i = 0; i < pages; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                image,
                width: imageWidth,
                height: PdfPageFormat.a4.height -
                    100, // Ajustar a la altura de la página
              ),
            );
          },
        ),
      );
    }
  } else {
    // Si la imagen cabe en la página, agregarla normalmente
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              image,
              width: imageWidth,
              height: imageHeight,
            ),
          );
        },
      ),
    );
  }

  try {
    // Generar nombre del archivo con la fecha actual
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'Entrada_Reporte_${currentDate}_$currentTime.pdf';

    final bytes = await pdf.save();

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    // Liberar el objeto URL después de descargar
    html.Url.revokeObjectUrl(url);

    print('PDF Reporte entrada descargado exitosamente.');
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar el PDF: $e');
  }
}

//Tabla de productos
Widget buildProductosAgregados(
  List<Map<String, dynamic>> productosAgregados,
  void Function(int) eliminarProducto,
  void Function(int, double) actualizarCosto,
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
          2: FlexColumnWidth(1), //Precio
          3: FlexColumnWidth(1), //Cantidad
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

            TextEditingController costoController =
                TextEditingController(text: producto['costo'].toString());

            return TableRow(
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(
                    texto: producto['descripcion'] ?? 'Sin descripción'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: costoController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onSubmitted: (nuevoValor) {
                      double nuevoCosto =
                          double.tryParse(nuevoValor) ?? producto['costo'];
                      actualizarCosto(index, nuevoCosto);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    ),
                  ),
                ),
                TableCellText(texto: producto['cantidad'].toString()),
                TableCellText(texto: '\$${producto['precio'].toString()}'),
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
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          ])
        ],
      ),
    ],
  );
}

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

//Buscar producto
class BuscarProductoWidget extends StatefulWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final ProductosController productosController;
  final Productos? selectedProducto;
  final Function(Productos?) onProductoSeleccionado;
  final Function(String) onAdvertencia;

  const BuscarProductoWidget({
    Key? key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
  }) : super(key: key);

  @override
  State<BuscarProductoWidget> createState() => _BuscarProductoWidgetState();
}

class _BuscarProductoWidgetState extends State<BuscarProductoWidget> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  Uint8List? _decodeImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64Image);
    } catch (e) {
      print('Error al decodificar la imagen: $e');
      return null;
    }
  }

  Future<void> _buscarProducto() async {
    final id = widget.idProductoController.text;
    if (id.isNotEmpty) {
      widget
          .onProductoSeleccionado(null); // Limpiar el producto antes de buscar
      _isLoading.value = true; // Iniciar el estado de carga

      try {
        final producto =
            await widget.productosController.getProductoById(int.parse(id));
        if (producto != null) {
          widget.onProductoSeleccionado(producto);
        } else {
          widget.onAdvertencia('Producto con ID: $id, no encontrado');
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar el producto: $e');
      } finally {
        _isLoading.value = false; // Finalizar el estado de carga
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de producto.');
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
            controller: widget.idProductoController,
            prefixIcon: Icons.search,
            labelText: 'Id Producto',
          ),
        ),
        const SizedBox(width: 15),

        // Botón para buscar producto
        ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            return ElevatedButton(
              onPressed: isLoading ? null : _buscarProducto,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? Colors.grey
                    : Colors.blue.shade900, // Cambiar color si está cargando
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Buscar producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(width: 15),

        // Información del Producto
        if (widget.selectedProducto != null)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Información del Producto:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Descripción: ${widget.selectedProducto!.prodDescripcion ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Precio: \$${widget.selectedProducto!.prodPrecio?.toStringAsFixed(2) ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Existencia: ${widget.selectedProducto!.prodExistencia ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Imagen del producto
                Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey.shade200,
                      ),
                      child: widget.selectedProducto!.prodImgB64 != null &&
                              _decodeImage(
                                      widget.selectedProducto!.prodImgB64) !=
                                  null
                          ? Image.memory(
                              _decodeImage(
                                  widget.selectedProducto!.prodImgB64)!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/sinFoto.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
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
        const SizedBox(width: 10),

        // Campo para la cantidad
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: CustomTextFieldNumero(
                controller: widget.cantidadController,
                prefixIcon: Icons.numbers_outlined,
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
Future<bool> validarCamposAntesDeImprimir(
    {required BuildContext context,
    required List productosAgregados,
    required TextEditingController referenciaController,
    required var selectedAlmacen,
    required var selectedJunta,
    required var padron,
    required var selectedUser}) async {
  if (referenciaController.text.isEmpty) {
    showAdvertence(context, 'La referencia es obligatoria.');
    return false;
  }

  if (selectedAlmacen == null) {
    showAdvertence(context, 'Debe seleccionar un almacen.');
    return false;
  }

  if (selectedJunta == null) {
    showAdvertence(context, 'Debe seleccionar una junta.');
    return false;
  }

  if (selectedUser == null) {
    showAdvertence(context, 'Debe asignar un empleado.');
    return false;
  }

  if (padron.text.isEmpty) {
    showAdvertence(context, 'Padrón es obligatorio.');
    return false;
  }

  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  return true;
}

// Función para validar campos antes de imprimir
Future<bool> validarCamposAntesDeImprimirEntrada({
  required BuildContext context,
  required List productosAgregados,
  required String referencia,
  required var selectedAlmacen,
  required var proveedor,
  required Uint8List? factura,
}) async {
  if (referencia.isEmpty) {
    showAdvertence(context, 'Referencia es obligatoria.');
    return false;
  }

  if (selectedAlmacen == null) {
    showAdvertence(context, 'Debe seleccionar un almacen.');
    return false;
  }

  if (proveedor == null) {
    showAdvertence(context, 'Debe seleccionar un proveedor.');
    return false;
  }

  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  if (factura == null) {
    showAdvertence(context, 'Factura obligatoria.');
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
                    child: Text(entrada.idProducto.toString()),
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

//Parse data
DateTime? parseDate(String dateString) {
  try {
    final parts = dateString.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
  } catch (e) {
    print('Error al parsear fecha: $e');
  }
  return null;
}
