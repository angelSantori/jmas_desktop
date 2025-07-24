import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/docs_pdf_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

// Función para guardar el PDF en la base de datos
Future<bool> guardarPdfPrestamoEnBD({
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

// Función principal que genera, guarda y descarga el PDF
Future<void> generarPdfPrestamoHerramientas({
  required String folio,
  required String fechaPrestamo,
  required String fechaDevolucion,
  required Users responsable,
  required Users? empleadoAsignado,
  required String? externoNombre,
  required String? externoContacto,
  required List<Map<String, dynamic>> herramientas,
}) async {
  try {
    // 1. Generar PDF como bytes
    final pdfBytes = await generarPdfPrestamoHerramientasBytes(
      folio: folio,
      fechaPrestamo: fechaPrestamo,
      fechaDevolucion: fechaDevolucion,
      responsable: responsable,
      empleadoAsignado: empleadoAsignado,
      externoNombre: externoNombre,
      externoContacto: externoContacto,
      herramientas: herramientas,
    );

    // 2. Convertir a base64
    final base64Pdf = base64Encode(pdfBytes);

    // 3. Guardar en base de datos
    final dbSuccess = await guardarPdfPrestamoEnBD(
      nombreDocPdf: 'Prestamo_Herramientas_$folio.pdf',
      fechaDocPdf: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      dataDocPdf: base64Pdf,
      idUser: responsable.id_User ?? 0,
    );

    if (!dbSuccess) {
      print('PDF se descargó pero no se guardó en la BD');
    }

    // 4. Descargar localmente
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final fileName = 'Prestamo_Herramientas_${currentDate}_$currentTime.pdf';

    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error al generar PDF de préstamo: $e');
    throw Exception('Error al generar el PDF');
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

Future<Uint8List> generarPdfPrestamoHerramientasBytes({
  required String folio,
  required String fechaPrestamo,
  required String fechaDevolucion,
  required Users responsable,
  required Users? empleadoAsignado,
  required String? externoNombre,
  required String? externoContacto,
  required List<Map<String, dynamic>> herramientas,
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

  pdf.addPage(
    pw.Page(
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
                // Encabezado con logo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.Image(logoImage),
                      margin: const pw.EdgeInsets.only(right: 15),
                    ),
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
                    pw.SizedBox(width: 70),
                  ],
                ),

                // Título del documento
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 15, bottom: 15),
                  child: pw.Text(
                    'COMPROBANTE DE PRÉSTAMO DE HERRAMIENTAS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Información del préstamo
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Columna izquierda
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Folio: $folio',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Fecha préstamo: $fechaPrestamo',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text('Fecha devolución: $fechaDevolucion',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),

                      // Columna derecha
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Responsable: ${responsable.id_User ?? 0} - ${responsable.user_Name ?? 'No Disponible'}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          if (empleadoAsignado != null)
                            pw.Text(
                                'Asignado a: ${empleadoAsignado.id_User ?? 0} - ${empleadoAsignado.user_Name ?? 'No Disponible'}',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (externoNombre != null)
                            pw.Text('Externo: $externoNombre',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (externoContacto != null)
                            pw.Text('Contacto: $externoContacto',
                                style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabla de herramientas
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(50), // ID
                    1: const pw.FixedColumnWidth(50), // Cantidad
                    2: const pw.FlexColumnWidth(3), // Descripción
                    3: const pw.FixedColumnWidth(60), // Fecha préstamo
                    4: const pw.FixedColumnWidth(60), // Fecha devolución
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
                          child: pw.Text('ID',
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
                          child: pw.Text('Cant.',
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
                          child: pw.Text('Herramienta',
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
                          child: pw.Text('Préstamo',
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
                            child: pw.Text('Devolución',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                    color: PdfColors.white))),
                      ],
                    ),
                    // Filas de herramientas
                    ...herramientas
                        .map((herramienta) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(herramienta['id'].toString(),
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      '1', // Cantidad fija 1 por herramienta
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(herramienta['nombre'] ?? '',
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(herramienta['fechaPrestamo'],
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      herramienta['fechaDevolucion'] ??
                                          'Pendiente',
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(fontSize: 8)),
                                ),
                              ],
                            ))
                        .toList(),
                  ],
                ),

                // Observaciones
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Observaciones:',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        height: 50,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                      ),
                    ],
                  ),
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

            // Sección de firmas al pie de página
            pw.Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  // Firma de quien recibe
                  pw.Column(children: [
                    pw.Container(
                      width: 120,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Recibe', style: const pw.TextStyle(fontSize: 10)),
                  ]),
                  // Firma de quien entrega
                  pw.Column(children: [
                    pw.Container(
                      width: 120,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Entrega', style: const pw.TextStyle(fontSize: 10)),
                  ]),
                  // Firma de autorización
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
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

Future<html.File> generarPdfPrestamoHerramientasFile({
  required String folio,
  required String fechaPrestamo,
  required String fechaDevolucion,
  required Users responsable,
  required Users? empleadoAsignado,
  required String? externoNombre,
  required String? externoContacto,
  required List<Map<String, dynamic>> herramientas,
}) async {
  final bytes = await generarPdfPrestamoHerramientasBytes(
      folio: folio,
      fechaPrestamo: fechaPrestamo,
      fechaDevolucion: fechaDevolucion,
      responsable: responsable,
      empleadoAsignado: empleadoAsignado,
      externoNombre: externoNombre,
      externoContacto: externoContacto,
      herramientas: herramientas);

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Generar nombre del archivo
  final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
  final String currentTime = DateFormat('HHmmss').format(DateTime.now());
  final String fileName =
      'Prestamo_Herramientas_${folio}_${currentDate}_$currentTime.pdf';

  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = fileName
    ..click();

  html.Url.revokeObjectUrl(url);

  return html.File([bytes], fileName, {'type': 'application/pdf'});
}
