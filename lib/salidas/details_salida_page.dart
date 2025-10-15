import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/contratistas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/salidas/widgets/details_producto_auxiliar.dart';
import 'package:jmas_desktop/salidas/widgets/pdf_salida.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_cancelacion.dart';
import '../widgets/reimpresion_salida_pdf.dart';

class DetailsSalidaPage extends StatefulWidget {
  final String userRole;
  final List<Salidas> salidas;
  final Almacenes almacen;
  final Juntas junta;
  final Padron padron;
  final Colonias colonia;
  final Calles calle;
  final Users userAsignado;
  final Users userAutoriza;
  final Users userCreoSalida;
  final OrdenServicio? ordenServicio;
  final String user;
  final Contratistas? contratista;
  final VoidCallback? onDocumentUploaded;

  const DetailsSalidaPage({
    super.key,
    required this.salidas,
    required this.almacen,
    required this.junta,
    required this.user,
    required this.padron,
    required this.userAsignado,
    required this.userRole,
    required this.colonia,
    required this.calle,
    required this.userAutoriza,
    this.ordenServicio,
    this.onDocumentUploaded,
    required this.userCreoSalida,
    this.contratista,
  });

  @override
  State<DetailsSalidaPage> createState() => _DetailsSalidaPageState();
}

class _DetailsSalidaPageState extends State<DetailsSalidaPage> {
  final ProductosController _productosController = ProductosController();
  final CanceladoSalidaController _canceladoSalidaController =
      CanceladoSalidaController();
  final AuthService _authService = AuthService();
  final UsersController _usersController = UsersController();
  final SalidasController _salidasController = SalidasController();
  late Future<Map<int, ProductosOptimizado>> _productosFuture;

  String? _currentUserId;
  Users? _currentUser;
  bool _isLoading = false;
  final TextEditingController _motivoController = TextEditingController();
  Map<int, ProductosOptimizado>? productosCache;
  bool _isUploadingDocument = false;
  Uint8List? _documentoFirmas;
  Uint8List? _documentoPago;

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProductos();
    _getCurrentUser();
    _verificarDocumentoExistente();
    _verificarPagoExistente();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _verificarDocumentoExistente() async {
    try {
      final tieneDocumento = widget.salidas.any((s) =>
          s.salida_DocumentoFirmas != null &&
          s.salida_DocumentoFirmas!.isNotEmpty);

      if (tieneDocumento) {
        final documento = await SalidasController()
            .getDocumentoFirmas(widget.salidas.first.salida_CodFolio!);
        if (mounted) {
          setState(() => _documentoFirmas = documento);
        }
      }
    } catch (e) {
      print(
          'Error al verificar documento existente | _verificarDocumentoExistente | DetailsSalida: $e');
    }
  }

  Future<void> _verificarPagoExistente() async {
    try {
      final tienePago = widget.salidas.any((s) =>
          s.salida_DocumentoPago != null && s.salida_DocumentoPago!.isNotEmpty);

      if (tienePago) {
        final documento = await SalidasController()
            .getDocumentoPago(widget.salidas.first.salida_CodFolio!);
        if (mounted) {
          setState(() => _documentoPago = documento);
        }
      }
    } catch (e) {
      print(
          'Error al verificar documento existente | _verificarDocumentoExistente | DetailsSalida: $e');
    }
  }

  Future<void> _subirDocumentoFirmas() async {
    final filePicker = FilePicker.platform;
    final result = await filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploadingDocument = true);

