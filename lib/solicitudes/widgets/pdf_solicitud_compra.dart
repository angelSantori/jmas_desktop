import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class PdfSolicitudCompra {
  // Generar y descargar PDF
  static Future<void> generarPdfSolicitudCompra({
    required BuildContext context,
    required String folio,
    required String objetivo,
    required String especificaciones,
    required String observaciones,
    required DateTime fechaSolicitud,
    required String usuarioSolicita,
    required String usuarioValida,
    required String usuarioAutoriza,
    required String idUserCaptura,
    required String nombreUserCaptura,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      // 1. Generar PDF como bytes
      final pdfBytes = await _generatePdfSolicitudBytes(
        folio: folio,
        objetivo: objetivo,
        especificaciones: especificaciones,
        observaciones: observaciones,
        fechaSolicitud: fechaSolicitud,
        usuarioSolicita: usuarioSolicita,
        usuarioValida: usuarioValida,
        usuarioAutoriza: usuarioAutoriza,
        productos: productos,
        nombreUserCaptura: nombreUserCaptura,
      );

      // 4. Descargar localmente
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
      final String currentTime = DateFormat('HHmmss').format(DateTime.now());
      final String fileName =
          'Solicitud_Compra_${folio}_${currentDate}_$currentTime.pdf';

      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = fileName
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al generar PDF de solicitud de compra: $e');
      throw Exception('Error al generar el PDF de solicitud de compra');
    }
  }

  // Generar bytes del PDF
  static Future<Uint8List> _generatePdfSolicitudBytes({
    required String folio,
    required String objetivo,
    required String especificaciones,
    required String observaciones,
    required DateTime fechaSolicitud,
    required String usuarioSolicita,
    required String usuarioValida,
    required String usuarioAutoriza,
    required String nombreUserCaptura,
    required List<Map<String, dynamic>> productos,
  }) async {
    final pdf = pw.Document();

    // Cargar imagen del logo desde assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_jmas_sf.png'))
          .buffer
          .asUint8List(),
    );

    // Cálculo del total
    final total = productos.fold<double>(
      0.0,
      (sum, producto) => sum + (producto['total'] ?? 0.0),
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
                    ],
                  ),

                  // Título del documento
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.only(top: 20, bottom: 15),
                    child: pw.Text(
                      'SOLICITUD DE BIENES O SERVICIOS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),

                  // Información general de la solicitud
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('INFORMACIÓN GENERAL',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    decoration: pw.TextDecoration.underline,
                                  )),
                              pw.SizedBox(height: 8),
                              _buildInfoRowPDF('Folio:', folio),
                              pw.SizedBox(height: 5),
                              _buildInfoRowPDF(
                                  'Fecha:',
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(fechaSolicitud)),
                              pw.SizedBox(height: 5),
                              _buildInfoRowPDF(
                                  'Solicitado por:', usuarioSolicita),
                              pw.SizedBox(height: 5),
                              _buildInfoRowPDF('Validado por:', usuarioValida),
                              pw.SizedBox(height: 5),
                              _buildInfoRowPDF(
                                  'Autorizado por:', usuarioAutoriza),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('DETALLES DE LA SOLICITUD',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    decoration: pw.TextDecoration.underline,
                                  )),
                              pw.SizedBox(height: 8),
                              _buildInfoRowPDF('Objetivo:', objetivo),
                              if (especificaciones.isNotEmpty) ...[
                                pw.SizedBox(height: 5),
                                _buildInfoRowPDF(
                                    'Especificaciones:', especificaciones),
                              ],
                              if (observaciones.isNotEmpty) ...[
                                pw.SizedBox(height: 5),
                                _buildInfoRowPDF(
                                    'Observaciones:', observaciones),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabla de productos
                  pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(50), // Cantidad
                      1: const pw.FlexColumnWidth(3), // Descripción
                      2: const pw.FixedColumnWidth(60), // Costo/Uni
                      3: const pw.FixedColumnWidth(70), // Total
                    },
                    border: pw.TableBorder.all(width: 0.5),
                    children: [
                      // Encabezados de tabla
                      pw.TableRow(
                        children: [
                          _buildHeaderCell('Cantidad'),
                          _buildHeaderCell('Descripción'),
                          _buildHeaderCell('Costo/Uni'),
                          _buildHeaderCell('Total'),
                        ],
                      ),
                      // Filas de productos
                      ...productos
                          .map((producto) => pw.TableRow(
                                children: [
                                  _buildDataCell(
                                      producto['cantidad'].toString()),
                                  _buildDataCell(producto['descripcion'] ?? ''),
                                  _buildDataCell(
                                      '\$${producto['costoUnitario']?.toStringAsFixed(2) ?? '0.00'}'),
                                  _buildDataCell(
                                      '\$${producto['total']?.toStringAsFixed(2) ?? '0.00'}'),
                                ],
                              ))
                          .toList(),
                      // Fila de total con celdas fusionadas
                      pw.TableRow(
                        children: [
                          // Celda vacía para cantidad
                          pw.Container(),
                          // Celda expandida para "SON: total en letras" (simula fusión)
                          pw.Expanded(
                            flex: 2, // Ocupa el espacio de 2 columnas
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('SON: $totalEnLetras',
                                  style: const pw.TextStyle(fontSize: 8)),
                            ),
                          ),
                          // Celda de "Total"
                          _buildHeaderCell('Total'),
                          // Celda con valor total
                          _buildDataCell(
                            '\$${total.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 40),
                ],
              ),

              // Sección de firmas al pie de página
              pw.Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: pw.Container(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      // Firma de Solicita
                      _buildFirmaSectionLine('SOLICITA', usuarioSolicita),
                      // Firma de Valida
                      _buildFirmaSectionLine('VALIDA', usuarioValida),
                      // Firma de Autoriza
                      _buildFirmaSectionLine('AUTORIZA', usuarioAutoriza),
                      // Campo de Fecha
                      _buildFirmaSectionLine('FECHA', ''),
                    ],
                  ),
                ),
              ),

              // Pie de página con información del sistema
              pw.Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: pw.Container(
                  child: pw.Text(
                    'Documento generado por: $nombreUserCaptura - ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
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

  // Métodos auxiliares para construir celdas
  static pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      decoration: const pw.BoxDecoration(color: PdfColors.black),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildInfoRowPDF(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFirmaSectionLine(String titulo, String nombre) {
    return pw.Column(
      children: [
        pw.Container(
          width: 120,
          height: 1,
          decoration: const pw.BoxDecoration(
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          nombre,
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // Función para convertir número a letras (copiada de pdf_salida.dart)
  static String _convertirNumeroALetras(int numero) {
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
}
