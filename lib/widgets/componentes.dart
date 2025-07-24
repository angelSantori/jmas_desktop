import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/docs_pdf_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

//ListTitle
class CustomListTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia el cursor al pasar el mouse
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200), // Duración de la animación
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered
                ? Colors.blue.shade600
                : Colors.transparent, // Color de fondo al hacer hover
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.3), // Color de la sombra
                      blurRadius: 10, // Difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ]
                : [], // Sin sombra cuando no hay hover
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            hoverColor:
                Colors.transparent, // Desactiva el hoverColor de InkWell
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  widget.icon,
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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

//ExpansionTitle
class CustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Duración de la animación
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _isHovered
              ? Colors.blue.shade800
              : Colors.transparent, // Color de fondo al hacer hover
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Color de la sombra
                    blurRadius: 10, // Difuminado de la sombra
                    offset: const Offset(0, 5), // Desplazamiento de la sombra
                  ),
                ]
              : [], // Sin sombra cuando no hay hover
        ),
        child: Theme(
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
                widget.icon,
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

//SubExpansionTitle
class SubCustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;

  const SubCustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  _SubCustomExpansionTileState createState() => _SubCustomExpansionTileState();
}

class _SubCustomExpansionTileState extends State<SubCustomExpansionTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200), // Duración de la animación
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered
                ? Colors.blue.shade700
                : Colors.transparent, // Color de fondo al hacer hover
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.3), // Color de la sombra
                      blurRadius: 10, // Difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ]
                : [], // Sin sombra cuando no hay hover
          ),
          child: Theme(
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
                  widget.icon,
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              children: widget.children,
            ),
          ),
        ),
      ),
    );
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

Future<bool> guardarPDFEntradaBD({
  required String nombreDocPdf,
  required String fechaDocPdf,
  required String dataDocPdf,
  required int idUser,
}) async {
  final pdfController = DocsPdfController();
  return await pdfController.savePdf(
    nombreDocPdf: nombreDocPdf,
    fechaDocPdf: fechaDocPdf,
    dataDocPdf: dataDocPdf,
    idUser: idUser,
  );
}

Future<void> generarPdfEntrada({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  required String referencia,
  required Almacenes alamcenA,
  required Proveedores proveedorP,
  required String numFactura,
  String? comentario,
  required List<Map<String, dynamic>> productos,
}) async {
  try {
    // 1. Generar PDF con bytes
    final pdfBytes = await generateAndPrintPdfEntradaByte(
      movimiento: movimiento,
      fecha: fecha,
      folio: folio,
      userName: userName,
      idUser: idUser,
      referencia: referencia,
      alamcenA: alamcenA,
      proveedorP: proveedorP,
      numFactura: numFactura,
      comentario: comentario,
      productos: productos,
    );

    // 2. Convertir a base 64
    final base64Pdf = base64Encode(pdfBytes);

    // 3. Guardar en base de datos
    final dbSuccess = await guardarPDFEntradaBD(
      nombreDocPdf: 'Entrada_Reporte_$folio.pdf',
      fechaDocPdf: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      dataDocPdf: base64Pdf,
      idUser: int.parse(idUser),
    );

    if (!dbSuccess) {
      print('PDF se descargó pero no se guardó en la BD');
    }

    // 4. Descargar localmente
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'Entrada_Reporte_${currentDate}_$currentTime.pdf';

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error al generar PDF de entrada: $e');
    throw Exception('Error al generar el PDF');
  }
}

