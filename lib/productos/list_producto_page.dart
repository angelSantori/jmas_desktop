import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/productos/details_producto_page.dart';
//import 'package:jmas_desktop/productos/details_producto_page.dart';
import 'package:jmas_desktop/productos/edit_producto_page.dart';
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
  final CapturainviniController _capturainviniController =
      CapturainviniController();
  final TextEditingController _searchController = TextEditingController();
  Map<int, Proveedores> proveedoresCache = {};

  List<Productos> _allProductos = [];
  List<Productos> _filteredProductos = [];
  List<Capturainvini> capturaList = [];

  bool _isLoading = true;
  bool _showExcess = false;
  bool _showDeficit = false;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
    _loadProveedores();
    _loadCaoturaList();
  }

  Future<void> _loadCaoturaList() async {
    try {
      capturaList = await _capturainviniController.listCapturaI();
      setState(() {});
    } catch (e) {
      print('Error al cargar capturaList: $e');
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

        // Buscar el invIniConteo del producto en capturaList
        double? invIniConteo = capturaList
            .firstWhere(
              (captura) => captura.id_Producto == producto.id_Producto,
              orElse: () => Capturainvini(invIniConteo: null),
            )
            .invIniConteo;

        bool matchesSearch =
            descripcion.contains(query) || clave.contains(query);

        bool matchesExcess = _showExcess &&
            (invIniConteo != null && invIniConteo > producto.prodMax!);

        bool matchesDeficit = _showDeficit &&
            (invIniConteo != null && invIniConteo < producto.prodMin!);

        return matchesSearch &&
            (matchesExcess ||
                matchesDeficit ||
                (!_showExcess && !_showDeficit));
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

  Future<Uint8List> _generateQrPdf(int productId) async {
    final pdf = pw.Document();

    // Configuración específica para ZDesigner ZT610
    const labelWidthInInches = 0.787; // Ancho de etiqueta
    const labelHeightInInches = 0.528; // Alto de etiqueta
    const dpi = 400; // Resolución de la impresora

    // Tamaño del QR (usamos 80% del lado más corto para dejar margen)
    const qrSizeInInches = labelHeightInInches * 0.85;
    final qrPixelSize = (qrSizeInInches * dpi).toDouble();

    // Generar imagen QR
    final qrPainter = QrPainter(
      data: productId.toString(),
      version: QrVersions.auto,
      gapless: true,
    );

    // Crear imagen del QR
    final qrImage = await qrPainter.toImageData(qrPixelSize,
        format: ui.ImageByteFormat.png);
    if (qrImage == null) throw Exception('Error al generar imagen QR');

    // Tamaño de página en puntos (1 pulgada = 72 puntos en PDF)
    const pageWidth = labelWidthInInches * 72;
    const pageHeight = labelHeightInInches * 72;

    // Calcular posición centrada
    final qrWidth = qrSizeInInches * 72;
    final qrHeight = qrSizeInInches * 72;
    final posX = (pageWidth - qrWidth) / 3.3;
    final posY = (pageHeight - qrHeight) / 2;

    // Crear PDF con tamaño exacto
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Fondo blanco
              pw.Container(
                width: pageWidth,
                height: pageHeight,
                color: PdfColors.white,
              ),
              // QR posicionado exactamente en el centro
              pw.Positioned(
                left: posX,
                top: posY,
                child: pw.Container(
                  width: qrWidth,
                  height: qrHeight,
                  child: pw.Image(
                    pw.MemoryImage(qrImage.buffer.asUint8List()),
                    fit: pw.BoxFit.cover,
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

  Future<void> _showPrintDialog(int productId) async {
    try {
      final pdfBytes = await _generateQrPdf(productId);

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
                        'Mostrar excesos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 15),
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
                        'Mostrar faltantes',
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

                            double? invIniConteo = capturaList
                                .firstWhere(
                                  (captura) =>
                                      captura.id_Producto ==
                                      producto.id_Producto,
                                  orElse: () =>
                                      Capturainvini(invIniConteo: null),
                                )
                                .invIniConteo;

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
                                    capturaList,
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
                                                  producto.id_Producto!),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
