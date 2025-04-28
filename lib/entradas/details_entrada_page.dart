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

  Future<void> _cancelarEntrada(Entradas entrada) async {
    final cantidadController = TextEditingController(
        text: entrada.entrada_Unidades?.toStringAsFixed(2) ?? '0');

    // Clave global
    final formKey = GlobalKey<FormState>();

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar entrada'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Qué cantidad desea cancelar?'),
              const SizedBox(height: 20),
              CustomTextFieldNumero(
                controller: cantidadController,
                labelText: 'Cantidad a cancelar',
                prefixIcon: Icons.delete_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una cantidad';
                  }

                  final cantidad = double.tryParse(value) ?? 0;
                  if (cantidad <= 0) return 'La cantidad debe ser mayor a 0';
                  if (cantidad > (entrada.entrada_Unidades ?? 0)) {
                    return 'No puede cancelar más de lo registrado';
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

    final cantidadCancelar = double.tryParse(cantidadController.text) ?? 0;

    setState(() => _isLoading = true);

    try {
      // 1. Registrar cancelación
      final cancelacion = Cancelados(
        idCancelacion: 0,
        cancelMotivo: cantidadCancelar == entrada.entrada_Unidades
            ? 'Cancelación total'
            : 'Cancelación parcial ($cantidadCancelar/${entrada.entrada_Unidades})',
        cancelFecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        id_Entrada: entrada.id_Entradas,
        id_User: int.parse(_currentUserId!),
      );

      final cancelacionExitosa =
          await _canceladoController.addCancelacion(cancelacion);
      if (!cancelacionExitosa) {
        throw Exception('TH1: Error al registrar la cancelación');
      }

      // 2. Actualizar la entrada original
      if (cantidadCancelar == entrada.entrada_Unidades) {
        // Cancelación total - marcar como cancelado
        entrada.entrada_Estado = false;
      } else {
        // Cancelación parcial - ajustar cantidades
        entrada.entrada_Unidades = entrada.entrada_Unidades! - cantidadCancelar;
        entrada.entrada_Costo = entrada.entrada_Costo! *
            (entrada.entrada_Unidades! /
                (entrada.entrada_Unidades! + cantidadCancelar));
      }

      final actualizado = await EntradasController().editEntrada(entrada);
      if (!actualizado) {
        throw Exception('TH2: Error al actualizar la entrada');
      }

      // 3. Actualizar existencias del producto
      final producto =
          await _productosController.getProductoById(entrada.idProducto!);
      if (producto != null) {
        producto.prodExistencia =
            (producto.prodExistencia ?? 0) - cantidadCancelar;
        await _productosController.editProducto(producto);
      }

      //4. Generar PDF cancelación
      await generarPdfCancelacion(
        tipoMovimiento: 'DEVOLUCIÓN_ENTRADA',
        fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        motivo: cantidadCancelar == entrada.entrada_Unidades
            ? 'Cancelación total'
            : 'Cancelación parcial ($cantidadCancelar/${entrada.entrada_Unidades})',
        folio: entrada.entrada_CodFolio ?? '',
        referencia: entrada.entrada_Referencia ?? '',
        user: _currentUser!,
        almacen: widget.almacen.almacen_Nombre ?? '',
        proveedor: widget.proveedor.proveedor_Name ?? '',
        junta: widget.junta.junta_Name ?? '',
        productos: [
          {
            'id': entrada.idProducto,
            'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
            'cantidad': cantidadCancelar,
            'costo': entrada.entrada_Costo! / entrada.entrada_Unidades!,
            'precio': (entrada.entrada_Costo! / entrada.entrada_Unidades!) *
                cantidadCancelar,
          }
        ],
      );

      // 5. Mostrar mensaje de éxito y actualizar vista
      await showOk(context, 'Cancelación registrada exitosamente');

      // Recargar datos
      final futureProductos = _loadProductos();
      setState(() {
        _productosFuture = futureProductos;
      });
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
    final Map<int, List<Entradas>> entradasPorProducto = {};

    final isAdmin = widget.userRole == "Admin";
    final isGestion = widget.userRole == "Gestion";

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
                          'Referencia: ${widget.entradas.first.entrada_Referencia}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Proveedor: ${widget.proveedor.proveedor_Name}'),
                        Text('Almacén: ${widget.almacen.almacen_Nombre}'),
                        Text('Junta: ${widget.junta.junta_Name}'),
                        Text('Realizado por: ${widget.user}'),
                        Text('Fecha: ${widget.entradas.first.entrada_Fecha}'),
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
                                  columns: [
                                    const DataColumn(
                                        label: Text('ID Producto')),
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
                                      if (isAdmin || isGestion)
                                        DataCell(
                                          tieneActivos
                                              ? IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color:
                                                          Colors.red.shade800),
                                                  onPressed: () => _cancelarEntrada(
                                                      entradasProducto
                                                          .firstWhere((e) =>
                                                              e.entrada_Estado ==
                                                              true)),
                                                  tooltip: 'Cancelar entrada',
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
