import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<Uint8List> generarPdfOrdenCompraBytes({
  required String folioOC,
  required String fechaOC,
  required String requisicionOC,
  required String fechaEntregaOC,
  required String direccionEntregaOC,
  required String centroCostoOC,
  required String centroBeneficioOC,
  required String notasOC,
  required String proveedorName,
  required String userName,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();
  final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  // Cargar imagen del logo desde assets
  final logoImage = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo_jmas_sf.png'))
        .buffer
        .asUint8List(),
  );

  // Calcular totales CORREGIDO - usando precioUnitario * cantidad
  double subtotal = productos.fold(
      0,
      (sum, item) =>
          sum + ((item['precioUnitario'] ?? 0) * (item['cantidad'] ?? 0)));
  double iva = subtotal * 0.16;
  double total = subtotal + iva;

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 20, // Reducido margen izquierdo
        marginRight: 20, // Reducido margen derecho
        marginTop: 20, // Reducido margen superior
        marginBottom: 20, // Reducido margen inferior
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Encabezado con borde negro
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2, color: PdfColors.black),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
                  pw.SizedBox(width: 10),
                  // Título
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: double.infinity,
                          color: PdfColors.black,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'JUNTA MUNICIPAL DE AGUA Y SANEAMIENTO DE MEOQUI',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: double.infinity,
                          color: PdfColors.grey300,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'ORDEN DE COMPRA - COMPRA DIRECTA',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  // Información de formato
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Formato: D F 5 C .20',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 10),
                      pw.Text('Fecha: 05.03.2024',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 10),
                      pw.Text('Versión: 1.1',
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // Fecha y folio
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('Fecha',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      width: 70,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        border: pw.Border.all(width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        fechaOC,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('No. Folio',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(width: 10),
                          pw.Text(folioOC,
                              style: const pw.TextStyle(fontSize: 10)),
                        ]),
                    pw.SizedBox(height: 5),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Requisición No.',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(width: 10),
                          pw.Container(
                            width: 70,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey300,
                              border: pw.Border.all(width: 0.5),
                            ),
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              requisicionOC,
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ]),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Proveedor
            pw.Text('1. Proveedor:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(width: 0.5),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(proveedorName,
                  style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.SizedBox(height: 10),

            // Entrega - MODIFICADO para mostrar fecha y dirección en línea
            pw.Text('2. Entrega:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Fecha:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          border: pw.Border.all(width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(fechaEntregaOC,
                            style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dirección:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          border: pw.Border.all(width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(direccionEntregaOC,
                            style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Centros de costo y beneficio
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Centro de Costo',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          border: pw.Border.all(width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(centroCostoOC,
                            style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Centro de Beneficio',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          border: pw.Border.all(width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(centroBeneficioOC,
                            style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // División
            pw.Divider(thickness: 1, color: PdfColors.black),

            // Tabla de artículos
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // No.
                1: const pw.FlexColumnWidth(3), // Descripción
                2: const pw.FixedColumnWidth(50), // Cantidad
                3: const pw.FixedColumnWidth(50), // Unidad
                4: const pw.FixedColumnWidth(70), // Precio Unitario
                5: const pw.FixedColumnWidth(70), // Importe Total
              },
              children: [
                // Encabezados
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('No.',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Descripción',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Cantidad',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Unidad',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Precio Unitario',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Importe Total',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Artículos
                ...productos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final producto = entry.value;
                  final importeTotal = (producto['precioUnitario'] ?? 0) *
                      (producto['cantidad'] ?? 0);

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${index + 1}',
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(producto['descripcion'] ?? '',
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(producto['cantidad'].toStringAsFixed(2),
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(producto['unidadMedida'] ?? '',
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                            formatCurrency.format(producto['precioUnitario']),
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(formatCurrency.format(importeTotal),
                            style: const pw.TextStyle(fontSize: 9)),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 5),

            // Información de entrega y totales
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PARA ENTREGA DE MATERIAL:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('     1. Copia de Orden de Compra',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(
                          '     2. Original y copia de factura de acuerdo a la orden de compra con fecha del mes en curso',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(
                          '     3. Solo se reciben facturas para pago del mes en curso hasta el día 25',
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  flex: 1,
                  child: pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Subtotal:',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(formatCurrency.format(subtotal),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('IVA 16%:',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(formatCurrency.format(iva),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('TOTAL:',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(formatCurrency.format(total),
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            // División
            pw.Divider(thickness: 1, color: PdfColors.black),

            // Notas adicionales
            pw.Text('Notas Adicionales:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(notasOC, style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.SizedBox(height: 20),

            // Firmas - MODIFICADO para solo tener subrayado
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(width: 1.0),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(bottom: 20),
                      child: pw.SizedBox(height: 40),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Firma Comprador',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(width: 1.0),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(bottom: 20),
                      child: pw.SizedBox(height: 40),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Firma de Autorización Dirección Financiera',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

Future<html.File> generarPdfOrdenCompraFile({
  required String folioOC,
  required String fechaOC,
  required String requisicionOC,
  required String fechaEntregaOC,
  required String direccionEntregaOC,
  required String centroCostoOC,
  required String centroBeneficioOC,
  required String notasOC,
  required String proveedorName,
  required String userName,
  required List<Map<String, dynamic>> productos,
}) async {
  final bytes = await generarPdfOrdenCompraBytes(
    folioOC: folioOC,
    fechaOC: fechaOC,
    requisicionOC: requisicionOC,
    fechaEntregaOC: fechaEntregaOC,
    direccionEntregaOC: direccionEntregaOC,
    centroCostoOC: centroCostoOC,
    centroBeneficioOC: centroBeneficioOC,
    notasOC: notasOC,
    proveedorName: proveedorName,
    userName: userName,
    productos: productos,
  );

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName =
      'OrdenCompra_${folioOC}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.pdf';

  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = fileName
    ..click();

  html.Url.revokeObjectUrl(url);

  return html.File([bytes], fileName, {'type': 'application/pdf'});
}
