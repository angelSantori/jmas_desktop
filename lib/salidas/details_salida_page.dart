import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_trabajo_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
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
  final OrdenTrabajo ordenTrabajo;
  final String user;

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
    required this.ordenTrabajo,
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
  late Future<Map<int, Productos>> _productosFuture;

  String? _currentUserId;
  Users? _currentUser;
  bool _isLoading = false;
  final TextEditingController _motivoController = TextEditingController();
  Map<int, Productos>? productosCache;

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

  Future<Map<int, Productos>> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
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
        });
      }

      await ReimpresionSalidaPdf.generateAndPrintPdfSalida(
        movimiento: 'SALIDA',
        fecha: widget.salidas.first.salida_Fecha ?? '',
        folio: widget.salidas.first.salida_CodFolio ?? '',
        referencia: widget.salidas.first.salida_Referencia ?? '',
        userName: widget.user,
        idUser: _currentUserId ?? '0',
        almacen: widget.almacen,
        userAsignado: widget.userAsignado,
        tipoTrabajo: widget.salidas.first.salida_TipoTrabajo ?? '',
        padron: widget.padron,
        colonia: widget.colonia,
        calle: widget.calle,
        ordenTrabajo: widget.ordenTrabajo,
        productos: productosParaPDF,
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
            await _productosController.editProducto(producto);

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
          referencia: widget.salidas.first.salida_Referencia ?? '',
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
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  color: const Color.fromARGB(255, 210, 220, 224),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(100),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Referencia: ${widget.salidas.first.salida_Referencia}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
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
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(),
                        //Columnas
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
                                        'Almacen: ${widget.almacen.almacen_Nombre}'),
                                    Text('Junta: ${widget.junta.junta_Name}'),
                                    Text(
                                        'Padron: ${widget.padron.idPadron} - ${widget.padron.padronNombre}'),
                                    Text(
                                        'Orden Trabajo: ${widget.ordenTrabajo.folioOT} - ${widget.ordenTrabajo.tipoProblemaOT}'),
                                  ],
                                ),
                              ),
                            ),

                            //Columna 2
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Asignado a: ${widget.userAsignado.user_Name}'),
                                    Text(
                                        'Tipo trabajo: ${widget.salidas.first.salida_TipoTrabajo ?? 'N/A'}'),
                                    Text(
                                        'Fecha: ${widget.salidas.first.salida_Fecha}'),
                                  ],
                                ),
                              ),
                            ),
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
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.blue.shade900),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error al cargar productos: ${snapshot.error}',
                                        style: const TextStyle(
                                            color: Colors.red)));
                              }
                              final productosCache = snapshot.data ?? {};

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Id Producto')),
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
                                    final salidasProducto =
                                        salidasPorProducto[idProducto] ?? [];
                                    final tieneActivos = salidasProducto
                                        .any((s) => s.salida_Estado == true);

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
