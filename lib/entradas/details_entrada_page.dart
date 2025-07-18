import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_cancelacion.dart';
import '../widgets/reimpresion_entraada_pdf.dart' show ReimpresionEntradaPdf;

class DetailsEntradaPage extends StatefulWidget {
  final String userRole;
  final List<Entradas> entradas;
  final Proveedores proveedor;
  final Almacenes almacen;
  final Juntas junta;
  final String user;

  const DetailsEntradaPage({
    super.key,
    required this.entradas,
    required this.proveedor,
    required this.almacen,
    required this.user,
    required this.junta,
    required this.userRole,
  });

  @override
  State<DetailsEntradaPage> createState() => _DetailsEntradaPageState();
}

class _DetailsEntradaPageState extends State<DetailsEntradaPage> {
  final ProductosController _productosController = ProductosController();
  final CanceladoController _canceladoController = CanceladoController();
  final AuthService _authService = AuthService();
  final UsersController _usersController = UsersController();
  late Future<Map<int, Productos>> _productosFuture;

  String? _currentUserId;
  Users? _currentUser;
  bool _isLoading = false;
  final TextEditingController _motivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProductos();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
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

  Future<void> _descargarFactura() async {
    try {
      // Buscar la primera entrada con imagen
      final entradaConImagen = widget.entradas.firstWhere(
        (e) =>
            e.entrada_ImgB64Factura != null &&
            e.entrada_ImgB64Factura!.isNotEmpty,
        orElse: () => Entradas(),
      );

      if (entradaConImagen.id_Entradas == null) {
        showError(context, 'No hay factura disponible para descargar');
        return;
      }

      setState(() => _isLoading = true);

      // Decodificar base64
      final bytes = base64.decode(entradaConImagen.entrada_ImgB64Factura!);

      // Crear un blob y descargar
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            'download', 'Factura_${entradaConImagen.entrada_CodFolio}.pdf')
        ..click();

      // Liberar el objeto URL
      html.Url.revokeObjectUrl(url);

      showOk(context, 'Descarga de factura iniciada');
    } catch (e) {
      showError(context, 'Error al descargar la factura: $e');
      debugPrint('Error al descargar factura: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<int, Productos>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      return {for (var prod in productos) prod.id_Producto!: prod};
    } catch (e) {
      throw Exception('Error al cargar productos: $e');
    }
  }

  Future<void> _cancelarTodaLaEntrada() async {
    final formKey = GlobalKey<FormState>();
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar toda la entrada'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Está seguro que desea cancelar toda esta entrada?'),
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

      // Procesar cada entrada individual
      for (var entrada in widget.entradas) {
        if (entrada.entrada_Estado == true) {
          // 1. Registrar cancelación para esta entrada
          final cancelacion = Cancelados(
            idCancelacion: 0,
            cancelMotivo: _motivoController.text,
            cancelFecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
            id_Entrada: entrada.id_Entradas,
            id_User: int.parse(_currentUserId!),
          );

          final cancelacionExitosa =
              await _canceladoController.addCancelacion(cancelacion);
          if (!cancelacionExitosa) {
            throw Exception(
                'Error al registrar la cancelación para entrada ${entrada.id_Entradas}');
          }

          // 2. Actualizar la entrada original
          entrada.entrada_Estado = false;
          final actualizado = await EntradasController().editEntrada(entrada);
          if (!actualizado) {
            throw Exception(
                'Error al actualizar la entrada ${entrada.id_Entradas}');
          }

          // 3. Actualizar existencias del producto
          final producto = productosCache[entrada.idProducto];
          if (producto != null) {
            final cantidad = entrada.entrada_Unidades ?? 0;
            producto.prodExistencia = (producto.prodExistencia ?? 0) - cantidad;
            await _productosController.editProducto(producto);

            // Agregar al PDF si no está ya incluido
            if (!productosParaPDF.any((p) => p['id'] == entrada.idProducto)) {
              productosParaPDF.add({
                'id': entrada.idProducto,
                'descripcion':
                    producto.prodDescripcion ?? 'Producto desconocido',
                'cantidad': cantidad,
                'costo':
                    entrada.entrada_Costo! / (entrada.entrada_Unidades ?? 1),
                'precio': entrada.entrada_Costo ?? 0,
              });
            }
          }
        }
      }

      // 4. Generar PDF cancelación si hay productos
      if (productosParaPDF.isNotEmpty) {
        await generarPdfCancelacion(
          tipoMovimiento: 'CANCELACION_ENTRADA',
          fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          motivo: _motivoController.text,
          folio: widget.entradas.first.entrada_CodFolio ?? '',
          referencia: widget.entradas.first.entrada_Referencia ?? '',
          user: _currentUser!,
          almacen: widget.almacen.almacen_Nombre ?? '',
          proveedor: widget.proveedor.proveedor_Name ?? '',
          junta: widget.junta.junta_Name ?? '',
          productos: productosParaPDF,
        );
      }

      // 5. Mostrar mensaje de éxito
      await showOk(context, 'Entrada cancelada exitosamente');

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