Future<Uint8List> generateAndPrintPdfEntradaByte({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  required String referencia,
  required Almacenes alamcenA,
  required Proveedores proveedorP,
  required String? numFactura,
  String? comentario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Generar código QR
  final qrBytes = await generateQrCode(folio);
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
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
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
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                      margin: const pw.EdgeInsets.only(right: 15),
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
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'www.jmasmeoqui.gob.mx',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          )
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
                          pw.Text('Mov: $folio',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Ref: $referencia',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              'Prov: ${proveedorP.id_Proveedor} - ${proveedorP.proveedor_Name}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),

                      // Columna central
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Fec: $fecha',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Capturó: $idUser - $userName',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Junta: 1 - Meoqui',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),

                      // Columna derecha
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Almacen: ${alamcenA.id_Almacen} - ${alamcenA.almacen_Nombre}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Número Factura: $numFactura',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabla de productos con solución alternativa para celdas fusionadas
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(50), // Clave
                    1: const pw.FixedColumnWidth(50), // Cantidad
                    2: const pw.FlexColumnWidth(3), // Descripción
                    3: const pw.FixedColumnWidth(50), // Costo
                    4: const pw.FixedColumnWidth(60), // Total
                  },
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    // Encabezados de tabla
                    pw.TableRow(
                      children: [
                        pw.Container(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.black),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Clave',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.white)),
                        ),
                        pw.Container(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.black),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Cantidad',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.white)),
                        ),
                        pw.Container(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.black),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Descripción',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.white)),
                        ),
                        pw.Container(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.black),
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Costo/Uni',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.white)),
                        ),
                        pw.Container(
                            decoration:
                                const pw.BoxDecoration(color: PdfColors.black),
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Total',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white))),
                      ],
                    ),
                    // Filas de productos
                    ...productos
                        .map((producto) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(producto['id'].toString(),
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      producto['cantidad'].toString(),
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(producto['descripcion'] ?? '',
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      '\$${(producto['costo'] ?? 0.0).toStringAsFixed(2)}',
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      '\$${(producto['precio'] ?? 0.0).toStringAsFixed(2)}',
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                              ],
                            ))
                        .toList(),
                    // Fila de total con solución alternativa para celdas fusionadas
                    pw.TableRow(
                      children: [
                        // Celda de clave vacía
                        pw.Container(),
                        // Celda de cantidad vacía
                        pw.Container(),
                        // Celda de descripción expandida (simula fusión)
                        pw.Expanded(
                          flex: 3, // Ocupa el espacio de 3 columnas
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('SON: $totalEnLetras',
                                style: const pw.TextStyle(fontSize: 8)),
                          ),
                        ),
                        // Celda de "Total"
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

                //  Comentario
                if (comentario != null && comentario.isNotEmpty) ...[
                  pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(top: 10),
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('COMENTARIOS: ',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                )),
                            pw.SizedBox(height: 3),
                            pw.Text(comentario,
                                style: const pw.TextStyle(fontSize: 8))
                          ])),
                  pw.SizedBox(height: 30),
                ],
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
              child: pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 180,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Autorizó',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

// Función para convertir números a letras
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

            TextEditingController costoController = TextEditingController(
              text: producto['costo'] is double
                  ? producto['costo'].toStringAsFixed(2)
                  : producto['costo'].toString(),
            );

            return TableRow(
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(
                    texto: producto['descripcion'] ?? 'Sin descripción'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: costoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    onSubmitted: (nuevoValor) {
                      double nuevoCosto = double.tryParse(nuevoValor) ??
                          (producto['costo'] is double
                              ? producto['costo']
                              : double.tryParse(producto['costo'].toString()) ??
                                  0.0);
                      // Asegurar que el nuevo costo tenga 2 decimales
                      actualizarCosto(
                          index, double.parse(nuevoCosto.toStringAsFixed(2)));
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    ),
                  ),
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
  final VoidCallback? onEnterPressed;

  const BuscarProductoWidget({
    super.key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
    this.onEnterPressed,
  });

  @override
  State<BuscarProductoWidget> createState() => _BuscarProductoWidgetState();
}

