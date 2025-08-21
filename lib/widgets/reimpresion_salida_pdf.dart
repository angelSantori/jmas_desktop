import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReimpresionSalidaPdf {
  static Future<void> generateAndPrintPdfSalida({
    required String movimiento,
    required String fecha,
    required String folio,
    required String userName,
    required String idUser,
    required Almacenes almacen,
    required Users userAsignado,
    required String tipoTrabajo,
    required Padron padron,
    required Colonias colonia,
    required Calles calle,
    required Juntas junta,
    required Users userAutoriza,
    OrdenServicio? ordenServicio,
    String? comentario,
    required List<Map<String, dynamic>> productos,
    required bool mostrarEstado,
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

    // Definir columnas según si se muestra el estado o no
    final columnWidths = mostrarEstado
        ? {
            0: const pw.FixedColumnWidth(40), // Clave
            1: const pw.FixedColumnWidth(50), // Cantidad
            2: const pw.FlexColumnWidth(2.5), // Descripción
            3: const pw.FixedColumnWidth(50), // Costo
            4: const pw.FixedColumnWidth(50), // Total
            5: const pw.FixedColumnWidth(45), // Estado
          }
        : {
            0: const pw.FixedColumnWidth(50), // Clave
            1: const pw.FixedColumnWidth(50), // Cantidad
            2: const pw.FlexColumnWidth(3), // Descripción
            3: const pw.FixedColumnWidth(50), // Costo
            4: const pw.FixedColumnWidth(60), // Total
          };

    // Generar contenido del PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 33,
          marginRight: 33,
          marginTop: 33,
          marginBottom: 33,
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
                      'REIMPRESIÓN DE MOVIMIENTO DE INVENTARIOS: $movimiento',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),

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
                            pw.Text('Movimiento: $folio',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text('Fecha: $fecha',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                                'Almacen: ${almacen.id_Almacen} - ${almacen.almacen_Nombre}',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text('Tipo de Trabajo: $tipoTrabajo',
                                style: const pw.TextStyle(fontSize: 9)),
                            if (ordenServicio?.prioridadOS != null) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  'Orden Servicio: ${ordenServicio?.folioOS} - ${ordenServicio?.prioridadOS}',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
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
                            pw.SizedBox(height: 3),
                            pw.Text(
                                'Usuario Asignado: ${userAsignado.id_User} - ${userAsignado.user_Name}',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                                'Autoriza: ${userAutoriza.id_User} - ${userAutoriza.user_Name}',
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
                            pw.Text('INFORMACIÓN DESTINO',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  decoration: pw.TextDecoration.underline,
                                )),
                            pw.SizedBox(height: 5),
                            pw.Text(
                                'Junta: ${junta.id_Junta} - ${junta.junta_Name}',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                                'Colonia: ${colonia.idColonia} - ${colonia.nombreColonia}',
                                style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                                'Calle: ${calle.idCalle} - ${calle.calleNombre}',
                                style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.SizedBox(width: 50),
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

                  // Tabla de productos
                  pw.Table(
                    columnWidths: columnWidths,
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
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.black),
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Total',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 9,
                                      color: PdfColors.white))),
                          if (mostrarEstado)
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.black),
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Estado',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 9,
                                      color: PdfColors.white)),
                            ),
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
                                    child: pw.Text(
                                        producto['descripcion'] ?? '',
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
                                  if (mostrarEstado)
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          producto['estado'] ?? 'Activo',
                                          textAlign: pw.TextAlign.center,
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            color: (producto['estado'] ==
                                                        'Cancelado' ||
                                                    producto['estado'] == false)
                                                ? PdfColors.red
                                                : PdfColors.green,
                                          )),
                                    ),
                                ],
                              ))
                          .toList(),
                      // Fila de total
                      pw.TableRow(
                        children: [
                          // Celdas vacías según si se muestra estado o no
                          pw.Container(),
                          pw.Container(),
                          // Celda de descripción expandida (simula fusión)
                          pw.Expanded(
                            flex: mostrarEstado ? 2 : 3,
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
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                          ),
                          if (mostrarEstado) pw.Container(),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),

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
                child: pw.Container(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Columna izquierda con 2 firmas
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Firma de Solicitó (usuario asignado)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                                'Solicitó \n${userAsignado.user_Name}',
                                style: const pw.TextStyle(fontSize: 10),
                                textAlign:
                                    pw.TextAlign.center, // Texto centrado
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 50),
                          // Firma de Recibió (junta destino)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                                'Recibió \n${junta.junta_Name}',
                                style: const pw.TextStyle(fontSize: 10),
                                textAlign:
                                    pw.TextAlign.center, // Texto centrado
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Columna derecha con 2 firmas
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Firma de Entregó (quien captura)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                                'Entregó \n$userName',
                                style: const pw.TextStyle(fontSize: 10),
                                textAlign:
                                    pw.TextAlign.center, // Texto centrado
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 50),
                          // Firma de Autorizó (se mantiene igual)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                                'Autorizó \n${userAutoriza.user_Name}',
                                style: const pw.TextStyle(fontSize: 10),
                                textAlign:
                                    pw.TextAlign.center, // Texto centrado
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Generar nombre del archivo con la fecha actual
      final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
      final String currentTime = DateFormat('HHmmss').format(DateTime.now());
      final String fileName =
          'Reimpresion_Salida_${folio}_${currentDate}_$currentTime.pdf';

      final bytes = await pdf.save();

      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = fileName
        ..click();

      html.Url.revokeObjectUrl(url);

      debugPrint('PDF Reimpresión de salida generado exitosamente.');
    } catch (e) {
      debugPrint('Error al generar PDF de reimpresión: $e');
    }
  }

  static Future<Uint8List> generateQrCode(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
    );
    final image = await qrPainter.toImageData(300);
    return image!.buffer.asUint8List();
  }

  static String _convertirNumeroALetras(int numero) {
    if (numero == 0) return 'CERO';

    final unidades = [
      '',
      'UNO',
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

    // Miles
    if (numero >= 1000) {
      final miles = numero ~/ 1000;
      numero %= 1000;
      if (miles == 1) {
        resultado += 'MIL ';
      } else {
        resultado += '${_convertirNumeroALetras(miles)} MIL ';
      }
    }

    // Centenas
    if (numero >= 100) {
      final centena = numero ~/ 100;
      numero %= 100;
      resultado += '${centenas[centena]} ';
    }

    // Decenas y unidades
    if (numero >= 10 && numero <= 19) {
      resultado += especiales[numero - 10];
    } else if (numero >= 20) {
      final decena = numero ~/ 10;
      numero %= 10;
      resultado += decenas[decena];
      if (numero > 0) {
        resultado += ' Y ${unidades[numero]}';
      }
    } else if (numero > 0) {
      resultado += unidades[numero];
    }

    return resultado.trim();
  }
}