  Future<void> _imprimirEntrada() async {
    setState(() => _isLoading = true);
    try {
      final productosCache = await _productosFuture;
      final productosParaPDF = <Map<String, dynamic>>[];

      // Agrupar entradas por producto para el PDF
      final Map<int, List<Entradas>> entradasPorProducto = {};
      for (var entrada in widget.entradas) {
        entradasPorProducto.update(
          entrada.idProducto!,
          (value) => [...value, entrada],
          ifAbsent: () => [entrada],
        );
      }

      // Preparar datos para el PDF
      for (var entry in entradasPorProducto.entries) {
        final producto = productosCache[entry.key];
        final cantidad = entry.value.fold<double>(
            0, (sum, entrada) => sum + (entrada.entrada_Unidades ?? 0));
        final total = entry.value.fold<double>(
            0.0, (sum, entrada) => sum + (entrada.entrada_Costo ?? 0.0));
        final tieneActivos = entry.value.any((e) => e.entrada_Estado == true);

        productosParaPDF.add({
          'id': entry.key,
          'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
          'cantidad': cantidad,
          'costo': total / cantidad,
          'precio': total,
          'estado': tieneActivos ? 'Activo' : 'Cancelado',
        });
      }

      await ReimpresionEntradaPdf.generateAndPrintPdfEntrada(
        movimiento: 'ENTRADA',
        fecha: widget.entradas.first.entrada_Fecha ?? '',
        folio: widget.entradas.first.entrada_CodFolio ?? '',
        referencia: widget.entradas.first.entrada_Referencia ?? '',
        userName: widget.user,
        idUser: _currentUserId ?? '0',
        almacen: widget.almacen,
        proveedor: widget.proveedor,
        junta: widget.junta,
        productos: productosParaPDF,
        mostrarEstado: true,
      );
    } catch (e) {
      showError(context, 'Error al generar PDF: $e');
      debugPrint('Error al generar PDF: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> groupProductos = {};
    final Map<int, List<Entradas>> entradasPorProducto = {};

    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";
    final tieneActivos = widget.entradas.any((e) => e.entrada_Estado == true);

    for (var entrada in widget.entradas) {
      // Agrupar por producto para mostrar en tabla
      groupProductos.update(
        entrada.idProducto!,
        (value) => {
          'cantidad': value['cantidad'] + entrada.entrada_Unidades,
          'total': value['total'] + entrada.entrada_Costo,
          'entradas': [...value['entradas'], entrada],
        },
        ifAbsent: () => {
          'cantidad': entrada.entrada_Unidades,
          'total': entrada.entrada_Costo,
          'entradas': [entrada],
        },
      );

      // Mapear todas las entradas por producto
      entradasPorProducto.update(
        entrada.idProducto!,
        (value) => [...value, entrada],
        ifAbsent: () => [entrada],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de entrada: ${widget.entradas.first.entrada_CodFolio}',
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
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  color: const Color.fromARGB(255, 201, 230, 242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(100),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Referencia: ${widget.entradas.first.entrada_Referencia}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if ((isAdmin || isGestion) && tieneActivos) ...[
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red.shade800),
                                onPressed: _cancelarTodaLaEntrada,
                                tooltip: 'Cancelar toda la entrada',
                              ),
                            ],
                            IconButton(
                              icon: Icon(Icons.print,
                                  color: Colors.blue.shade900),
                              onPressed: _imprimirEntrada,
                              tooltip: 'Reimprimir entrada',
                            ),
                            // Add this new button for downloading factura
                            if (widget.entradas.any((e) =>
                                e.entrada_ImgB64Factura != null &&
                                e.entrada_ImgB64Factura!.isNotEmpty))
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf,
                                    color: Colors.red),
                                onPressed: _descargarFactura,
                                tooltip: 'Descargar factura PDF',
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(),

                        //Columna 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Proveedor: ${widget.proveedor.proveedor_Name}'),
                                  Text(
                                      'Almacén: ${widget.almacen.almacen_Nombre}'),
                                  Text('Junta: ${widget.junta.junta_Name}'),
                                ],
                              ),
                            )),
                            Expanded(
                                child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Realizado por: ${widget.user}'),
                                  Text(
                                      'Fecha: ${widget.entradas.first.entrada_Fecha}'),
                                ],
                              ),
                            ))
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: FutureBuilder<Map<int, Productos>>(
                            future: _productosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error al cargar productos: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final productosCache = snapshot.data ?? {};

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  border: TableBorder.all(),
                                  columns: const [
                                    DataColumn(label: Text('ID Producto')),
                                    DataColumn(label: Text('Nombre')),
                                    DataColumn(label: Text('Cantidad')),
                                    DataColumn(label: Text('Precio unitario')),
                                    DataColumn(label: Text('Total (\$)')),
                                    DataColumn(label: Text('Estado')),
                                  ],
                                  rows: groupProductos.entries.map((entry) {
                                    final idProducto = entry.key;
                                    final cantidad = entry.value['cantidad'];
                                    final total = entry.value['total'];
                                    final nombreProducto =
                                        productosCache[idProducto]
                                                ?.prodDescripcion ??
                                            'Desconocido';
                                    final entradasProducto =
                                        entradasPorProducto[idProducto] ?? [];
                                    final tieneActivos = entradasProducto
                                        .any((e) => e.entrada_Estado == true);

                                    return DataRow(cells: [
                                      DataCell(Text(idProducto.toString())),
                                      DataCell(Text(nombreProducto)),
                                      DataCell(Text(cantidad.toString())),
                                      DataCell(Text(
                                          '\$${(total / cantidad).toStringAsFixed(2)}')),
                                      DataCell(Text(
                                          '\$${total.toStringAsFixed(2)}')),
                                      DataCell(Text(
                                          tieneActivos ? 'Activo' : 'Cancelado',
                                          style: TextStyle(
                                              color: tieneActivos
                                                  ? Colors.green
                                                  : Colors.red))),
                                    ]);
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