class _BuscarProductoWidgetState extends State<BuscarProductoWidget> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  //double? _invIniConteo;
  double? _existencia;
  final TextEditingController _nombreProducto = TextEditingController();
  final FocusNode _cantidadFocusNode = FocusNode();
  List<Productos> _productosSugeridos = [];
  Timer? _debounce;

  @override
  void dispose() {
    _nombreProducto.dispose();
    _debounce?.cancel();
    _cantidadFocusNode.dispose();
    super.dispose();
  }

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
          final existenciaList =
              await widget.productosController.listProductos();

          final existencia = existenciaList.firstWhere(
            (element) => element.id_Producto == producto.id_Producto,
            orElse: () => Productos(prodExistencia: null),
          );
          setState(() {
            _existencia = existencia.prodExistencia;
          });

          widget.onProductoSeleccionado(producto);

          FocusScope.of(context).requestFocus(_cantidadFocusNode);
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

  Future<void> _buscarProductoXNombre(String query) async {
    if (query.isEmpty) {
      setState(() => _productosSugeridos = []);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final productos =
            await widget.productosController.getProductoByNombre(query);

        if (mounted) {
          setState(() => _productosSugeridos = productos);
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar productos: $e');
        setState(() => _productosSugeridos = []);
      }
    });
  }

  void _seleccionarProducto(Productos producto) {
    widget.idProductoController.text = producto.id_Producto.toString();
    widget.onProductoSeleccionado(producto);
    setState(() {
      _productosSugeridos = [];
      _nombreProducto.clear();
    });
  }

  // Widget de búsqueda por nombre (modificado ligeramente)
  Widget _buildBuscadorPorNombre() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextFielTexto(
                      controller: _nombreProducto,
                      labelText: 'Escribe el nombre del producto',
                      prefixIcon: Icons.search,
                      onChanged: _buscarProductoXNombre,
                    ),
                  ),
                ],
              ),
              if (_productosSugeridos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _productosSugeridos.length,
                    itemBuilder: (context, index) {
                      final producto = _productosSugeridos[index];
                      return ListTile(
                        title: Text(producto.prodDescripcion ?? 'Sin nombre'),
                        subtitle: Text(
                          'ID: ${producto.id_Producto} - Costo: \$${producto.prodCosto?.toStringAsFixed(2) ?? 'No disponible'}',
                        ),
                        onTap: () => _seleccionarProducto(producto),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DividerWithText(text: 'Selección de Productos'),
        const SizedBox(height: 20),
        _buildBuscadorPorNombre(),
        const SizedBox(height: 30),
        Row(
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
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _buscarProducto();
                  }
                },
              ),
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
                            'Costo: \$${widget.selectedProducto!.prodCosto?.toStringAsFixed(2) ?? 'No disponible'}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Existencia: ${_existencia ?? 'No disponible'}',
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
                                  _decodeImage(widget
                                          .selectedProducto!.prodImgB64) !=
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
                  style: TextStyle(fontSize: 14),
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
                    focusNode: _cantidadFocusNode,
                    prefixIcon: Icons.numbers_outlined,
                    labelText: 'Cantidad',
                    onFieldSubmitted: (value) {
                      if (widget.selectedProducto != null && value.isNotEmpty) {
                        widget.onEnterPressed?.call();
                      }
                    },
                  ),
                ),
              ],
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
    required var padron,
    required var calle,
    required var colonia,
    var selectedServicio,
    required var selectedJunta,
    required var selectedUser}) async {
  if (referenciaController.text.isEmpty) {
    showAdvertence(context, 'La referencia es obligatoria.');
    return false;
  }

  // if (selectedServicio == null) {
  //   showAdvertence(context, 'Debe seleccionar una orden de servicio.');
  //   return false;
  // }

  if (selectedAlmacen == null) {
    showAdvertence(context, 'Debe seleccionar un almacen.');
    return false;
  }

  if (selectedUser == null) {
    showAdvertence(context, 'Debe asignar un empleado.');
    return false;
  }

  if (selectedJunta == null) {
    showAdvertence(context, 'Debe seleccionar una junta.');
    return false;
  }

  if (colonia.text.isEmpty) {
    showAdvertence(context, 'Colonia es obligatoria.');
    return false;
  }

  if (calle.text.isEmpty) {
    showAdvertence(context, 'Calle es obligatoria.');
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
  required String numFactura,
  required var selectedAlmacen,
  required var proveedor,
  //required var junta,
  required Uint8List? factura,
}) async {
  if (referencia.isEmpty) {
    showAdvertence(context, 'Referencia es obligatoria.');
    return false;
  }

  if (numFactura.isEmpty) {
    showAdvertence(context, 'Número de factura es obligatoria.');
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

  // if (junta == null) {
  //   showAdvertence(context, 'Debe seleccionar una junta.');
  //   return false;
  // }

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
    // Primero intenta con el formato que incluye mes/día/año hora:minuto:segundo
    final formats = [
      'dd/MM/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm',
      'dd/MM/yyyy HH:mm',
      'dd/MM/yyyy',
    ];

    for (var format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {
        continue;
      }
    }

    // Si ninguno de los formatos anteriores funciona, intenta parsear como DateTime directamente
    return DateTime.tryParse(dateString);
  } catch (e) {
    print('Error al parsear fecha: $dateString');
    return null;
  }
}
