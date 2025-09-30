import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
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
  Map<int, Productos>? productosCache;
  bool _isUploadingDocument = false;
  // ignore: unused_field
  Uint8List? _documentoFirmas;
  // ignore: unused_field
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
            salida.salida_DocumentoFirmas =
                "documento_subido"; // O el valor que uses para indicar que hay documento
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

        // Guardar el documento localmente
        final result = await FileSaver.instance.saveFile(
          name: 'documento_firmas_${widget.salidas.first.salida_CodFolio}.pdf',
          bytes: documento,
          customMimeType: 'pdf',
        );

        // ignore: unnecessary_null_comparison
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

        //  Guardar el documento localmente
        final result = await FileSaver.instance.saveFile(
          name: 'documento_pago_${widget.salidas.first.salida_CodFolio}.pdf',
          bytes: documento,
          customMimeType: 'pdf',
        );

        // ignore: unnecessary_null_comparison
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

      // Agrupar salidas por producto para el PDF
      final Map<int, List<Salidas>> salidasPorProducto = {};
      for (var salida in widget.salidas) {
        salidasPorProducto.update(
          salida.idProducto!,
          (value) => [...value, salida],
          ifAbsent: () => [salida],
        );
      }

      // Preparar datos para el PDF
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
          // AÑADIR ESTOS CAMPOS CRUCIALES:
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
        mostrarEstado: true, // Mostrar columna de estado
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
      // Preparar datos para el PDF
      final List<Map<String, dynamic>> productosParaPDF = [];
      final productosCache = await _productosFuture;

      // Procesar cada salida individual
      for (var salida in widget.salidas) {
        if (salida.salida_Estado == true) {
          // 1. Registrar cancelación para esta salida
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

          // 2. Actualizar la salida original
          salida.salida_Estado = false;
          final actualizado = await SalidasController().editSalida(salida);
          if (!actualizado) {
            throw Exception(
                'Error al actualizar la salida ${salida.id_Salida}');
          }

          // 3. Actualizar existencias del producto
          final producto = productosCache[salida.idProducto];
          if (producto != null) {
            final cantidad = salida.salida_Unidades ?? 0;
            producto.prodExistencia = (producto.prodExistencia ?? 0) + cantidad;
            Productos productoEditar = producto.toProductos();
            await _productosController.editProducto(productoEditar);

            // Agregar al PDF si no está ya incluido
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

      // 4. Generar PDF cancelación si hay productos
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

      // 5. Mostrar mensaje de éxito
      await showOk(context, 'Salida cancelada exitosamente');
      Navigator.pop(context, true);

      // Recargar datos
      final futureProductos = _loadProductos();
      setState(() {
        _productosFuture = futureProductos;
      });

      // Cerrar la pantalla después de la cancelación exitosa
      Navigator.pop(context);
    } catch (e) {
      showError(context, 'Error al procesar cancelación');
      print('Error al procesar cancelación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editarJuntaSalida() async {
    final juntasController = JuntasController();
    final todasJuntas = await juntasController.listJuntas();

    Juntas? juntaSeleccionada = widget.junta;

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Junta de Salida'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Seleccione la nueva junta destino:'),
                const SizedBox(height: 20),
                DropdownButtonFormField<Juntas>(
                  value: juntaSeleccionada,
                  items: todasJuntas.map((junta) {
                    return DropdownMenuItem<Juntas>(
                      value: junta,
                      child: Text('${junta.junta_Name} (${junta.id_Junta})'),
                    );
                  }).toList(),
                  onChanged: (junta) {
                    setState(() {
                      juntaSeleccionada = junta;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Junta Destino',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (juntaSeleccionada != null) {
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

    if (confirmacion != true || juntaSeleccionada == null) return;

    setState(() => _isLoading = true);

    try {
      // Actualizar todas las salidas asociadas al mismo folio
      bool todasActualizadas = true;
      for (var salida in widget.salidas) {
        // Crear una copia de la salida con la nueva junta
        final salidaActualizada = salida.copyWith(
          id_Junta: juntaSeleccionada!.id_Junta,
        );

        // Usar el método editSalida existente
        final success = await SalidasController().editSalida(salidaActualizada);

        if (!success) {
          todasActualizadas = false;
          break;
        }
      }

      if (todasActualizadas) {
        // Generar PDF de modificación (similar al de cancelación)
        final productosCache = await _productosFuture;
        final productosParaPDF = <Map<String, dynamic>>[];

        for (var salida in widget.salidas) {
          final producto = productosCache[salida.idProducto];
          if (producto != null) {
            productosParaPDF.add({
              'id': salida.idProducto,
              'descripcion': producto.prodDescripcion ?? 'Producto desconocido',
              'cantidad': salida.salida_Unidades ?? 0,
              'costo': salida.salida_Costo! / (salida.salida_Unidades ?? 1),
              'precio': salida.salida_Costo ?? 0,
            });
          }
        }

        await generarPdfSalida(
          movimiento: 'MODIFICACION SALIDA',
          fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          folio: widget.salidas.first.salida_CodFolio ?? '',
          userName: _currentUser?.user_Name ?? '',
          idUser: _currentUser!.id_User.toString(),
          alamcenA: widget.almacen,
          userAsignado: widget.userAsignado,
          tipoTrabajo: widget.salidas.first.salida_TipoTrabajo ?? '',
          padron: widget.padron,
          colonia: widget.colonia,
          userAutoriza: widget.userAutoriza,
          calle: widget.calle,
          junta: juntaSeleccionada!,
          productos: productosParaPDF,
        );

        // Mostrar mensaje de éxito
        await showOk(context, 'Junta actualizada exitosamente');

        // Cerrar la pantalla actual para forzar recarga
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al actualizar algunas salidas');
      }
    } catch (e) {
      showError(context, 'Error al actualizar junta: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> groupProductos = {};
    final Map<int, List<Salidas>> salidasPorProducto = {};
    final tieneActivos = widget.salidas.any((s) => s.salida_Estado == true);

    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    for (var salida in widget.salidas) {
      // Agrupar por producto para mostrar en tabla
      groupProductos.update(
        salida.idProducto!,
        (value) => {
          'cantidad': value['cantidad'] + (salida.salida_Unidades ?? 0),
          'total': value['total'] + (salida.salida_Costo ?? 0),
          'salidas': [...value['salidas'], salida],
        },
        ifAbsent: () => {
          'cantidad': salida.salida_Unidades ?? 0,
          'total': salida.salida_Costo ?? 0,
          'salidas': [salida],
        },
      );

      // Mapear todas las salidas por producto
      salidasPorProducto.update(
        salida.idProducto!,
        (value) => [...value, salida],
        ifAbsent: () => [salida],
      );
    }

    // ... código anterior ...

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de salida: ${widget.salidas.first.salida_CodFolio}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900))
          : SingleChildScrollView(
              // Cambio principal: Scroll en toda la página
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 4,
                    color: widget.salidas.first.salida_Estado == false
                        ? const Color.fromARGB(188, 255, 205, 210)
                        : Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(20), // Reducir margen
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // Importante
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if ((isAdmin || isGestion) && tieneActivos) ...[
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red.shade800),
                                    onPressed: _cancelarTodaLaSalida,
                                    tooltip: 'Cancelar toda la salida',
                                  ),
                                ],
                                IconButton(
                                  icon: Icon(Icons.print,
                                      color: Colors.blue.shade800),
                                  onPressed: _imprimirSalida,
                                  tooltip: 'Reimprimir salida',
                                ),
                              ]),
                          const SizedBox(height: 15),
                          const Divider(),

                          //Columnas de información
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Almacen: ${widget.almacen.almacen_Nombre}'),
                                      Row(
                                        children: [
                                          const Text('Junta: '),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.userRole == "Admin") {
                                                _editarJuntaSalida();
                                              }
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  widget.junta.junta_Name ?? '',
                                                  style: TextStyle(
                                                    color: (widget.userRole ==
                                                                "Admin" ||
                                                            widget.userRole ==
                                                                "Gestion")
                                                        ? Colors.blue.shade800
                                                        : Colors.black,
                                                    decoration: (widget
                                                                    .userRole ==
                                                                "Admin" ||
                                                            widget.userRole ==
                                                                "Gestion")
                                                        ? TextDecoration
                                                            .underline
                                                        : null,
                                                  ),
                                                ),
                                                if (widget.userRole ==
                                                        "Admin" ||
                                                    widget.userRole ==
                                                        "Gestion")
                                                  const Icon(Icons.edit,
                                                      size: 16,
                                                      color: Colors.blue),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                          'Padron: ${widget.padron.idPadron} - ${widget.padron.padronNombre}'),
                                      if (widget.ordenServicio?.prioridadOS !=
                                          null) ...[
                                        Text(
                                            'Orden Trabajo: ${widget.ordenServicio?.folioOS} - ${widget.ordenServicio?.prioridadOS}'),
                                      ]
                                    ],
                                  ),
                                ),
                              ),

                              //Columna 2
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Colonia: ${widget.colonia.idColonia} - ${widget.colonia.nombreColonia}'),
                                      Text(
                                          'Calle: ${widget.calle.idCalle} - ${widget.calle.calleNombre}'),
                                      Text('Realizado por: ${widget.user}'),
                                    ],
                                  ),
                                ),
                              ),

                              //Columna 3
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Asignado a: ${widget.userAsignado.user_Name}'),
                                      Text(
                                          'Tipo trabajo: ${widget.salidas.first.salida_TipoTrabajo ?? 'N/A'}'),
                                      Text(
                                          'Fecha: ${widget.salidas.first.salida_Fecha}'),
                                      Text(
                                          'Autoriza: ${widget.userAutoriza.user_Name ?? 'No especificado'}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),

                          //  Tabla - SIN altura fija
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

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 20,
                                  dataRowMinHeight: 40,
                                  dataRowMaxHeight: 40,
                                  headingRowHeight: 40,
                                  columns: const [
                                    DataColumn(
                                        label: Text(
                                      'Id Producto',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Nombre',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Cantidad',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Precio unitario',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Total (\$)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Estado',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ],
                                  rows: groupProductos.entries.map((entry) {
                                    final idProducto = entry.key;
                                    final cantidad = entry.value['cantidad'];
                                    final total = entry.value['total'];
                                    final nombreProducto =
                                        productosCache[idProducto]
                                                ?.prodDescripcion ??
                                            'Desconocido';
                                    final salidasProducto =
                                        salidasPorProducto[idProducto] ?? [];
                                    final tieneActivos = salidasProducto
                                        .any((s) => s.salida_Estado == true);

                                    return DataRow(cells: [
                                      DataCell(Text(
                                        idProducto.toString(),
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                      DataCell(Text(
                                        nombreProducto,
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                      DataCell(Text(
                                        cantidad.toString(),
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                      DataCell(Text(
                                        '\$${(total / cantidad).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                      DataCell(Text(
                                        '\$${total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                      DataCell(Text(
                                          tieneActivos ? 'Activo' : 'Cancelado',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: tieneActivos
                                                  ? Colors.green
                                                  : Colors.red))),
                                    ]);
                                  }).toList(),
                                ),
                              );
                            },
                          ),

                          //  Comentario
                          if (widget.salidas.first.salida_Comentario != null &&
                              widget.salidas.first.salida_Comentario!
                                  .isNotEmpty) ...[
                            const SizedBox(height: 30),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
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
                                    widget.salidas.first.salida_Comentario!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          //  Doc Firmas
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Documento con Firmas',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                      if (widget.salidas.any((s) =>
                                          s.salida_DocumentoFirmas != null &&
                                          s.salida_DocumentoFirmas!
                                              .isNotEmpty)) ...[
                                        Row(
                                          children: [
                                            const Icon(Icons.description,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            const Text('Documento disponible'),
                                            IconButton(
                                              icon: const Icon(Icons.download,
                                                  color: Colors.green),
                                              onPressed:
                                                  _descargarDocumentoFirmas,
                                              tooltip: 'Descargar documento',
                                            ),
                                          ],
                                        )
                                      ] else ...[
                                        const Text('No hay documento subido'),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: _subirDocumentoFirmas,
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text(
                                              'Subir documento con firmas'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                      if (_isUploadingDocument) ...[
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: LinearProgressIndicator(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),

                              //  Doc Pago
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Documento de Pago',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                      if (widget.salidas.any((s) =>
                                          s.salida_DocumentoPago != null &&
                                          s.salida_DocumentoPago!
                                              .isNotEmpty)) ...[
                                        Row(
                                          children: [
                                            const Icon(Icons.description,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            const Text('Documento disponible'),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.download,
                                                color: Colors.green,
                                              ),
                                              onPressed:
                                                  _descargarDocumentoPago,
                                              tooltip: 'Descargar documento',
                                            )
                                          ],
                                        )
                                      ] else ...[
                                        const Text('No hay documento subido'),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: _subirDocumentoPago,
                                          icon: const Icon(
                                            Icons.upload_file,
                                          ),
                                          label: const Text(
                                              'Subir documento de pago'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            foregroundColor: Colors.white,
                                          ),
                                        )
                                      ],
                                      if (_isUploadingDocument) ...[
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: LinearProgressIndicator(),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
