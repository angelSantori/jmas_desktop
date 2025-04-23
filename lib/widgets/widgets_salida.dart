import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
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
  final CapturainviniController capturainviniController;
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
    required this.capturainviniController,
  });

  @override
  State<BuscarProductoWidgetSalida> createState() =>
      _BuscarProductoWidgetSalidaState();
}

class _BuscarProductoWidgetSalidaState
    extends State<BuscarProductoWidgetSalida> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  double? _invIniConteo;

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
          // Buscar el valor de invIniConteo para el producto
          final capturaList =
              await widget.capturainviniController.listCapturaI();
          final captura = capturaList.firstWhere(
            (captura) => captura.id_Producto == producto.id_Producto,
            orElse: () => Capturainvini(invIniConteo: null),
          );

          setState(() {
            _invIniConteo = captura.invIniConteo; // Almacenar el valor
          });
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
                        'Existencia: ${_invIniConteo ?? 'No disponible'}',
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
  required String usuario,
  required String idUser,
  required Almacenes almacenA,
  required Users userAsignado,
  required String tipoTabajo,
  required Padron padron,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Generar código QR
  final qrBytes = await generateQrCode(salidaCodFolio);
  final qrImage = pw.MemoryImage(qrBytes);

  // Cargar imagen del logo desde assets
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo_jmas_sf.png'))
        .buffer
        .asUint8List(),
  );

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) =>
        sum + ((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0),
  );

  // Convertir total a letra con centavos
  final partes = total.toStringAsFixed(2).split('.');
  final entero = int.parse(partes[0]);
  final centavos = partes[1];
  final totalEnLetras =
      '${_convertirNumeroALetras(entero)} PESOS $centavos/100 M.N.';

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      // Márgenes estrechos (1.27 cm = 36 puntos)
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 36,
        marginRight: 36,
        marginTop: 36,
        marginBottom: 36,
      ),
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            // Contenido principal
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado con logo y datos de la organización
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo a la izquierda
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.Image(logoImage),
                      margin: pw.EdgeInsets.only(right: 15),
                    ),
                    // Información de la organización centrada
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            'JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'CALLE ZARAGOZA No. 117, Colonia. CENTRO',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'MEOQUI, CHIHUAHUA, MEXICO.',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Espacio para el QR
                    pw.SizedBox(width: 70),
                  ],
                ),

                // Título del movimiento
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 15, bottom: 15),
                  child: pw.Text(
                    'MOVIMIENTO DE INVENTARIOS: $movimiento',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Información de variables en 3 columnas
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Columna izquierda
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Mov: $salidaCodFolio',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Ref: $referencia',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('TT: $tipoTabajo',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),

                      // Columna central
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text('Fec: $fecha',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Capturó: $idUser - $usuario',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'Padron: ${padron.idPadron} - ${padron.padronNombre}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),

                      // Columna derecha
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Junta: Meoqui',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'Almacen: ${almacenA.id_Almacen} - ${almacenA.almacen_Nombre}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'UserAsignado: ${userAsignado.id_User} - ${userAsignado.user_Name}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabla de productos con estructura similar a entradas
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(50), // Clave
                    1: const pw.FixedColumnWidth(50), // Cantidad
                    2: const pw.FlexColumnWidth(3), // Descripción
                    3: const pw.FixedColumnWidth(50), // Costo/Uni
                    4: const pw.FixedColumnWidth(50), // % Incrementado
                    5: const pw.FixedColumnWidth(50), // \$ Incrementado
                    6: const pw.FixedColumnWidth(60), // Total
                  },
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    // Encabezados de tabla con fondo negro y texto blanco
                    pw.TableRow(
                      children: [
                        _buildHeaderCell('Clave'),
                        _buildHeaderCell('Cantidad'),
                        _buildHeaderCell('Descripción'),
                        _buildHeaderCell('Costo/Uni'),
                        _buildHeaderCell('% Incr'),
                        _buildHeaderCell('\$ Incr'),
                        _buildHeaderCell('Total'),
                      ],
                    ),
                    // Filas de productos
                    ...productos
                        .map((producto) => pw.TableRow(
                              children: [
                                _buildDataCell(producto['id'].toString()),
                                _buildDataCell(producto['cantidad'].toString()),
                                _buildDataCell(
                                    producto['descripcion'].toString()),
                                _buildDataCell(
                                    '\$${producto['costo'].toString()}'),
                                _buildDataCell(
                                    '${producto['porcentaje'].toString()}%'),
                                _buildDataCell(
                                    '\$${producto['precioIncrementado'].toString()}'),
                                _buildDataCell(
                                    '\$${(producto['precioIncrementado'] * producto['cantidad'])}'
                                        .toString()),
                              ],
                            ))
                        // ignore: unnecessary_to_list_in_spreads
                        .toList(),
                    // Fila de total con celdas fusionadas
                    pw.TableRow(
                      children: [
                        // Celda de clave vacía
                        pw.Container(),
                        // Celda de cantidad vacía
                        pw.Container(),
                        // Celda de descripción vacía
                        pw.Expanded(
                          flex: 5, // Ocupa el espacio de 5 columnas
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('SON: $totalEnLetras',
                                style: const pw.TextStyle(fontSize: 8)),
                          ),
                        ),
                        // Celda de costo vacía
                        pw.Container(),
                        // Celda de % incrementado vacía
                        pw.Container(),
                        // Celda expandida que simula la fusión
                        pw.Container(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.black),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Total',
                              textAlign: pw.TextAlign.end,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                  color: PdfColors.white)),
                        ),
                        // Celda con valor total
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('\$${total.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),
              ],
            ),

            // QR en la esquina superior derecha
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 70,
                height: 70,
                child: pw.Image(qrImage),
              ),
            ),

            // Sección de firma al pie de página
            pw.Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      //Fimra de Entrga
                      pw.Column(children: [
                        pw.Container(
                          width: 120,
                          height: 1,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text('Entrega',
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                      //Fimra de Autoriza
                      pw.Column(children: [
                        pw.Container(
                          width: 120,
                          height: 1,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text('Autoriza',
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                      //Fimra de Recibe
                      pw.Column(children: [
                        pw.Container(
                          width: 120,
                          height: 1,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text('Recibe',
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                    ])),
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

    final bytes = await pdf.save();

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);

    print('PDF Reporte salida descargado exitosamente.');
  } catch (e) {
    print('Error al guardar el PDF: $e');
  }
}

// Función auxiliar para construir celdas de encabezado
pw.Widget _buildHeaderCell(String text, {double fontSize = 9}) {
  return pw.Container(
    decoration: const pw.BoxDecoration(color: PdfColors.black),
    padding: const pw.EdgeInsets.all(3),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: fontSize,
        color: PdfColors.white,
      ),
    ),
  );
}

// Función auxiliar para construir celdas de datos
pw.Widget _buildDataCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 8),
    ),
  );
}

