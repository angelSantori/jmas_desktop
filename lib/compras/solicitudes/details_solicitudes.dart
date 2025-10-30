import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_autorizaciones_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_compras_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_validaciones_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/compras/solicitudes/widgets/dialog/autorizacion_dialog.dart';
import 'package:jmas_desktop/compras/solicitudes/widgets/dialog/validacion_dialog.dart';
import 'package:jmas_desktop/compras/solicitudes/widgets/pdf_solicitud_compra.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class DetailsSolicitudPage extends StatefulWidget {
  final String userRole;
  final String idUser;
  final List<SolicitudCompras> solicitudes;
  final Users userSolicita;
  final Users? userValida;
  final Users? userAutoriza;
  final String user;

  const DetailsSolicitudPage({
    super.key,
    required this.solicitudes,
    required this.user,
    required this.userSolicita,
    required this.userRole,
    this.userValida,
    this.userAutoriza,
    required this.idUser,
  });

  @override
  State<DetailsSolicitudPage> createState() => _DetailsSolicitudPageState();
}

class _DetailsSolicitudPageState extends State<DetailsSolicitudPage> {
  final ProductosController _productosController = ProductosController();
  final SolicitudComprasController _solicitudController =
      SolicitudComprasController();
  final SolicitudValidacionesController _validacionesController =
      SolicitudValidacionesController();
  final SolicitudAutorizacionesController _autorizacionesController =
      SolicitudAutorizacionesController();

  late Future<Map<int, Productos>> _productosFuture;
  late Future<List<SolicitudValidaciones>> _validacionesFuture;
  late Future<List<SolicitudAutorizaciones>> _autorizacinoesFuture;

  bool _isLoading = false;

