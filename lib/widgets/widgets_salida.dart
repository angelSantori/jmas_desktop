import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:ui' as ui;

//Tabla de productos salida
Widget buildProductosAgregadosSalida(
  List<Map<String, dynamic>> productosAgregados,
  void Function(int) eliminarProductoSalida,
  void Function(int, double) actualizarCostoSalida,
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
          2: FlexColumnWidth(1), //Costo
          3: FlexColumnWidth(1), //Cantidad
          4: FlexColumnWidth(1), //% Incremento
          5: FlexColumnWidth(1), //Precio incrementado
          6: FlexColumnWidth(1), //Precio total
          7: FlexColumnWidth(1), //Eliminar
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              TableHeaderCell(texto: 'Calve'),
              TableHeaderCell(texto: 'Descripción'),
              TableHeaderCell(texto: 'Costo'),
              TableHeaderCell(texto: 'Cantidad'),
              TableHeaderCell(texto: '% Incremento'),
              TableHeaderCell(texto: 'Precio Incrementado'),
              TableHeaderCell(texto: 'Precio Total'),
              TableHeaderCell(texto: 'Eliminar'),
            ],
          ),
          ...productosAgregados.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> producto = entry.value;

            TextEditingController costoSalidaController =
                TextEditingController(text: producto['costo'].toString());

            return TableRow(
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(texto: producto['descripcion'].toString()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: costoSalidaController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onSubmitted: (nuevoValor) {
                      double nuevoCosto =
                          double.tryParse(nuevoValor) ?? producto['costo'];
                      actualizarCostoSalida(index, nuevoCosto);
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      fillColor: Colors.blue.shade900,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                    ),
                  ),
                ),
                TableCellText(texto: producto['cantidad'].toString()),
                TableCellText(texto: producto['porcentaje'].toString() + '%'),
                TableCellText(
                    texto: '\$${producto['precioIncrementado'].toString()}'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '\$${((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0).toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarProductoSalida(index),
                  ),
                ),
              ],
            );
          }),
          TableRow(children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
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
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) => previousValue + ((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0)).toStringAsFixed(2)}',
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

//Buscar producto
class BuscarProductoWidgetSalida extends StatefulWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final ProductosController productosController;
  final Productos? selectedProducto;
  final Function(Productos?) onProductoSeleccionado;
  final Function(String) onAdvertencia;
  final ValueNotifier<double> selectedIncremento;

  BuscarProductoWidgetSalida({
    super.key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
    required this.selectedIncremento,
  });

  @override
  State<BuscarProductoWidgetSalida> createState() =>
      _BuscarProductoWidgetSalidaState();
}

class _BuscarProductoWidgetSalidaState
    extends State<BuscarProductoWidgetSalida> {
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
          child: CustomTextFieldNumero(
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
                      ValueListenableBuilder<double?>(
                        valueListenable: widget.selectedIncremento,
                        builder: (context, porcentaje, child) {
                          final double precioUnitario =
                              widget.selectedProducto!.prodPrecio ?? 0.0;
                          final double precioAjustado = precioUnitario +
                              (precioUnitario * (porcentaje! / 100));
                          return Text(
                            'Precio ajustad: \$${precioAjustado.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      DropdownButton<double>(
                        value: widget.selectedIncremento.value,
                        items: const [
                          DropdownMenuItem(value: 0.0, child: Text('0%')),
                          DropdownMenuItem(value: 5.0, child: Text('5%')),
                          DropdownMenuItem(value: 10.0, child: Text('10%'))
                        ],
                        onChanged: (value) {
                          setState(() {
                            widget.selectedIncremento.value = value!;
                          });
                        },
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

//Padron
class BuscarPadronWidgetSalida extends StatefulWidget {
  final TextEditingController idPadronController;
  final PadronController padronController;
  final Padron? selectedPadron;
  final Function(Padron?) onPadronSeleccionado;
  final Function(String) onAdvertencia;

  BuscarPadronWidgetSalida({
    super.key,
    required this.idPadronController,
    required this.padronController,
    required this.selectedPadron,
    required this.onPadronSeleccionado,
    required this.onAdvertencia,
  });

  @override
  State<BuscarPadronWidgetSalida> createState() =>
      _BuscarPadronWidgetSalidaState();
}

class _BuscarPadronWidgetSalidaState extends State<BuscarPadronWidgetSalida> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  Future<void> _buscarPadron() async {
    final id = widget.idPadronController.text;
    if (id.isNotEmpty) {
      widget.onPadronSeleccionado(null); // Limpiar el padrón antes de buscar
      _isLoading.value = true; // Iniciar el estado de carga

      try {
        final padronList = await widget.padronController.listPadron();
        final foundPadron = padronList.firstWhere(
            (p) => p.idPadron.toString() == id,
            orElse: () =>
                Padron()); // Devuelve un Padron vacío si no se encuentra
        if (foundPadron.idPadron != null) {
          widget.onPadronSeleccionado(foundPadron);
        } else {
          widget.onAdvertencia('Padrón con ID: $id, no encontrado');
          widget.idPadronController.clear();
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar el padrón: $e');
      } finally {
        _isLoading.value = false; // Finalizar el estado de carga
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de padrón.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Campo para ID del Padrón
        SizedBox(
          width: 160,
          child: CustomTextFieldNumero(
            controller: widget.idPadronController,
            prefixIcon: Icons.search,
            labelText: 'Id Padrón',
          ),
        ),
        const SizedBox(width: 15),

        // Botón para buscar padrón
        ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            return ElevatedButton(
              onPressed: isLoading ? null : _buscarPadron,
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
                      'Buscar padrón',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(width: 15),

        // Información del Padrón
        if (widget.selectedPadron != null &&
            widget.selectedPadron!.idPadron != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información del Padrón:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Nombre: ${widget.selectedPadron!.padronNombre ?? 'No disponible'}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Dirección: ${widget.selectedPadron!.padronDireccion ?? 'No disponible'}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        else
          const Expanded(
            flex: 2,
            child: Text(
              'No se ha buscado un padrón.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

//PDF
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

Future<void> generateAndPrintPdfSalida({
  required String movimiento,
  required String fecha,
  required String salidaCodFolio,
  required String referencia,
  required String almacen,
  required String junta,
  required String usuario,
  required String userAsignado,
  required int padron,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  //QR
  final qrBytes = await generateQrCode(salidaCodFolio);
  final qrImage = pw.MemoryImage(qrBytes);

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) =>
        sum + ((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0),
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
                pw.Text('Realizado por: $usuario'),
                pw.Text('Referencia: $referencia'),
                pw.Text('Almacen: $almacen'),
                pw.Text('Junta: $junta'),
                pw.Text('Asignado a: $userAsignado'),
                pw.Text('ID padron: $padron'),
                pw.SizedBox(height: 30),
                pw.Table.fromTextArray(headers: [
                  'Clave',
                  'Descripción',
                  'Costo',
                  'Cantidad',
                  '% Incremento',
                  'Precio Incrementado',
                  'Precio Total'
                ], data: [
                  ...productos.map((producto) {
                    return [
                      producto['id'].toString(),
                      producto['descripcion'] ?? '',
                      '\$${producto['costo'].toString()}',
                      producto['cantidad'].toString(),
                      '${producto['porcentaje'].toString()}%',
                      '\$${producto['precioIncrementado'].toString()}',
                      '\$${(producto['precioIncrementado'] * producto['cantidad']).toStringAsFixed(2)}',
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
                ]),
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