String _convertirNumeroALetras(int numero) {
  if (numero == 0) return 'CERO';
  if (numero == 1) return 'UN';

  final unidades = [
    '',
    'UN',
    'DOS',
    'TRES',
    'CUATRO',
    'CINCO',
    'SEIS',
    'SIETE',
    'OCHO',
    'NUEVE'
  ];
  final decenas = [
    '',
    'DIEZ',
    'VEINTE',
    'TREINTA',
    'CUARENTA',
    'CINCUENTA',
    'SESENTA',
    'SETENTA',
    'OCHENTA',
    'NOVENTA'
  ];
  final especiales = [
    'DIEZ',
    'ONCE',
    'DOCE',
    'TRECE',
    'CATORCE',
    'QUINCE',
    'DIECISEIS',
    'DIECISIETE',
    'DIECIOCHO',
    'DIECINUEVE'
  ];
  final centenas = [
    '',
    'CIENTO',
    'DOSCIENTOS',
    'TRESCIENTOS',
    'CUATROCIENTOS',
    'QUINIENTOS',
    'SEISCIENTOS',
    'SETECIENTOS',
    'OCHOCIENTOS',
    'NOVECIENTOS'
  ];

  String resultado = '';
  int resto = numero;

  // Miles
  if (resto >= 1000) {
    final miles = resto ~/ 1000;
    if (miles == 1) {
      resultado += 'MIL ';
    } else {
      resultado += '${_convertirNumeroALetras(miles)} MIL ';
    }
    resto %= 1000;
  }

  // Centenas
  if (resto >= 100) {
    final centena = resto ~/ 100;
    resultado += '${centenas[centena]} ';
    resto %= 100;
    if (resto == 0 && centena == 1) {
      resultado = resultado.replaceAll('CIENTO', 'CIEN');
    }
  }

  // Decenas y unidades
  if (resto >= 10 && resto <= 19) {
    resultado += especiales[resto - 10];
  } else if (resto >= 20) {
    final decena = resto ~/ 10;
    resultado += decenas[decena];
    final unidad = resto % 10;
    if (unidad != 0) {
      resultado += ' Y ${unidades[unidad]}';
    }
  } else if (resto > 0) {
    resultado += unidades[resto];
  }

  return resultado.trim();
}