    try {
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        final success = await SalidasController().uploadDocumentoFirmas(
          widget.salidas.first.salida_CodFolio!,
          fileBytes,
        );

        if (success) {
          setState(() => _documentoFirmas = fileBytes);
          for (var salida in widget.salidas) {
            salida.salida_DocumentoFirmas = "documento_subido";
          }
          if (widget.onDocumentUploaded != null) {
            widget.onDocumentUploaded!();
          }
          showOk(context, 'Documento subido correctamente');
        } else {
          showError(context, 'Error al subir documento');
        }
      }
    } catch (e) {
      print('ERROR _subirDocumentoFirmas | Try | DetailsSalida: $e');
      showError(context, 'Error al procesar el archivo');
    } finally {
      setState(() => _isUploadingDocument = false);
    }
  }

  Future<void> _subirDocumentoPago() async {
    final filePicker = FilePicker.platform;
    final result = await filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploadingDocument = true);

    try {
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        final success = await _salidasController.uploadDocumentoPago(
          widget.salidas.first.salida_CodFolio!,
          fileBytes,
        );

        if (success) {
          setState(() => _documentoPago = fileBytes);
          for (var salida in widget.salidas) {
            salida.salida_DocumentoPago = 'documento_subido';
          }
          if (widget.onDocumentUploaded != null) {
            widget.onDocumentUploaded!();
          }
          showOk(context, 'Documento subido correctamente');
        } else {
          showError(context, 'Error al subir el documento');
        }
      }
    } catch (e) {
      print('ERROR _subirDocumentoPago | Try | DetailsSalida: $e');
      showError(context, 'Error al procesar el archivo');
    } finally {
      setState(() => _isUploadingDocument = false);
    }
  }

  Future<void> _descargarDocumentoFirmas() async {
    setState(() => _isLoading = true);
    try {
      final documento = await _salidasController
          .getDocumentoFirmas(widget.salidas.first.salida_CodFolio!);
      if (documento != null) {
        setState(() => _documentoFirmas = documento);

        final result = await FileSaver.instance.saveFile(
          name: 'documento_firmas_${widget.salidas.first.salida_CodFolio}.pdf',
          bytes: documento,
          customMimeType: 'pdf',
        );

        if (result != null) {
          showOk(context, 'Documento descargado correctamente');
        }
      } else {
        showAdvertence(context, 'No hay documento de firmas para esta salida');
      }
    } catch (e) {
      print('ERROR _descargarDocumentoFirmas | DetailsSalida: $e');
      showError(context, 'Error al descargar documento');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _descargarDocumentoPago() async {
    setState(() => _isLoading = true);
    try {
      final documento = await _salidasController
          .getDocumentoPago(widget.salidas.first.salida_CodFolio!);
      if (documento != null) {
        setState(() => _documentoPago = documento);

        final result = await FileSaver.instance.saveFile(
          name: 'documento_pago_${widget.salidas.first.salida_CodFolio}.pdf',
          bytes: documento,
          customMimeType: 'pdf',
        );

        if (result != null) {
          showOk(context, 'Documento descargado correctamente');
        }
      } else {
        showAdvertence(context, 'No hay documento de pago para esta salida');
      }
    } catch (e) {
      print('ERROR _descargarDocumentoPago | DetailsSalida: $e');
      showError(context, 'Error al descargar el documento');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentUser() async {
    final decodeToken = await _authService.decodeToken();
    if (decodeToken != null) {
      final userId = decodeToken['Id_User']?.toString() ?? '0';
      final user = await _usersController.getUserById(int.parse(userId));
      setState(() {
        _currentUserId = userId;
        _currentUser = user;
      });
    }
  }

  Future<Map<int, ProductosOptimizado>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductosOptimizado();
      return {for (var prod in productos) prod.id_Producto!: prod};
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  Future<void> _imprimirSalida() async {
    setState(() => _isLoading = true);
    try {
      final productosCache = await _productosFuture;
      final productosParaPDF = <Map<String, dynamic>>[];

      final Map<int, List<Salidas>> salidasPorProducto = {};
      for (var salida in widget.salidas) {
        salidasPorProducto.update(
          salida.idProducto!,
          (value) => [...value, salida],
          ifAbsent: () => [salida],
        );
      }

      for (var entry in salidasPorProducto.entries) {
        final producto = productosCache[entry.key];
        final cantidad = entry.value.fold<double>(
            0, (sum, salida) => sum + (salida.salida_Unidades ?? 0));
        final total = entry.value.fold<double>(
            0.0, (sum, salida) => sum + (salida.salida_Costo ?? 0.0));
        final tieneActivos = entry.value.any((s) => s.salida_Estado == true);

        productosParaPDF.add({
          'id': entry.key,
          'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
          'cantidad': cantidad,
          'costo': total / cantidad,
          'precio': total,
          'estado': tieneActivos ? 'Activo' : 'Cancelado',
          'prodUMedEntrada': producto?.prodUMedEntrada ?? '',
          'prodUMedSalida': producto?.prodUMedSalida ?? '',
        });
      }

      await ReimpresionSalidaPdf.generateAndPrintPdfSalida(
        movimiento: 'SALIDA',
        fecha: widget.salidas.first.salida_Fecha ?? '',
        folio: widget.salidas.first.salida_CodFolio ?? '',
        userName: widget.userCreoSalida.user_Name!,
        idUser: widget.userCreoSalida.id_User.toString(),
        almacen: widget.almacen,
        folioOST: widget.salidas.first.salidaFolioOST ?? 'N/A',
        contratista: widget.contratista,
        userAutoriza: widget.userAutoriza,
        junta: widget.junta,
        userAsignado: widget.userAsignado,
        tipoTrabajo: widget.salidas.first.salida_TipoTrabajo ?? '',
        padron: widget.padron,
        colonia: widget.colonia,
        calle: widget.calle,
        ordenServicio: widget.ordenServicio,
        productos: productosParaPDF,
        comentario: widget.salidas.first.salida_Comentario,
        mostrarEstado: true,
      );
    } catch (e) {
      showError(context, 'Error al generar PDF: $e');
      debugPrint('Error al generar PDF: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelarTodaLaSalida() async {
    final formKey = GlobalKey<FormState>();
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar toda la salida'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Está seguro que desea cancelar toda esta salida?'),
              const SizedBox(height: 20),
              CustomTextFielTexto(
                controller: _motivoController,
                labelText: 'Motivo de la cancelación',
                prefixIcon: Icons.info_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un motivo';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmacion != true) return;

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> productosParaPDF = [];
      final productosCache = await _productosFuture;

      for (var salida in widget.salidas) {
        if (salida.salida_Estado == true) {
          final cancelacion = CanceladoSalidas(
            idCanceladoSalida: 0,
            cancelSalidaMotivo: _motivoController.text,
            cancelSalidaFecha:
                DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
            id_Salida: salida.id_Salida,
            id_User: int.parse(_currentUserId!),
          );

          final cancelacionExitosa =
              await _canceladoSalidaController.addCancelSalida(cancelacion);
          if (!cancelacionExitosa) {
            throw Exception(
                'Error al registrar la cancelación para salida ${salida.id_Salida}');
          }

          salida.salida_Estado = false;
          final actualizado = await SalidasController().editSalida(salida);
          if (!actualizado) {
            throw Exception(
                'Error al actualizar la salida ${salida.id_Salida}');
          }

          final producto = productosCache[salida.idProducto];
          if (producto != null) {
            final cantidad = salida.salida_Unidades ?? 0;
            producto.prodExistencia = (producto.prodExistencia ?? 0) + cantidad;
            Productos productoEditar = producto.toProductos();
            await _productosController.editProducto(productoEditar);

            if (!productosParaPDF.any((p) => p['id'] == salida.idProducto)) {
              productosParaPDF.add({
                'id': salida.idProducto,
                'descripcion':
                    producto.prodDescripcion ?? 'Producto desconocido',
                'cantidad': cantidad,
                'costo': salida.salida_Costo! / (salida.salida_Unidades ?? 1),
                'precio': salida.salida_Costo ?? 0,
              });
            }
          }
        }
      }

      if (productosParaPDF.isNotEmpty) {
        await generarPdfCancelacion(
          tipoMovimiento: 'CANCELACION_SALIDA',
          fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          motivo: _motivoController.text,
          folio: widget.salidas.first.salida_CodFolio ?? '',
          user: _currentUser!,
          almacen: widget.almacen.almacen_Nombre ?? '',
          junta: widget.junta.junta_Name ?? '',
          padron: widget.padron.padronNombre ?? '',
          usuarioAsignado: widget.userAsignado.user_Name ?? '',
          tipoTrabajo: widget.salidas.first.salida_TipoTrabajo ?? '',
          productos: productosParaPDF,
        );
      }

      await showOk(context, 'Salida cancelada exitosamente');
      Navigator.pop(context, true);

      final futureProductos = _loadProductos();
      setState(() {
        _productosFuture = futureProductos;
      });

      Navigator.pop(context);
    } catch (e) {
      showError(context, 'Error al procesar cancelación');
      print('Error al procesar cancelación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.salidas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de Salida'),
        ),
        body: const Center(
          child: Text('No hay datos de la salida'),
        ),
      );
    }

    final salidaPrincipal = widget.salidas.first;
    final tieneActivos = widget.salidas.any((s) => s.salida_Estado == true);
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    // Calcular totales
    final double totalUnidades = widget.salidas
        .fold(0, (sum, item) => sum + (item.salida_Unidades ?? 0));
    final double totalCosto =
        widget.salidas.fold(0, (sum, item) => sum + (item.salida_Costo ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Salida ${salidaPrincipal.salida_CodFolio}'),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.blue.shade700,
              ),
              onPressed: _imprimirSalida,
              tooltip: 'Reimprimir salida',
            ),
          ],
        ),
        actions: [
          // Botón para cancelar salida
          if ((isAdmin || isGestion) && tieneActivos)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red.shade700,
              ),
              onPressed: _cancelarTodaLaSalida,
              tooltip: 'Cancelar toda la salida',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Tarjeta #1: Datos Generales
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Datos Generales',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Folio:',
                                      salidaPrincipal.salida_CodFolio ?? ''),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('OST:',
                                      salidaPrincipal.salidaFolioOST ?? 'N/A'),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Fecha:',
                                      salidaPrincipal.salida_Fecha ?? ''),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Almacén:',
                                      widget.almacen.almacen_Nombre ?? ''),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Tipo trabajo:',
                                    salidaPrincipal.salida_TipoTrabajo ?? 'N/A',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Total Unidades:',
                                    totalUnidades.toString(),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Total Costo:',
                                    '\$${totalCosto.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Estado:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              salidaPrincipal.salida_Estado ==
                                                      true
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          salidaPrincipal.salida_Estado == true
                                              ? 'ACTIVA'
                                              : 'CANCELADA',
                                          style: TextStyle(
                                            color:
                                                salidaPrincipal.salida_Estado ==
                                                        true
                                                    ? Colors.green.shade800
                                                    : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Tarjeta #2: Datos Destino
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Datos Destino',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (salidaPrincipal.salida_PresupuestoFolio!
                                          .isNotEmpty &&
                                      salidaPrincipal.salida_PresupuestoFolio !=
                                          'N/A') ...[
                                    _buildInfoRow(
                                      'Folio Presupuesto:',
                                      '${salidaPrincipal.salida_PresupuestoFolio}',
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      const Text(
                                        'Junta:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                widget.junta.junta_Name ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (widget.userRole == "Admin" ||
                                                widget.userRole == "Gestion")
                                              const Icon(Icons.edit,
                                                  size: 16, color: Colors.blue),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'ID Padrón:',
                                    '${widget.padron.idPadron}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Nombre Padrón:',
                                    '${widget.padron.padronNombre}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Dirección Padrón:',
                                    '${widget.padron.padronDireccion}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Colonia:',
                                    '${widget.colonia.idColonia} - ${widget.colonia.nombreColonia}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Calle:',
                                    '${widget.calle.idCalle} - ${widget.calle.calleNombre}',
                                  ),
                                  if (widget.ordenServicio?.prioridadOS !=
                                      null) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      'Orden Trabajo:',
                                      '${widget.ordenServicio?.folioOS} - ${widget.ordenServicio?.prioridadOS}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Tarjeta #3: Datos Usuarios
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Datos Usuarios',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    'Creada por:',
                                    '${widget.userCreoSalida.id_User ?? 0} - ${widget.userCreoSalida.user_Name ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Asignada a:',
                                    '${widget.userAsignado.id_User} - ${widget.userAsignado.user_Name ?? ''}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Autoriza:',
                                    '${widget.userAutoriza.id_User ?? 0} - ${widget.userAutoriza.user_Name ?? 'No especificado'}',
                                  ),
                                  if (salidaPrincipal.idContratista != null &&
                                      widget.contratista != null) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      'Contratista:',
                                      '${widget.contratista?.idContratista ?? 'N/A'} - ${widget.contratista?.contratistaNombre ?? 'N/A'}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lista de productos de la salida
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos de la Salida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<Map<int, ProductosOptimizado>>(
                            future: _productosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.blue.shade900),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                      'Error al cargar productos: ${snapshot.error}',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                );
                              }

                              final productosCache = snapshot.data ?? {};
                              // Actualizamos la variable de instancia para que esté disponible en _buildProductoItem
                              this.productosCache = productosCache;

                              final Map<int, Map<String, dynamic>>
                                  groupProductos = {};

                              for (var salida in widget.salidas) {
                                groupProductos.update(
                                  salida.idProducto!,
                                  (value) => {
                                    'cantidad': value['cantidad'] +
                                        (salida.salida_Unidades ?? 0),
                                    'total': value['total'] +
                                        (salida.salida_Costo ?? 0),
                                    'salidas': [...value['salidas'], salida],
                                  },
                                  ifAbsent: () => {
                                    'cantidad': salida.salida_Unidades ?? 0,
                                    'total': salida.salida_Costo ?? 0,
                                    'salidas': [salida],
                                  },
                                );
                              }

                              return Column(
                                children: groupProductos.entries.map((entry) {
                                  final idProducto = entry.key;
                                  final cantidad = entry.value['cantidad'];
                                  final total = entry.value['total'];
                                  final producto = productosCache[idProducto];
                                  final salidasProducto =
                                      entry.value['salidas'];
                                  final tieneActivos = salidasProducto
                                      .any((s) => s.salida_Estado == true);

                                  return _buildProductoItem(
                                    idProducto,
                                    '${producto?.id_Producto ?? 0} - ${producto?.prodDescripcion ?? 'N/A'}',
                                    cantidad,
                                    total / cantidad,
                                    total,
                                    tieneActivos ? 'Activo' : 'Cancelado',
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          // Comentario al final de la lista de productos
                          if (salidaPrincipal.salida_Comentario != null &&
                              salidaPrincipal
                                  .salida_Comentario!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.comment,
                                          size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Comentarios:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueGrey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    salidaPrincipal.salida_Comentario!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta para documentos
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Documentos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Documento de Firmas
                              Expanded(
                                child: _buildDocumentoCard(
                                  'Documento con Firmas',
                                  widget.salidas.any((s) =>
                                      s.salida_DocumentoFirmas != null &&
                                      s.salida_DocumentoFirmas!.isNotEmpty),
                                  _subirDocumentoFirmas,
                                  _descargarDocumentoFirmas,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Documento de Pago
                              Expanded(
                                child: _buildDocumentoCard(
                                  'Documento de Pago',
                                  widget.salidas.any((s) =>
                                      s.salida_DocumentoPago != null &&
                                      s.salida_DocumentoPago!.isNotEmpty),
                                  _subirDocumentoPago,
                                  _descargarDocumentoPago,
                                ),
                              ),
                            ],
                          ),
                          if (_isUploadingDocument) ...[
                            const SizedBox(height: 16),
                            const LinearProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductoItem(
    int idProducto,
    String nombre,
    double cantidad,
    double precioUnitario,
    double total,
    String estado,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsProductoAuxiliar(
            idProducto: idProducto,
            nombreProducto: nombre,
            productosCache: productosCache,
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cantidad:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cantidad.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio Unitario:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${precioUnitario.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: estado == 'Activo'
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              estado,
              style: TextStyle(
                color: estado == 'Activo'
                    ? Colors.green.shade800
                    : Colors.red.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentoCard(
    String titulo,
    bool tieneDocumento,
    VoidCallback onSubir,
    VoidCallback onDescargar,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Icon(
              tieneDocumento ? Icons.check_circle : Icons.pending,
              color: tieneDocumento ? Colors.green : Colors.orange,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              tieneDocumento ? 'Documento subido' : 'Pendiente de subir',
              style: TextStyle(
                color: tieneDocumento ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSubir,
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tieneDocumento ? onDescargar : null,
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tieneDocumento
                          ? Colors.green.shade800
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
