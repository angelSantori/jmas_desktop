import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_cancelacion.dart';

class DetailsSalidaPage extends StatefulWidget {
  final String userRole;
  final List<Salidas> salidas;
  final Almacenes almacen;
  final Juntas junta;
  final Padron padron;
  final Users userAsignado;
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

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProductos();
    _getCurrentUser();
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

  Future<void> _devolverProductoSalida(Salidas salida) async {
    final cantidadController = TextEditingController(
        text: salida.salida_Unidades?.toStringAsFixed(2) ?? '0');

    //Clave global
    final formKey = GlobalKey<FormState>();

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devolver producto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Qué cantidad desea devolver?'),
              const SizedBox(height: 20),
              CustomTextFieldNumero(
                controller: cantidadController,
                labelText: 'Cantidad a devolver',
                prefixIcon: Icons.delete_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una cantidad';
                  }

                  final cantidad = double.tryParse(value) ?? 0;
                  if (cantidad <= 0) return 'La cantidad debe ser mayor a 0';
                  if (cantidad > (salida.salida_Unidades ?? 0)) {
                    return 'No puede devolver más de lo registrado';
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

    final cantidadDevolver = double.tryParse(cantidadController.text) ?? 0;

    setState(() => _isLoading = true);

    try {
      //TODO: Agregar en el back la cantidad
      //1. Registrar cancelación
      final cancelacion = CanceladoSalidas(
        idCanceladoSalida: 0,
        cancelSalidaMotivo: cantidadDevolver == salida.salida_Unidades
            ? 'Devolución total'
            : 'Devolución parcial ($cantidadDevolver/${salida.salida_Unidades})',
        cancelSalidaFecha:
            DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        id_Salida: salida.id_Salida,
        id_User: int.parse(_currentUserId!),
      );

      final cancelacionExitosa =
          await _canceladoSalidaController.addCancelSalida(cancelacion);
      if (!cancelacionExitosa) {
        throw Exception('TH1: Error al registrar la cancelación');
      }

      // 2. Actualizar la salida original
      if (cantidadDevolver == salida.salida_Unidades) {
        // Devolución total - marcar como cancelado
        salida.salida_Estado = false;
      } else {
        // Devolución parcial - ajustar cantidades
        salida.salida_Unidades = salida.salida_Unidades! - cantidadDevolver;
        salida.salida_Costo = salida.salida_Costo! *
            (salida.salida_Unidades! /
                (salida.salida_Unidades! + cantidadDevolver));
      }

      final actualizado = await SalidasController().editSalida(salida);
      if (!actualizado) {
        throw Exception('TH2: Error al actualizar la salida');
      }

      //3. Actualizar existencias del produco
      final producto =
          await _productosController.getProductoById(salida.idProducto!);
      if (producto != null) {
        producto.prodExistencia =
            (producto.prodExistencia ?? 0) + cantidadDevolver;
        await _productosController.editProducto(producto);
      }

      //4. Generar PDF cancelación
      await generarPdfCancelacion(
        tipoMovimiento: 'DEVOLUCIÓN_SALIDA',
        fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        motivo: cantidadDevolver == salida.salida_Unidades
            ? 'Devolución total'
            : 'Devolución parcial ($cantidadDevolver/${salida.salida_Unidades})',
        folio: salida.salida_CodFolio ?? '',
        referencia: salida.salida_Referencia ?? '',
        user: _currentUser!,
        almacen: widget.almacen.almacen_Nombre ?? '',
        junta: widget.junta.junta_Name ?? '',
        padron: widget.padron.padronNombre ?? '',
        usuarioAsignado: widget.userAsignado.user_Name ?? '',
        tipoTrabajo: salida.salida_TipoTrabajo ?? '',
        productos: [
          {
            'id': salida.idProducto,
            'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
            'cantidad': cantidadDevolver,
            'costo': salida.salida_Costo! / salida.salida_Unidades!,
            'precio': (salida.salida_Costo! / salida.salida_Unidades!) *
                cantidadDevolver,
          }
        ],
      );

      //5. Mostrar mensaje de éxito y actualizar vist
      await showOk(context, 'Devolución registrada exitosamente');

      //Recargar datos
      final futureProductos = _loadProductos();
      setState(() {
        _productosFuture = futureProductos;
      });
    } catch (e) {
      showError(context, 'Error al procesar devolución');
      print('Error al procesar devolución: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> groupProductos = {};
    final Map<int, List<Salidas>> salidasPorProducto = {};

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 4,
                  color: const Color.fromARGB(255, 201, 230, 242),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Referencia: ${widget.salidas.first.salida_Referencia}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Almacen: ${widget.almacen.almacen_Nombre}'),
                        Text('Junta: ${widget.junta.junta_Name}'),
                        Text('Padron: ${widget.padron.padronNombre}'),
                        Text('Realizado por: ${widget.user}'),
                        Text('Asignado a: ${widget.userAsignado.user_Name}'),
                        Text(
                            'Tipo trabajo: ${widget.salidas.first.salida_TipoTrabajo}'),
                        Text('Fecha: ${widget.salidas.first.salida_Fecha}'),
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
                                  columns: [
                                    const DataColumn(
                                        label: Text('Id Producto')),
                                    const DataColumn(label: Text('Nombre')),
                                    const DataColumn(label: Text('Cantidad')),
                                    const DataColumn(
                                        label: Text('Precio unitario')),
                                    const DataColumn(label: Text('Total (\$)')),
                                    const DataColumn(label: Text('Estado')),
                                    if (isAdmin || isGestion)
                                      const DataColumn(label: Text('Acciones')),
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
                                      if (isAdmin || isGestion)
                                        DataCell(
                                          tieneActivos
                                              ? IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color:
                                                          Colors.red.shade800),
                                                  onPressed: () =>
                                                      _devolverProductoSalida(
                                                          salidasProducto
                                                              .firstWhere((s) =>
                                                                  s.salida_Estado ==
                                                                  true)),
                                                  tooltip: 'Devolver producto',
                                                )
                                              : const Text(''),
                                        ),
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
