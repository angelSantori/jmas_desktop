import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/docs_pdf_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'dart:html' as html;

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  State<PdfListPage> createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  final DocsPdfController _pdfController = DocsPdfController();
  List<Map<String, dynamic>> _pdfDocuments = [];
  bool _isLoading = false;
  bool _hasSearched =
      false; // Nuevo estado para controlar si se ha realizado una búsqueda

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Document types extracted from names
  final List<String> _docTypes = [
    'AjusteMas',
    'Prestamo_Herramientas',
    'Salida_Reporte',
    'Entrada_Reporte',
    'Orden_Servicio',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDocuments() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true; // Marcar que se ha realizado una búsqueda
    });
    try {
      // Convertir fechas a formato string si existen
      final startDateStr = _startDate != null
          ? DateFormat('dd/MM/yyyy').format(_startDate!)
          : null;
      final endDateStr =
          _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : null;

      // Llamar al nuevo método de búsqueda en el controlador
      final documents = await _pdfController.searchPdfDocuments(
        name: _searchController.text,
        docType: _selectedDocType,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      setState(() {
        _pdfDocuments = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showError(context, 'Error al buscar documentos');
      print('Error al buscar documentos: $e');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDocType = null;
      _startDate = null;
      _endDate = null;
      _pdfDocuments = [];
      _hasSearched = false; // Resetear el estado de búsqueda
    });
  }

  Future<void> _viewPdf(int idDocumentPdf) async {
    try {
      final pdfBytes = await _pdfController.downloadPdf(idDocumentPdf);
      _showPdfViewerDialog(pdfBytes);
    } catch (e) {
      showError(context, 'Error al abrir el PDF: $e');
    }
  }

  void _showPdfViewerDialog(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda de Documentos PDF'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Texto
                    Expanded(
                      child: CustomTextFielTexto(
                        controller: _searchController,
                        labelText: 'Buscar por nombre',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    const SizedBox(width: 20),

                    //Tipo
                    Expanded(
                      child: CustomListaDesplegable(
                        value: _selectedDocType,
                        labelText: 'Tipo de documento',
                        items: _docTypes,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDocType = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),

                    //Fecha
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDateRange(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 201, 230, 242),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade900,
                        ),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                              : 'Rango de fechas',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  Botón de busqueda
                    ElevatedButton(
                      onPressed: _searchDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        elevation: 8,
                        shadowColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        'Buscar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 100),

                    //  Limpiar filtros
                    ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        elevation: 8,
                        shadowColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        'Limpiar todos los filtros',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Documents list
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: Colors.blue.shade900))
                : _pdfDocuments.isEmpty
                    ? Center(
                        child: Text(
                          _hasSearched
                              ? 'No se encontraron resultados'
                              : 'Ingrese los criterios de búsqueda y presione "Buscar"',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pdfDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = _pdfDocuments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              title: Text(
                                doc['nombreDocPdf'] ?? 'Documento sin nombre',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Fecha: ${doc['fechaDocPdf'] ?? 'Desconocida'}'),
                                  Text(
                                    'Tipo: ${_getDocumentType(doc['nombreDocPdf'])}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _viewPdf(doc['idDocumentPdf']),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getDocumentType(String? fileName) {
    if (fileName == null) return 'Desconocido';
    if (fileName.startsWith('AjusteMas')) return 'Ajustes Mas';
    if (fileName.startsWith('Prestamo_Herramientas')) {
      return 'Préstamo Herramientas';
    }
    if (fileName.startsWith('Salida_Reporte')) return 'Salida Reporte';
    if (fileName.startsWith('Entrada_Reporte')) return 'Entrada Reporte';
    return 'Otro';
  }
}
