import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/productos/details_producto_page.dart';
import 'package:jmas_desktop/productos/edit_producto_page.dart';
import 'package:jmas_desktop/productos/widgets/listas_caracteristicas.dart';
import 'package:jmas_desktop/widgets/excel_service.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ListProductoPage extends StatefulWidget {
  const ListProductoPage({super.key});

  @override
  State<ListProductoPage> createState() => _ListProductoPageState();
}

class _ListProductoPageState extends State<ListProductoPage> {
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();
  final TextEditingController _searchController = TextEditingController();
  Map<int, Proveedores> proveedoresCache = {};

  List<Productos> _allProductos = [];
  List<Productos> _filteredProductos = [];

  bool _isLoading = true;
  // ignore: unused_field
  bool _isLoadingQRRange = false;
  bool _showExcess = false;
  bool _showDeficit = false;
  bool _showServices = false;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
    _loadProveedores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _imprimirQRsPorRango() async {
    final idInicialController = TextEditingController();
    final idFinalController = TextEditingController();

    bool isGenerating = false;

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimir QRs por rango'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idInicialController,
              decoration:
                  const InputDecoration(labelText: 'ID Producto inicial'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: idFinalController,
              decoration: const InputDecoration(labelText: 'ID Producto final'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed:
                isGenerating ? null : () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: isGenerating
                ? null
                : () async {
                    final idInicial = int.tryParse(idInicialController.text);
                    final idFinal = int.tryParse(idFinalController.text);

                    if (idInicial == null || idFinal == null) {
                      showError(context, 'Ingrese IDs válidos');
                      return;
                    }

                    if (idInicial > idFinal) {
                      showError(context,
                          'El ID inicial debe ser menor o igual al final');
                      return;
                    }

                    setState(() => isGenerating = true);
                    await Future.delayed(const Duration(
                        milliseconds:
                            1)); // Para permitir que la UI se actualice
                    Navigator.pop(context, true);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: isGenerating
                ? const Text('Generando...',
                    style: TextStyle(color: Colors.white))
                : const Text('Continuar',
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmacion != true) return;

    setState(() {
      _isLoadingQRRange = true;
    });

    try {
      final idInicial = int.parse(idInicialController.text);
      final idFinal = int.parse(idFinalController.text);

      final productosEnRango = _allProductos.where((producto) {
        final id = producto.id_Producto ?? 0;
        return id >= idInicial && id <= idFinal;
      }).toList();

      if (productosEnRango.isEmpty) {
        showError(context, 'No hay productos en el rango especificado');
        return;
      }

      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Generando QRs...'),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  color: Colors.blue.shade900,
                ),
                const SizedBox(height: 10),
                Text(
                  'Generando ${productosEnRango.length} etiquetas',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );

      // Configuración y generación del PDF...
      final pdf = pw.Document();
      // Nueva configuración: 2 pulgadas de largo x 1 pulgada de ancho
      const labelWidthInInches = 1.0; // Ancho: 1 pulgada
      const labelHeightInInches = 2.0; // Alto: 2 pulgadas
      const dpi = 400; // Resolución de la impresora

      // Tamaño del QR (usamos 60% del lado más corto para dejar espacio)
      const qrSizeInInches = labelWidthInInches * 0.4;

      // Tamaño de página en puntos (1 pulgada = 72 puntos en PDF)
      const pageWidth = labelWidthInInches * 72;
      const pageHeight = labelHeightInInches * 72;

      // Calcular posiciones
      const qrWidth = qrSizeInInches * 120;
      const qrHeight = qrSizeInInches * 120;

      // Posición del QR (centrado verticalmente en la parte izquierda)
      const qrPosX = (labelWidthInInches * 72 * 0.2) - (qrWidth / 5);
      const qrPosY = (pageHeight - qrHeight) / 8;

      // Posición del texto (parte derecha)
      const textPosX = qrWidth + 10;
      const textPosY = pageHeight * 0.01;

      // Dentro del bucle for (var producto in productosEnRango)
      for (var producto in productosEnRango) {
        // Obtener la cuenta contable del producto
        final ccController = CcontablesController();
        final cuentas =
            await ccController.listCCxProducto(producto.id_Producto!);
        final ccProducto = cuentas.isNotEmpty ? cuentas.first.ccProducto : null;

        final qrPainter = QrPainter(
          data: producto.id_Producto.toString(),
          version: QrVersions.auto,
          gapless: true,
        );

        final qrImage = await qrPainter.toImageData(
          (qrSizeInInches * dpi).toDouble(),
          format: ui.ImageByteFormat.png,
        );

        if (qrImage == null) continue;

        pdf.addPage(
          pw.Page(
            pageFormat: const PdfPageFormat(
              pageHeight,
              pageWidth,
            ),
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  // QR en la parte izquierda
                  pw.Positioned(
                    left: qrPosX,
                    top: qrPosY,
                    child: pw.Container(
                      width: qrWidth,
                      height: qrHeight,
                      child: pw.Image(
                        pw.MemoryImage(qrImage.buffer.asUint8List()),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),

                  // Información del producto en la parte derecha
                  pw.Positioned(
                    left: textPosX,
                    top: textPosY,
                    child: pw.Container(
                      width: pageWidth,
                      height: pageHeight * 0.5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          // ID del producto
                          pw.Text(
                            '${producto.id_Producto}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.SizedBox(height: 5),

                          // Descripción del producto
                          pw.Text(
                            _truncateDescription(
                                producto.prodDescripcion ?? ''),
                            style: pw.TextStyle(
                              fontSize: 6,
                              color: PdfColors.black,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            maxLines: 3,
                            overflow: pw.TextOverflow.clip,
                          ),

                          // Cuenta contable en la base
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 2),
                            child: pw.Text(
                              ccProducto?.isNotEmpty == true
                                  ? 'Cuenta: $ccProducto'
                                  : 'Sin cuenta contable',
                              style: pw.TextStyle(
                                fontSize: 2,
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.normal,
                              ),
                            ),
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
      }

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'QRs_Productos_${idInicial}_a_$idFinal',
      );

      if (!mounted) return;
      showOk(context,
          '${productosEnRango.length} etiquetas QR generadas correctamente');
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showError(context, 'Error al generar QRs: ${e.toString()}');
      }
      print('Error al generar QRs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQRRange = false;
        });
      }
    }
  }

  Future<void> _loadProveedores() async {
    try {
      final proveedores = await _proveedoresController.listProveedores();
      setState(() {
        proveedoresCache = {for (var us in proveedores) us.id_Proveedor!: us};
      });
    } catch (e) {
      print('Error al cargar proveedores|Details productos|: $e');
    }
  }

  Future<void> _loadProductos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final productos = await _productosController.listProductos();
      setState(() {
        _allProductos = productos;
        _filteredProductos = productos;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductos = _allProductos.where((producto) {
        final descripcion = producto.prodDescripcion?.toLowerCase() ?? '';
        final clave = producto.id_Producto.toString();

        double? totalExistencias = _allProductos
            .firstWhere(
              (captura) => captura.id_Producto == producto.id_Producto,
              orElse: () => Productos(prodExistencia: null),
            )
            .prodExistencia;

        bool matchesSearch =
            descripcion.contains(query) || clave.contains(query);

        bool matchesExcess = _showExcess &&
            (totalExistencias != null && totalExistencias > producto.prodMax!);

        bool matchesDeficit = _showDeficit &&
            (totalExistencias != null && totalExistencias < producto.prodMin!);

        bool matchesServices = _showServices &&
            (producto.prodUMedEntrada?.toLowerCase() == 'servicio' &&
                producto.prodUMedSalida?.toLowerCase() == 'servicio');

        if (_showExcess || _showDeficit || _showServices) {
          return matchesSearch &&
              (matchesExcess || matchesDeficit || matchesServices);
        } else {
          // Si ningún filtro está activo, mostrar todos los que coincidan con la búsqueda
          return matchesSearch;
        }
      }).toList();
    });
  }

  Future<void> _exportarProductosConDeficit() async {
    try {
      final productos = await _productosController.getProductosConDeficit();
      if (productos.isEmpty) {
        showOk(context, 'No hay productos con deficit');
        return;
      }
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exportar productos con déficit'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('¿Estás seguro de exportar los datos?')],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await ExcelService.exportProductosToExcel(
                  productos: productos,
                  fileName: 'Productos_Deficit',
                );

                Navigator.pop(context);

                showOk(context,
                    'Reporte de productos con deficit generado correctamente');
              },
              child: const Text('Exportar'),
            ),
          ],
        ),
      );
    } catch (e) {
      showError(context, 'Error al generar reporte');
      print('Error al generar reporete: $e');
    }
  }

  Future<void> _exportarPorRango() async {
    final idInicialController = TextEditingController();
    final idFinalController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar por rango de IDs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idInicialController,
              decoration: const InputDecoration(labelText: 'Id Inicial'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: idFinalController,
              decoration: const InputDecoration(labelText: 'Id Final'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final idInicial = int.tryParse(idInicialController.text);
              final idFinal = int.tryParse(idFinalController.text);

              if (idInicial == null || idFinal == null) {
                showAdvertence(context, 'Por favor ingrese IDs válidos');
                return;
              }
              Navigator.pop(context);

              try {
                final productos = await _productosController
                    .getProductosPorRango(idInicial, idFinal);

                if (productos.isEmpty) {
                  showAdvertence(
                      context, 'No se encontraron productos en ese rango');
                  return;
                }

                await ExcelService.exportProductosToExcel(
                  productos: productos,
                  fileName: 'Productos_Rango',
                );

                showOk(context, 'Reporte generado exitosamente');
              } catch (e) {
                showError(context, 'Error al generar reporte');
                print('Error al generar reporete: $e');
              }
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generateQrPdf(
      int productId, String descripcion, String? ccProducto) async {
    final pdf = pw.Document();

    // Configuración: 2 pulgadas de largo x 1 pulgada de ancho
    const labelWidthInInches = 1.0; // Ancho: 1 pulgada
    const labelHeightInInches = 2.0; // Alto: 2 pulgadas

    // Tamaño del QR (40% del ancho de la etiqueta)
    const qrSizeInInches = labelWidthInInches * 0.4;
    final qrPixelSize =
        (qrSizeInInches * 400).toDouble(); // Para generar QR nítido

    // Generar imagen QR
    final qrPainter = QrPainter(
      data: productId.toString(),
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    // Crear imagen del QR
    final qrImage = await qrPainter.toImageData(qrPixelSize,
        format: ui.ImageByteFormat.png);
    if (qrImage == null) throw Exception('Error al generar imagen QR');

    // Tamaño de página en puntos (1 pulgada = 72 puntos en PDF)
    const pageWidth = labelWidthInInches * 72;
    const pageHeight = labelHeightInInches * 72;

    // Tamaño del QR en puntos PDF
    const qrWidth = qrSizeInInches * 120;
    const qrHeight = qrSizeInInches * 120;

    // Posición del QR (centrado verticalmente en la parte izquierda)
    const qrPosX = (labelWidthInInches * 72 * 0.2) - (qrWidth / 5);
    const qrPosY = (pageHeight - qrHeight) / 8;

    // Posición del texto (parte derecha con márgenes)
    const textPosX = qrWidth + 10;
    const textPosY = pageHeight * 0.1;

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(pageHeight, pageWidth),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // QR en la parte izquierda
              pw.Positioned(
                left: qrPosX,
                top: qrPosY,
                child: pw.Container(
                  width: qrWidth,
                  height: qrHeight,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                  child: pw.Image(
                    pw.MemoryImage(qrImage.buffer.asUint8List()),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

              // Información del producto en la parte derecha
              pw.Positioned(
                left: textPosX,
                top: textPosY,
                child: pw.Container(
                  width: pageWidth,
                  height: pageHeight * 0.8,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      // ID del producto
                      pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(
                          '$productId',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),

                      // Descripción del producto
                      pw.Container(
                        width: pageWidth,
                        child: pw.Text(
                          _truncateDescription(descripcion),
                          style: pw.TextStyle(
                            fontSize: 6,
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          maxLines: 5,
                          overflow: pw.TextOverflow.clip,
                        ),
                      ),

                      // Cuenta contable en la base
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          ccProducto?.isNotEmpty == true
                              ? '$ccProducto'
                              : 'Sin cuenta contable',
                          style: pw.TextStyle(
                            fontSize: 6,
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
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

    return pdf.save();
  }

  String _truncateDescription(String descripcion) {
    if (descripcion.isEmpty) return 'Sin Descripción';

    const maxChars = 45;
    if (descripcion.length <= maxChars) {
      return descripcion;
    }

    // Encontrar el último espacio antes del límite para no cortar palabras
    final truncated = descripcion.substring(0, maxChars);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace > 0) {
      return '${truncated.substring(0, lastSpace)}...';
    }

    return '$truncated...';
  }

  Future<void> _showPrintDialog(int productId, String descripcion) async {
    try {
      // Obtener la cuenta contable del producto
      final ccController = CcontablesController();
      final cuentas = await ccController.listCCxProducto(productId);
      final ccProducto = cuentas.isNotEmpty ? cuentas.first.ccProducto : null;

      final pdfBytes = await _generateQrPdf(productId, descripcion, ccProducto);

      // Esperar un breve momento antes de mostrar el diálogo
      await Future.delayed(const Duration(milliseconds: 300));

      // Usar un nuevo contexto para el diálogo de impresión
      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Etiqueta_Producto_$productId',
      );

      // Mostrar mensaje solo si el diálogo se cerró
      if (!mounted) return;
      showOk(context, 'QR generado correctamente');
    } catch (e) {
      if (!mounted) return;
      showError(context, 'Error al generar QR: ${e.toString()}');
      print('Error al generar QR: $e');
    }
  }

  Future<void> _exportarTodosLosProductos() async {
    try {
      if (_allProductos.isEmpty) {
        showOk(context, 'No hay productos para exportar');
        return;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exportar todos los productos'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('¿Estás seguro de exportar todos los productos?')],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await ExcelService.exportProductosToExcel(
                  productos: _allProductos,
                  fileName: 'Todos_Productos',
                );

                showOk(context,
                    'Reporte de todos los productos generado correctamente');
              },
              child: const Text('Exportar'),
            ),
          ],
        ),
      );
    } catch (e) {
      showError(context, 'Error al generar reporte');
      print('Error al generar reporte de todos los productos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.warning_rounded,
              color: Colors.green.shade800,
            ),
            tooltip: 'Exportar productos con déficit',
            onPressed: _exportarProductosConDeficit,
          ),
          IconButton(
            icon: Icon(Icons.filter_alt, color: Colors.green.shade800),
            tooltip: 'Exportar por rango de IDs',
            onPressed: _exportarPorRango,
          ),
          IconButton(
            icon: Icon(
              Icons.qr_code_2,
              color: Colors.green.shade800,
            ),
            tooltip: 'Imprimir QRs por',
            onPressed: _imprimirQRsPorRango,
          ),
          IconButton(
            icon: Icon(
              Icons.download,
              color: Colors.green.shade800,
            ),
            tooltip: 'Exportar todos los productos',
            onPressed: _exportarTodosLosProductos,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: CustomTextFielTexto(
                    controller: _searchController,
                    labelText: 'Buscar por descrición o clave',
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //  Excesos
                      Checkbox(
                        value: _showExcess,
                        activeColor: Colors.blue.shade900,
                        onChanged: (value) {
                          setState(() {
                            _showExcess = value ?? false;
                            _filterProductos();
                          });
                        },
                      ),
                      const Text(
                        'Excesos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 15),

                      //  Deficit Faltantes
                      Checkbox(
                        value: _showDeficit,
                        activeColor: Colors.blue.shade900,
                        onChanged: (value) {
                          setState(() {
                            _showDeficit = value ?? false;
                            _filterProductos();
                          });
                        },
                      ),
                      const Text(
                        'Faltantes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 15),

                      //  Servicios
                      Checkbox(
                        value: _showServices,
                        activeColor: Colors.blue.shade900,
                        onChanged: (value) {
                          setState(() {
                            _showServices = value ?? false;
                            _filterProductos();
                          });
                        },
                      ),
                      const Text(
                        'Servicios',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900),
                    )
                  : _filteredProductos.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay productos que coincidan con la búsqueda'),
                        )
                      : ListView.builder(
                          itemCount: _filteredProductos.length,
                          itemBuilder: (context, index) {
                            final producto = _filteredProductos[index];

                            double? invIniConteo = _allProductos
                                .firstWhere(
                                  (captura) =>
                                      captura.id_Producto ==
                                      producto.id_Producto,
                                  orElse: () => Productos(prodExistencia: null),
                                )
                                .prodExistencia;

                            Color cardColor =
                                const Color.fromARGB(255, 201, 230, 242);

                            return Card(
                              color: cardColor,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  showProductDetailsDialog(
                                    context,
                                    producto,
                                    proveedoresCache,
                                    _allProductos,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: producto.prodImgB64 != null &&
                                                producto.prodImgB64!.isNotEmpty
                                            ? Image.memory(
                                                base64Decode(
                                                    producto.prodImgB64!),
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/sinFoto.jpg',
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${producto.prodDescripcion}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Chip(
                                              label: Text(
                                                producto.prodEstado ??
                                                    'Sin estado',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: getEstadoColor(
                                                  producto.prodEstado),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 4),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Clave: ${producto.id_Producto}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Costo: \$${producto.prodCosto}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Cantidad: ${invIniConteo ?? 'N/A'}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Ubicación: ${producto.prodUbFisica?.isNotEmpty == true ? producto.prodUbFisica : 'Sin ubicación'}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PermissionWidget(
                                        permission: 'edit',
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                              tooltip: 'Editar producto',
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProductoPage(
                                                            producto: producto),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadProductos();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.qr_code,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                              tooltip: 'Generar etiqueta QR',
                                              onPressed: () => _showPrintDialog(
                                                  producto.id_Producto ?? 0,
                                                  producto.prodDescripcion ??
                                                      'N/A'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
