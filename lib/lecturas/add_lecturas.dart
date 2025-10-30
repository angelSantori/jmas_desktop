import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:jmas_desktop/contollers/lectenviar_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class AddLecturasEnviarScreen extends StatefulWidget {
  const AddLecturasEnviarScreen({super.key});

  @override
  State<AddLecturasEnviarScreen> createState() =>
      _AddLecturasEnviarScreenState();
}

class _AddLecturasEnviarScreenState extends State<AddLecturasEnviarScreen> {
  final LecturaEnviarController _controller = LecturaEnviarController();

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  bool _hasFile = false;
  List<Map<String, dynamic>> _parsedData = [];
  int _successCount = 0;
  int _errorCount = 0;
  List<String> _errors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Lecturas desde Archivo'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          if (_hasFile)
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar selección',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información y guía
            _buildInfoCard(),
            const SizedBox(height: 20),

            // Selector de archivo
            _buildFileSelector(),
            const SizedBox(height: 20),

            // Vista previa de datos
            if (_parsedData.isNotEmpty) _buildDataPreview(),

            // Resultados de la carga
            if (_successCount > 0 || _errorCount > 0) _buildResults(),

            // Botones de acción
            if (_hasFile) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Información de Carga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Formato esperado del archivo CSV:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '• El archivo debe contener las columnas: leCuenta, leNombre, leDireccion, leId, lePeriodo, leNumeroMedidor, leLecturaAnterior, leLecturaActual, leRuta',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              '• Las fechas se asignarán automáticamente a la fecha actual',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              '• El estado se establecerá como "true" (registrado)',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Archivo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Seleccionar Archivo CSV/Excel'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _selectedFile!.size != null
                                ? '${(_selectedFile!.size! / 1024).toStringAsFixed(2)} KB'
                                : 'Tamaño no disponible',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _clearSelection,
                      icon: Icon(Icons.close, color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataPreview() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Vista Previa de Datos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text('${_parsedData.length} registros'),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.blue.shade50,
                    ),
                    columns: const [
                      DataColumn(label: Text('Cuenta')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Lectura Actual')),
                      DataColumn(label: Text('Período')),
                    ],
                    rows: _parsedData.take(10).map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['leCuenta']?.toString() ?? '')),
                        DataCell(Text(data['leNombre']?.toString() ?? 'N/A')),
                        DataCell(
                            Text(data['leLecturaActual']?.toString() ?? '')),
                        DataCell(Text(data['lePeriodo']?.toString() ?? '')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (_parsedData.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Mostrando 10 de ${_parsedData.length} registros',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados de la Carga',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildResultChip(
                  'Éxitos',
                  _successCount,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildResultChip(
                  'Errores',
                  _errorCount,
                  Colors.red,
                ),
              ],
            ),
            if (_errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Detalles de errores:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: _errors.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.error,
                          color: Colors.red.shade700, size: 16),
                      title: Text(
                        _errors[index],
                        style:
                            TextStyle(fontSize: 12, color: Colors.red.shade700),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _processFile,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
            label: Text(_isLoading ? 'Procesando...' : 'Cargar Lecturas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _clearSelection,
            icon: const Icon(Icons.clear),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.single;
          _hasFile = true;
        });

        // Parsear el archivo inmediatamente después de seleccionarlo
        await _parseCSVFile();
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar archivo');
      print('Error al seleccionar archivo | _pickFile: $e');
    }
  }

  Future<void> _parseCSVFile() async {
    if (_selectedFile == null) return;

    try {
      setState(() {
        _isLoading = true;
        _parsedData = [];
      });

      List<int> bytes;

      // Obtener los bytes del archivo
      if (_selectedFile!.bytes != null) {
        // Para web - usar bytes
        bytes = _selectedFile!.bytes!;
      } else if (_selectedFile!.path != null) {
        // Para desktop - usar path
        final file = File(_selectedFile!.path!);
        bytes = await file.readAsBytes();
      } else {
        _showSnackBar('No se pudo acceder al archivo');
        return;
      }

      // Intentar diferentes codificaciones
      String csvString;
      try {
        // Primero intentar con UTF-8
        csvString = utf8.decode(bytes);
      } catch (e) {
        try {
          // Si falla, intentar con Latin1 (common en archivos de Windows)
          csvString = latin1.decode(bytes);
        } catch (e) {
          _showSnackBar('Error: No se pudo decodificar el archivo');
          return;
        }
      }

      // Parsear CSV
      final csvTable = const CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty) {
        _showSnackBar('El archivo está vacío');
        return;
      }

      // Obtener encabezados (primera fila)
      final headers = csvTable[0].cast<String>();

      // Mapear datos - CORREGIDO: usar los nombres de columna correctos
      final parsedData = <Map<String, dynamic>>[];

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        final rowData = <String, dynamic>{};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          rowData[headers[j]] = row[j];
        }

        // Validar que tenga datos mínimos
        if (rowData['leCuenta'] != null &&
            rowData['leCuenta'].toString().isNotEmpty) {
          parsedData.add(rowData);
        }
      }

      setState(() {
        _parsedData = parsedData;
      });

      if (_parsedData.isEmpty) {
        _showSnackBar('No se encontraron registros válidos');
      } else {
        _showSnackBar('Se encontraron ${_parsedData.length} registros');
      }
    } catch (e) {
      _showSnackBar('Error al procesar archivo: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processFile() async {
    if (_parsedData.isEmpty) {
      _showSnackBar('No hay datos válidos para procesar');
      return;
    }

    setState(() {
      _isLoading = true;
      _successCount = 0;
      _errorCount = 0;
      _errors = [];
    });

    for (final data in _parsedData) {
      try {
        // Validar campos requeridos
        if (data['leCuenta'] == null || data['leCuenta'].toString().isEmpty) {
          throw Exception('Cuenta es requerida');
        }

        if (data['leLecturaActual'] == null) {
          throw Exception('Lectura actual es requerida');
        }

        // Crear objeto LecturaEnviar - CORREGIDO con todos los campos
        final lecturaEnviar = LecturaEnviarCompleto(
          idLectEnviar: 0,
          leCampo1: data['leCampo1']?.toString() ?? "Jmas",
          leCampo2: data['leCampo2']?.toString() ?? "SERGIO",
          leCampo3: _parseInt(data['leCampo3']) ?? 0,
          leCampo4: _parseInt(data['leCampo4']) ?? 0,
          leCampo5: data['leCampo5']?.toString(),
          leCampo6: _parseInt(data['leCampo6']) ?? 0,
          leCampo7: _parseInt(data['leCampo7']) ?? 0,
          leCampo8: _parseInt(data['leCampo8']) ?? 0,
          leCampo9: data['leCampo9']?.toString() ?? "01/01/1900",
          leCampo10: data['leCampo10']?.toString() ?? "01/01/1900",
          leCuenta: data['leCuenta']?.toString(),
          leNombre: data['leNombre']?.toString(),
          leDireccion: data['leDireccion']?.toString(),
          leCampo11: data['leCampo11']?.toString(),
          leId: _parseInt(data['leId']),
          lePeriodo: data['lePeriodo']?.toString(),
          leFecha: null,
          leCampo12: data['leCampo12']?.toString() ?? "D",
          leCampo13: data['leCampo13']?.toString() ?? "V",
          leCampo14: data['leCampo14']?.toString() ?? ":",
          leNumeroMedidor: data['leNumeroMedidor']?.toString(),
          leLecturaAnterior: _parseInt(data['leLecturaAnterior']),
          leLecturaActual: _parseInt(data['leLecturaActual']),
          idProblemaLectura: 1,
          leRuta: data['leRuta']?.toString(),
          leCampo15: data['leCampo15']?.toString(),
          leCampo16: data['leCampo16']?.toString(),
          leCampo17: _parseInt(data['leCampo17']),
          leCampo18: data['leCampo18']?.toString() ?? "N",
          leCampo19: data['leCampo19']?.toString() ?? "C1",
          leCampo20: _parseInt(data['leCampo20']) ?? 0,
          leCampo21: _parseInt(data['leCampo21']) ?? 0,
          leFotoBase64: null,
          idUser: null,
          leEstado: false,
          leUbicacion: null,
        );

        final success = await _createLecturaEnviar(lecturaEnviar);

        if (success) {
          setState(() {
            _successCount++;
          });
        } else {
          throw Exception('Error al guardar en la base de datos');
        }
      } catch (e) {
        setState(() {
          _errorCount++;
          _errors.add('Error en registro ${data['leCuenta']}: $e');
        });
      }
    }

    setState(() {
      _isLoading = false;
    });

    _showResultsDialog();
  }

  // Método auxiliar para crear la lectura - CORREGIDO
  Future<bool> _createLecturaEnviar(LecturaEnviarCompleto lectura) async {
    try {
      // Llamar al método real del controlador que envía a la API
      final success = await _controller.createLectEnviar(lectura);

      if (success) {
        print('✅ Lectura guardada: ${lectura.leCuenta}');
        return true;
      } else {
        print('❌ Error al guardar: ${lectura.leCuenta}');
        return false;
      }
    } catch (e) {
      print('Error al crear lectura: $e');
      return false;
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Limpiar string y convertir
      final cleaned = value.trim();
      if (cleaned.isEmpty || cleaned == 'null') return null;
      return int.tryParse(cleaned);
    }
    return null;
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultados de la Carga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Registros exitosos: $_successCount'),
            Text('❌ Registros con errores: $_errorCount'),
            if (_errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Errores detallados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 150,
                width: 400,
                child: ListView.builder(
                  itemCount: _errors.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          const Icon(Icons.error, size: 16, color: Colors.red),
                      title: Text(
                        _errors[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_errorCount == 0) {
                _clearSelection();
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _hasFile = false;
      _parsedData = [];
      _successCount = 0;
      _errorCount = 0;
      _errors = [];
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
