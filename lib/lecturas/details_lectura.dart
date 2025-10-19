import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/lectenviar_controller.dart';
import 'package:jmas_desktop/contollers/problemas_lectura_controller.dart';

class DetailsLecturaDialog extends StatefulWidget {
  final LELista lectura;

  const DetailsLecturaDialog({super.key, required this.lectura});

  @override
  State<DetailsLecturaDialog> createState() => _DetailsLecturaDialogState();
}

class _DetailsLecturaDialogState extends State<DetailsLecturaDialog> {
  final LecturaEnviarController _lecturaController = LecturaEnviarController();
  final ProblemasLecturaController _problemasController =
      ProblemasLecturaController();

  LecturaEnviar? _lecturaCompleta;
  String? _nombreProblema;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar datos completos de la lectura
      final lecturaCompleta = await _lecturaController
          .getLectEnviarById(widget.lectura.idLectEnviar);

      // Cargar nombre del problema si existe
      String? nombreProblema;
      if (widget.lectura.idProblemaLectura != null) {
        final problemas = await _problemasController.listProblmeasLectura();
        final problema = problemas.firstWhere(
          (p) => p.idProblema == widget.lectura.idProblemaLectura,
          orElse: () =>
              ProblemasLectura(idProblema: -1, plDescripcion: 'No encontrado'),
        );
        nombreProblema = problema.plDescripcion;
      }

      setState(() {
        _lecturaCompleta = lecturaCompleta;
        _nombreProblema = nombreProblema;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: isImportant ? Colors.blue.shade900 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail() {
    final fotoBase64 = _lecturaCompleta?.leFotoBase64;

    // Verificar si es nulo o está vacío
    if (fotoBase64 == null || fotoBase64.isEmpty) {
      return Container(
        width: 120,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Sin foto',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showFullScreenPhoto,
      child: Container(
        width: 120,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64.decode(fotoBase64),
            width: 120,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 24),
                    SizedBox(height: 4),
                    Text(
                      'Error',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenPhoto() {
    final fotoBase64 = _lecturaCompleta?.leFotoBase64;

    // Verificar si es nulo o está vacío
    if (fotoBase64 == null || fotoBase64.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: Image.memory(
                  base64.decode(fotoBase64),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey.shade200,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text('Error al cargar la imagen'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, List<Widget> children) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(30),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando información...'),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalles de Lectura',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estado de la lectura
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.lectura.leEstado == true
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.lectura.leEstado == true
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.lectura.leEstado == true
                              ? Icons.check_circle
                              : Icons.pending,
                          color: widget.lectura.leEstado == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.lectura.leEstado == true
                                ? 'Lectura registrada'
                                : 'Lectura pendiente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.lectura.leEstado == true
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tres columnas de información
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Columna 1: Información del Cliente
                                _buildInfoColumn(
                                  'Información del Cliente',
                                  [
                                    _buildInfoRow(Icons.numbers, 'ID Registro',
                                        widget.lectura.idLectEnviar.toString()),
                                    if (widget.lectura.leCuenta != null)
                                      _buildInfoRow(Icons.credit_card, 'Cuenta',
                                          widget.lectura.leCuenta!),
                                    if (widget.lectura.leNombre != null)
                                      _buildInfoRow(Icons.person, 'Nombre',
                                          widget.lectura.leNombre!,
                                          isImportant: true),
                                    if (widget.lectura.leDireccion != null)
                                      _buildInfoRow(
                                          Icons.location_on,
                                          'Dirección',
                                          widget.lectura.leDireccion!),
                                    if (widget.lectura.leId != null)
                                      _buildInfoRow(Icons.badge, 'ID Padrón',
                                          widget.lectura.leId.toString()),
                                    if (widget.lectura.leRuta != null)
                                      _buildInfoRow(Icons.map, 'Ruta',
                                          widget.lectura.leRuta!),
                                  ],
                                ),

                                // Columna 2: Información de Lectura
                                _buildInfoColumn(
                                  'Información de Lectura',
                                  [
                                    if (widget.lectura.lePeriodo != null)
                                      _buildInfoRow(Icons.calendar_today,
                                          'Período', widget.lectura.lePeriodo!),
                                    _buildInfoRow(Icons.date_range, 'Fecha',
                                        _formatDate(widget.lectura.leFecha)),
                                    if (widget.lectura.leNumeroMedidor != null)
                                      _buildInfoRow(
                                          Icons.speed,
                                          'Número de Medidor',
                                          widget.lectura.leNumeroMedidor!),
                                    if (widget.lectura.leLecturaAnterior !=
                                        null)
                                      _buildInfoRow(
                                          Icons.arrow_back,
                                          'Lectura Anterior',
                                          widget.lectura.leLecturaAnterior
                                              .toString()),
                                    if (widget.lectura.leLecturaActual != null)
                                      _buildInfoRow(
                                          Icons.arrow_forward,
                                          'Lectura Actual',
                                          widget.lectura.leLecturaActual
                                              .toString(),
                                          isImportant: true),
                                  ],
                                ),

                                // Columna 3: Problema Reportado y Foto
                                _buildInfoColumn(
                                  widget.lectura.idProblemaLectura != null
                                      ? 'Problema Reportado'
                                      : 'Estado',
                                  [
                                    if (widget.lectura.idProblemaLectura !=
                                        null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.red.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.warning,
                                                    color: Colors.red.shade700),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'ID Problema: ${widget.lectura.idProblemaLectura}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _nombreProblema ?? 'Cargando...',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green.shade700),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Sin problemas reportados',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // Sección de Foto Miniatura
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Foto del Medidor',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildPhotoThumbnail(),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Miniatura',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Haga clic para ver en pantalla completa',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
