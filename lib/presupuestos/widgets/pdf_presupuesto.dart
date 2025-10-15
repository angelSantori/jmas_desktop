import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/docs_pdf_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:qr_flutter/qr_flutter.dart';

//  Validación de campos
Future<bool> validarCamposPresupuesto({
  required BuildContext context,
  required List productosAgregados,
  required var selectedPadron,
}) async {
  if (selectedPadron == null) {
    showAdvertence(context, 'Debe seleccionar un padrón');
    return false;
  }

  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de guardar');
    return false;
  }

  return true;
}

//  PDF
Future<void> generarPDFPresupuesto({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  required Padron padron,
  required List<Map<String, dynamic>> productos,
}) async {
  try {
    // 1. Generar PDF como bytes
    final pdfBytes = await _generateSavePDFPresupuestoBytes(
      movimiento: movimiento,
      fecha: fecha,
      folio: folio,
      userName: userName,
      idUser: idUser,
      padron: padron,
      productos: productos,
    );

    // 2. Convertir a base64
    final base64Pdf = base64Encode(pdfBytes);

    // 3. Guardar en base de datos
    final dbSuccess = await _guardarPDFPresupuestoBD(
      nombreDocPDF: 'Presupuesto_Reporte_$folio.pdf',
      fechaDocPDF: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      dataDocPDF: base64Pdf,
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
    final String fileName =
        'Presupuesto_Reporte_${currentDate}_$currentTime.pdf';

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error al generar PDF de salida: $e');
    throw Exception('Error al generar el PDF');
  }
}

//  QR
Future<Uint8List> _generateQR(String data) async {
  final qrCode = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
  );
  final image = await qrCode.toImage(200);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

//  Guardar PDF original en BD
Future<bool> _guardarPDFPresupuestoBD({
  required String nombreDocPDF,
  required String fechaDocPDF,
  required String dataDocPDF,
  required int idUser,
}) async {
  final pdfController = DocsPdfController();
  return await pdfController.savePdf(
    nombreDocPdf: nombreDocPDF,
    fechaDocPdf: fechaDocPDF,
    dataDocPdf: dataDocPDF,
    idUser: idUser,
  );
}

//
Future<Uint8List> _generateSavePDFPresupuestoBytes({
  required String movimiento,
  required String fecha,
  required String folio,
  required String userName,
  required String idUser,
  required Padron padron,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Generar código QR
  final qrBytes = await _generateQR(folio);
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
                    'MOVIMIENTO: $movimiento',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Usuario | Folio | Fecha
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('INFORMACIÓN DEL MOVIMIENTO',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline,
                              )),
                          pw.SizedBox(height: 5),
                          pw.Text('Folio: $folio',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Fecha: $fecha',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                      pw.SizedBox(width: 50),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('INFORMACIÓN DE USUARIOS',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline,
                              )),
                          pw.SizedBox(height: 5),
                          pw.Text('Capturó: $idUser - $userName',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('INFORMACIÓN PADRON',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline,
                              )),
                          pw.SizedBox(height: 5),
                          pw.Text(
                              'Padron: ${padron.idPadron} - ${padron.padronNombre}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Dirección: ${padron.padronDireccion}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

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
                            child: pw.Text('Total + IVA',
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
          ],
        );
      },
    ),
  );
  return await pdf.save();
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
