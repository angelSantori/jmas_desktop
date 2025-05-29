import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/ajuste_mas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_ajustemas.dart';

class DetailsAjusteMasPage extends StatefulWidget {
  final String userRole;
  final List<AjusteMas> ajustes;
  final Users user;

  const DetailsAjusteMasPage({
    super.key,
    required this.ajustes,
    required this.user,
    required this.userRole,
  });

  @override
  State<DetailsAjusteMasPage> createState() => _DetailsAjusteMasPageState();
}

class _DetailsAjusteMasPageState extends State<DetailsAjusteMasPage> {
  final ProductosController _productosController = ProductosController();
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

  Future<void> _imprimirAjusteMas() async {
    setState(() => _isLoading = true);
    try {
      final productosCache = await _productosFuture;
      final productosParaPDF = <Map<String, dynamic>>[];

      // Agrupar ajustes por producto para el PDF
      final Map<int, List<AjusteMas>> ajustesPorProducto = {};
      for (var ajuste in widget.ajustes) {
        ajustesPorProducto.update(
          ajuste.id_Producto!,
          (value) => [...value, ajuste],
          ifAbsent: () => [ajuste],
        );
      }

      // Preparar datos para el PDF
      for (var entry in ajustesPorProducto.entries) {
        final producto = productosCache[entry.key];
        final cantidad = entry.value.fold<double>(
            0, (sum, ajuste) => sum + (ajuste.ajusteMas_Cantidad ?? 0));
        final costoUnitario = producto?.prodPrecio ?? 0.0;
        final total = costoUnitario * cantidad;

        productosParaPDF.add({
          'id': entry.key,
          'descripcion': producto?.prodDescripcion ?? 'Producto desconocido',
          'cantidad': cantidad,
          'costo': costoUnitario,
          'precio': total,
        });
      }

      await generarPdfAjusteMasFile(
        fecha: widget.ajustes.first.ajusteMas_Fecha ?? '',
        motivo: widget.ajustes.first.ajuesteMas_Descripcion ?? '',
        folio: widget.ajustes.first.ajusteMas_CodFolio ?? '',
        user: widget.user,
        almacen: 'JMAS Meoqui', // Puedes ajustar esto según necesidades
        productos: productosParaPDF,
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
    final Map<int, List<AjusteMas>> ajustesPorProducto = {};

    for (var ajuste in widget.ajustes) {
      // Agrupar por producto para mostrar en tabla
      groupProductos.update(
        ajuste.id_Producto!,
        (value) => {
          'cantidad': value['cantidad'] + ajuste.ajusteMas_Cantidad,
          'ajustes': [...value['ajustes'], ajuste],
        },
        ifAbsent: () => {
          'cantidad': ajuste.ajusteMas_Cantidad,
          'ajustes': [ajuste],
        },
      );

      // Mapear todos los ajustes por producto
      ajustesPorProducto.update(
        ajuste.id_Producto!,
        (value) => [...value, ajuste],
        ifAbsent: () => [ajuste],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Ajuste Más: ${widget.ajustes.first.ajusteMas_CodFolio}',
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
                              'Descripción: ${widget.ajustes.first.ajuesteMas_Descripcion}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.print,
                                  color: Colors.blue.shade900),
                              onPressed: _imprimirAjusteMas,
                              tooltip: 'Imprimir ajuste más',
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(),

                        // Información general
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
                                      'Realizado por: ${widget.user.user_Name}'),
                                  Text('ID Usuario: ${widget.user.id_User}'),
                                ],
                              ),
                            )),
                            Expanded(
                                child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Fecha: ${widget.ajustes.first.ajusteMas_Fecha}'),
                                  Text(
                                      'Total Productos: ${widget.ajustes.length}'),
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
                                  ],
                                  rows: groupProductos.entries.map((entry) {
                                    final idProducto = entry.key;
                                    final cantidad = entry.value['cantidad'];
                                    final producto = productosCache[idProducto];
                                    final precioUnitario =
                                        producto?.prodPrecio ?? 0.0;
                                    final total = precioUnitario * cantidad;

                                    return DataRow(cells: [
                                      DataCell(Text(idProducto.toString())),
                                      DataCell(Text(producto?.prodDescripcion ??
                                          'Desconocido')),
                                      DataCell(
                                          Text(cantidad.toStringAsFixed(2))),
                                      DataCell(Text(
                                          '\$${precioUnitario.toStringAsFixed(2)}')),
                                      DataCell(Text(
                                          '\$${total.toStringAsFixed(2)}')),
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
