import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

// Función para generar el archivo PDF
Future<void> generateAndPrintPdf({
  required BuildContext context,
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
            pw.Text('Reporte de Entrada', style: pw.TextStyle(fontSize: 24)),
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
