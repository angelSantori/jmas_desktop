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
  List<Map<String, dynamic>> _filteredDocuments = [];
  bool _isLoading = true;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedDocType = 'Todos';
  DateTime? _startDate;
  DateTime? _endDate;

  // Document types extracted from names
  final List<String> _docTypes = [
    'Todos',
    'AjusteMas',
    'Prestamo_Herramientas',
    'Salida_Reporte',
    'Entrada_Reporte'
  ];

  @override
  void initState() {
    super.initState();
    _loadPdfDocuments();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfDocuments() async {
    setState(() => _isLoading = true);
    try {
      final documents = await _pdfController.listPdfDocuments();
      setState(() {
        _pdfDocuments = documents;
        _filteredDocuments = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showError(context, 'Error al cargar documentos');
      print('Error al cargar documentos: $e');
    }
  }

  void _applyFilters() {
    final searchTerm = _searchController.text.toLowerCase();
    final docType = _selectedDocType;

    setState(() {
      _filteredDocuments = _pdfDocuments.where((doc) {
        final name = doc['nombreDocPdf']?.toString().toLowerCase() ?? '';
        final date = doc['fechaDocPdf']?.toString() ?? '';

        // Apply search filter
        final matchesSearch = name.contains(searchTerm);

        // Apply document type filter
        final matchesDocType =
            docType == 'Todos' || name.startsWith(docType.toLowerCase());

        // Apply date filter if selected
        bool matchesDate = true;
        if (_startDate != null || _endDate != null) {
          try {
            final dateParts = date.split(' ');
            final dayMonthYear = dateParts[0].split('/');
            final docDate = DateTime(
              int.parse(dayMonthYear[2]),
              int.parse(dayMonthYear[1]),
              int.parse(dayMonthYear[0]),
            );

            if (_startDate != null && docDate.isBefore(_startDate!)) {
              matchesDate = false;
            }
            if (_endDate != null && docDate.isAfter(_endDate!)) {
              matchesDate = false;
            }
          } catch (e) {
            matchesDate = false;
          }
        }

        return matchesSearch && matchesDocType && matchesDate;
      }).toList();
    });
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
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDocType = 'Todos';
      _startDate = null;
      _endDate = null;
      _filteredDocuments = _pdfDocuments;
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
        title: const Text('Documentos PDF Guardados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdfDocuments,
          ),
        ],
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
                    const SizedBox(width: 30),

                    //Tipo
                    Expanded(
                      child: CustomListaDesplegable(
                        value: _selectedDocType,
                        labelText: 'Tipo de documento',
                        items: _docTypes,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDocType = newValue!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 30),

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
                    if (_startDate != null || _endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _applyFilters();
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),

                // Clear filters button

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
          ),

          // Documents list
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: Colors.blue.shade900))
                : _filteredDocuments.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'No hay documentos que coincidan con la búsqueda'
                              : (_startDate != null || _endDate != null)
                                  ? 'No hay documentos en el rango de fechas seleccionado'
                                  : (_selectedDocType != 'Todos')
                                      ? 'No hay documentos del tipo seleccionado'
                                      : 'No hay documentos disponibles',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = _filteredDocuments[index];
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