  double get _totalGeneral {
    return widget.solicitudes
        .fold(0.0, (sum, solicitud) => sum + solicitud.scTotalCostoProductos);
  }

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProductos();
    _validacionesFuture = _loadValidaciones();
    _autorizacinoesFuture = _loadAutorizaciones();
  }

  Future<Map<int, Productos>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      return {for (var prod in productos) prod.id_Producto!: prod};
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  Future<List<SolicitudValidaciones>> _loadValidaciones() async {
    try {
      if (widget.solicitudes.isNotEmpty) {
        return await _validacionesController
            .getSolicitudValidacionByFolio(widget.solicitudes.first.scFolio);
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar validaciones: $e');
    }
  }

  Future<List<SolicitudAutorizaciones>> _loadAutorizaciones() async {
    try {
      if (widget.solicitudes.isNotEmpty) {
        return await _autorizacionesController
            .getSolicitudAutorizacionByFolio(widget.solicitudes.first.scFolio);
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar autorizaciones: $e');
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'atendido':
        return Colors.orange.shade100;
      case 'cancelado':
        return Colors.green.shade100;
      case 'rechazada':
        return Colors.red.shade100;
      case 'tramite':
        return Colors.blue.shade100;
      case 'validada':
        return Colors.green.shade100;
      case 'autorizada':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> _validarSolicitud() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ValidacionDialog(
        idUser: widget.idUser,
        folio: widget.solicitudes.first.scFolio,
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      // Recargar todos los datos
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        // Recargar las solicitudes actualizadas
        final solicitudesActualizadas = await _solicitudController
            .getSolicitudComprasByFolio(widget.solicitudes.first.scFolio);

        // Recargar validaciones
        final validacionesActualizadas = await _validacionesController
            .getSolicitudValidacionByFolio(widget.solicitudes.first.scFolio);

        if (mounted) {
          setState(() {
            widget.solicitudes.clear();
            widget.solicitudes.addAll(solicitudesActualizadas);
            _validacionesFuture = Future.value(validacionesActualizadas);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showError(context, 'Error al actualizar datos');
          print('Error _validarSolicitud | DetailsSolicitudPage: $e');
        }
      }
    }
  }

  Future<void> _autorizarSolicitud() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AutorizacionDialog(
        idUser: widget.idUser,
        folio: widget.solicitudes.first.scFolio,
      ),
    );
    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final solicitudesActualizadas = await _solicitudController
            .getSolicitudComprasByFolio(widget.solicitudes.first.scFolio);

        final autorizacionesActualizadas = await _autorizacionesController
            .getSolicitudAutorizacionByFolio(widget.solicitudes.first.scFolio);

        if (mounted) {
          setState(() {
            widget.solicitudes.clear();
            widget.solicitudes.addAll(solicitudesActualizadas);
            _autorizacinoesFuture = Future.value(autorizacionesActualizadas);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showError(context, 'Error al actualizar datos');
          print('Error _autorizarSolicitud | DetailsSolicitudPage: $e');
        }
      }
    }
  }

  bool _puedeValidar() {
    final solicitudPrincipal = widget.solicitudes.first;
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return (isAdmin || isGestion) &&
        solicitudPrincipal.scEstado.toLowerCase() == 'tramite' &&
        solicitudPrincipal.idUserValida == null;
  }

  bool _puedeAutorizar() {
    final solicitudPrincipal = widget.solicitudes.first;
    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

    return (isAdmin || isGestion) &&
        solicitudPrincipal.scEstado.toLowerCase() == 'validada' &&
        solicitudPrincipal.idUserAutoriza == null;
  }

  bool _puedeDescargarPDF() {
    final solicitudPrincipal = widget.solicitudes.first;
    return solicitudPrincipal.scEstado.toLowerCase() == 'autorizada';
  }

  Future<void> _descargarPDFSolicitud() async {
    if (widget.solicitudes.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final solicitudPrincipal = widget.solicitudes.first;
      final productosCache = await _productosFuture;

      // Preparar datos de los productos
      final productosAgrupados = <int, List<SolicitudCompras>>{};
      for (var solicitud in widget.solicitudes) {
        productosAgrupados.update(
          solicitud.idProducto,
          (value) => [...value, solicitud],
          ifAbsent: () => [solicitud],
        );
      }

      final productosParaPDF = productosAgrupados.entries.map((entry) {
        final idProducto = entry.key;
        final solicitudesProducto = entry.value;
        final producto = productosCache[idProducto];
        final cantidadTotal = solicitudesProducto.length;
        final costoUnitario = solicitudesProducto.first.scTotalCostoProductos /
            solicitudesProducto.first.scCantidadProductos;
        final costoTotal = solicitudesProducto.fold(
            0.0, (sum, solicitud) => sum + solicitud.scTotalCostoProductos);

        return {
          'idProducto': idProducto,
          'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
          'cantidad': cantidadTotal,
          'unidadMedida': producto?.prodUMedEntrada ?? '',
          'costoUnitario': costoUnitario,
          'total': costoTotal,
        };
      }).toList();

      // Obtener información de usuarios
      final usersController = UsersController();
      final usuarioSolicita =
          await usersController.getUserById(solicitudPrincipal.idUserSolicita);
      final usuarioValida = solicitudPrincipal.idUserValida != null
          ? await usersController.getUserById(solicitudPrincipal.idUserValida!)
          : null;
      final usuarioAutoriza = solicitudPrincipal.idUserAutoriza != null
          ? await usersController
              .getUserById(solicitudPrincipal.idUserAutoriza!)
          : null;

      // Generar PDF
      await PdfSolicitudCompra.generarPdfSolicitudCompra(
        context: context,
        folio: solicitudPrincipal.scFolio,
        objetivo: solicitudPrincipal.scObjetivo,
        especificaciones: solicitudPrincipal.scEspecificaciones,
        observaciones: solicitudPrincipal.scObservaciones,
        fechaSolicitud: solicitudPrincipal.scFecha,
        usuarioSolicita:
            '${usuarioSolicita?.id_User ?? 'N/A'} - ${usuarioSolicita?.user_Name ?? 'N/A'}',
        usuarioValida: usuarioValida != null
            ? '${usuarioValida.id_User} - ${usuarioValida.user_Name}'
            : 'N/A',
        usuarioAutoriza: usuarioAutoriza != null
            ? '${usuarioAutoriza.id_User} - ${usuarioAutoriza.user_Name}'
            : 'N/A',
        idUserCaptura: widget.idUser,
        nombreUserCaptura: widget.user,
        productos: productosParaPDF,
      );

      if (mounted) {
        showOk(context, 'PDF de solicitud descargado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        showError(context, 'Error al generar el PDF: $e');
        print('Error _descargarPDFSolicitud | DetailsSolicitudPage: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solicitudes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles de Solicitud')),
        body: const Center(child: Text('No hay datos de la solicitud')),
      );
    }

    final solicitudPrincipal = widget.solicitudes.first;
    final puedeValidar = _puedeValidar();
    final puedeAutorizar = _puedeAutorizar();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Solicitud ${solicitudPrincipal.scFolio}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getEstadoColor(solicitudPrincipal.scEstado),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjetas superiores con información general
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Tarjeta #1: Datos Generales
                        Expanded(
                          child: Card(
                            elevation: 4,
                            color: _getEstadoColor(solicitudPrincipal.scEstado),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Datos Generales',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    'Solicitado por:',
                                    '${widget.userSolicita.id_User ?? 0} - ${widget.userSolicita.user_Name ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      'Folio:', solicitudPrincipal.scFolio),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    'Fecha:',
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(solicitudPrincipal.scFecha),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Estado:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getEstadoColor(
                                              solicitudPrincipal.scEstado),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                        ),
                                        child: Text(
                                          solicitudPrincipal.scEstado
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Botón PDF
                                  if (_puedeDescargarPDF()) ...[
                                    const SizedBox(height: 12),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading
                                            ? null
                                            : _descargarPDFSolicitud,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        icon: _isLoading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.picture_as_pdf,
                                                color: Colors.white),
                                        label: Text(
                                          _isLoading
                                              ? 'Generando PDF...'
                                              : 'Descargar PDF de Solicitud',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Tarjeta #2: Información de la Solicitud
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Información de la Solicitud',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Objetivo:',
                                      solicitudPrincipal.scObjetivo),
                                  const SizedBox(height: 8),
                                  if (solicitudPrincipal
                                      .scEspecificaciones.isNotEmpty)
                                    _buildInfoRow('Especificaciones:',
                                        solicitudPrincipal.scEspecificaciones),
                                  if (solicitudPrincipal
                                      .scEspecificaciones.isNotEmpty)
                                    const SizedBox(height: 8),
                                  if (solicitudPrincipal
                                      .scObservaciones.isNotEmpty)
                                    _buildInfoRow('Observaciones:',
                                        solicitudPrincipal.scObservaciones),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Tarjeta #3: Validación - OCUPA TODA LA CARD
                        Expanded(
                          child: FutureBuilder<List<SolicitudValidaciones>>(
                            future: _validacionesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Card(
                                  elevation: 4,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.blue.shade900),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 40),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Error al cargar validación',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                // Si existe validación, mostrar información
                                final validacion = snapshot.data!.first;
                                return _buildValidacionCardCompact(validacion);
                              } else {
                                // Si no existe validación y puede validar, mostrar botón que ocupa toda la card
                                if (puedeValidar) {
                                  return Card(
                                    elevation: 4,
                                    child: InkWell(
                                      onTap: _validarSolicitud,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.fact_check,
                                              color: Colors.blue.shade900,
                                              size: 58,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Validar Solicitud',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Presione aquí para validar esta solicitud',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Si no puede validar y no hay validación, mostrar card vacía o informativa
                                  return Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.pending_actions,
                                              color: Colors.grey.shade400,
                                              size: 40),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Pendiente de validación',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Tarjeta #4: Autorización - OCUPA TODA LA CARD
                        Expanded(
                          child: FutureBuilder<List<SolicitudAutorizaciones>>(
                            future: _autorizacinoesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Card(
                                  elevation: 4,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.blue.shade900),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 40),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Error al cargar autorizaciones',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                final autorizacion = snapshot.data!.first;
                                return _buildAutorizacionCardCompact(
                                    autorizacion);
                              } else {
                                if (puedeAutorizar) {
                                  return Card(
                                    elevation: 4,
                                    child: InkWell(
                                      onTap: _autorizarSolicitud,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.price_check_rounded,
                                              color: Colors.blue.shade900,
                                              size: 58,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Autorizar Solicitud',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Presione aquí para autorizar esta solicitud',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Si no puede validar y no hay validación, mostrar card vacía o informativa
                                  return Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.pending_actions,
                                              color: Colors.grey.shade400,
                                              size: 58),
                                          const SizedBox(height: 8),
                                          Text(
                                            solicitudPrincipal.scEstado ==
                                                    'Rechazada'
                                                ? 'Validación rechazada'
                                                : 'Pendiente de validación',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lista de productos de la solicitud
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos Solicitados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<Map<int, Productos>>(
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
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final productosCache = snapshot.data ?? {};
                              final productosAgrupados =
                                  <int, List<SolicitudCompras>>{};

                              // Agrupar productos por ID
                              for (var solicitud in widget.solicitudes) {
                                productosAgrupados.update(
                                  solicitud.idProducto,
                                  (value) => [...value, solicitud],
                                  ifAbsent: () => [solicitud],
                                );
                              }

                              return Column(
                                children:
                                    productosAgrupados.entries.map((entry) {
                                  final idProducto = entry.key;
                                  final solicitudesProducto = entry.value;
                                  final producto = productosCache[idProducto];
                                  final cantidadTotal =
                                      solicitudesProducto.length;
                                  final costoUnitario = solicitudesProducto
                                          .first.scTotalCostoProductos /
                                      solicitudesProducto
                                          .first.scCantidadProductos;
                                  final costoTotal = solicitudesProducto.fold(
                                      0.0,
                                      (sum, solicitud) =>
                                          sum +
                                          solicitud.scTotalCostoProductos);

                                  return _buildProductoItem(
                                    idProducto,
                                    '${producto?.id_Producto ?? 0} - ${producto?.prodDescripcion ?? 'Producto desconocido'}',
                                    cantidadTotal,
                                    producto?.prodUMedEntrada ?? '',
                                    costoUnitario,
                                    costoTotal,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          // Total General
                          const SizedBox(height: 20),
                          Card(
                            elevation: 4,
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total General:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${_totalGeneral.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
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

  // Versión compacta de la tarjeta de validación para la tercera card
  Widget _buildValidacionCardCompact(SolicitudValidaciones validacion) {
    return Card(
      elevation: 4,
      color: _getEstadoColor(validacion.svEstado),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Estado:', validacion.svEstado),
            const SizedBox(height: 6),
            _buildInfoRow('Fecha:',
                DateFormat('dd/MM/yyyy HH:mm').format(validacion.svFecha)),
            const SizedBox(height: 6),
            if (validacion.svComentario.isNotEmpty)
              _buildInfoRow('Comentario:', validacion.svComentario),
            if (validacion.svComentario.isNotEmpty) const SizedBox(height: 6),
            _buildInfoRow('Validado por:', '${validacion.idUserValida}'),
          ],
        ),
      ),
    );
  }

  // Versión compacta de la tarjeta de validación para la tercera card
  Widget _buildAutorizacionCardCompact(SolicitudAutorizaciones autorizacion) {
    return Card(
      elevation: 4,
      color: _getEstadoColor(autorizacion.saEstado),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Autorización',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Estado:', autorizacion.saEstado),
            const SizedBox(height: 6),
            _buildInfoRow('Fecha:',
                DateFormat('dd/MM/yyyy HH:mm').format(autorizacion.saFecha)),
            const SizedBox(height: 6),
            if (autorizacion.saComentario.isNotEmpty)
              _buildInfoRow('Comentario:', autorizacion.saComentario),
            if (autorizacion.saComentario.isNotEmpty) const SizedBox(height: 6),
            _buildInfoRow('Validado por:', '${autorizacion.idUserAutoriza}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoItem(
    int idProducto,
    String nombre,
    int cantidad,
    String unidadMedida,
    double costoUnitario,
    double costoTotal,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Icono del producto
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip('Cantidad: $cantidad', Icons.numbers),
                    const SizedBox(width: 8),
                    _buildInfoChip('UM: $unidadMedida', Icons.scale),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                        'Costo Unitario: \$${costoUnitario.toStringAsFixed(2)}',
                        Icons.attach_money),
                    const SizedBox(width: 8),
                    _buildInfoChip('Total: \$${costoTotal.toStringAsFixed(2)}',
                        Icons.money),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
