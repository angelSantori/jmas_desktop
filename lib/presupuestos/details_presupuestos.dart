import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/presupuestos_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class DetailsPresupuestoPage extends StatefulWidget {
  final List<Presupuestos> presupuestos;
  final String user;
  final String userRole;
  final Padron? padron;
  final Users? userCreoPresupuesto;

  const DetailsPresupuestoPage({
    super.key,
    required this.presupuestos,
    required this.user,
    required this.userRole,
    this.padron,
    this.userCreoPresupuesto,
  });

  @override
  State<DetailsPresupuestoPage> createState() => _DetailsPresupuestoPageState();
}

class _DetailsPresupuestoPageState extends State<DetailsPresupuestoPage> {
  final PresupuestosController _presupuestosController =
      PresupuestosController();
  final ProductosController _productosController = ProductosController();

  List<ProductosOptimizado> _productos = [];
  Map<int, ProductosOptimizado> _productosCache = {};
  bool _isLoading = true;
  bool _editMode = false;

  // Controladores para edición
  final Map<int, TextEditingController> _unidadesControllers = {};
  final Map<int, TextEditingController> _totalControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var presupuesto in widget.presupuestos) {
      _unidadesControllers[presupuesto.idPresupuesto] = TextEditingController(
          text: presupuesto.presupuestoUnidades.toString());
      _totalControllers[presupuesto.idPresupuesto] =
          TextEditingController(text: presupuesto.presupuestoTotal.toString());
    }
  }

  Future<void> _loadData() async {
    try {
      final productos = await _productosController.listProductosOptimizado();
      setState(() {
        _productos = productos;
        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) {
        // Al salir del modo edición, restaurar valores originales
        _initializeControllers();
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      List<Presupuestos> updatedPresupuestos = [];

      for (var presupuesto in widget.presupuestos) {
        final unidadesController =
            _unidadesControllers[presupuesto.idPresupuesto];
        final totalController = _totalControllers[presupuesto.idPresupuesto];

        if (unidadesController != null && totalController != null) {
          final updatedPresupuesto = presupuesto.copyWith(
            presupuestoUnidades: double.tryParse(unidadesController.text) ??
                presupuesto.presupuestoUnidades,
            presupuestoTotal: double.tryParse(totalController.text) ??
                presupuesto.presupuestoTotal,
          );
          updatedPresupuestos.add(updatedPresupuesto);
        }
      }

      final result = await _presupuestosController
          .updatePresupuestosMultiple(updatedPresupuestos);

      if (result != null) {
        showOk(context, 'Presupuesto actualizado correctamente');
        setState(() {
          _editMode = false;
        });
        // Actualizar la lista local con los resultados
        widget.presupuestos.clear();
        widget.presupuestos.addAll(result);
      } else {
        showAdvertence(context, 'Error al actualizar el presupuesto');
      }
    } catch (e) {
      print('Error al guardar cambios: $e');
      showAdvertence(context, 'Error al guardar los cambios');
    }
  }

  void _updateTotal(int idPresupuesto) {
    final unidadesController = _unidadesControllers[idPresupuesto];
    final totalController = _totalControllers[idPresupuesto];

    if (unidadesController != null && totalController != null) {
      final unidades = double.tryParse(unidadesController.text) ?? 0;
      final presupuesto = widget.presupuestos
          .firstWhere((p) => p.idPresupuesto == idPresupuesto);
      final producto = _productosCache[presupuesto.idProducto];

      if (producto != null) {
        final total = unidades * (producto.prodCosto ?? 0);
        totalController.text = total.toStringAsFixed(2);
      }
    }
  }

  void _toggleEstado() async {
    try {
      final nuevoEstado = !widget.presupuestos.first.presupuestoEstado;
      List<Presupuestos> updatedPresupuestos = [];

      for (var presupuesto in widget.presupuestos) {
        updatedPresupuestos.add(presupuesto.copyWith(
          presupuestoEstado: nuevoEstado,
        ));
      }

      final result = await _presupuestosController
          .updatePresupuestosMultiple(updatedPresupuestos);

      if (result != null) {
        showOk(context, 'Estado del presupuesto actualizado');
        setState(() {
          widget.presupuestos.clear();
          widget.presupuestos.addAll(result);
        });
      } else {
        showAdvertence(context, 'Error al actualizar el estado');
      }
    } catch (e) {
      print('Error al cambiar estado: $e');
      showAdvertence(context, 'Error al cambiar el estado');
    }
  }

  @override
  void dispose() {
    // Limpiar controladores
    for (var controller in _unidadesControllers.values) {
      controller.dispose();
    }
    for (var controller in _totalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.presupuestos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Presupuesto'),
        ),
        body: const Center(
          child: Text('No hay datos del presupuesto'),
        ),
      );
    }

    final presupuestoPrincipal = widget.presupuestos.first;
    final double totalUnidades = widget.presupuestos
        .fold(0, (sum, item) => sum + item.presupuestoUnidades);
    final double totalCosto =
        widget.presupuestos.fold(0, (sum, item) => sum + item.presupuestoTotal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Presupuesto ${presupuestoPrincipal.presupuestoFolio}'),
        centerTitle: true,
        actions: [
          // Botón para cambiar estado
          IconButton(
            icon: Icon(
              presupuestoPrincipal.presupuestoEstado
                  ? Icons.check_circle
                  : Icons.cancel,
              color: presupuestoPrincipal.presupuestoEstado
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: _toggleEstado,
            tooltip: presupuestoPrincipal.presupuestoEstado
                ? 'Marcar como usado'
                : 'Marcar como sin usar',
          ),
          // Botón de edición
          if (widget.userRole == 'admin' || widget.userRole == 'supervisor')
            IconButton(
              icon: Icon(_editMode ? Icons.save : Icons.edit),
              onPressed: _editMode ? _saveChanges : _toggleEditMode,
              tooltip: _editMode ? 'Guardar cambios' : 'Editar presupuesto',
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
                  // Información general del presupuesto
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Folio: ${presupuestoPrincipal.presupuestoFolio}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: presupuestoPrincipal.presupuestoEstado
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  presupuestoPrincipal.presupuestoEstado
                                      ? 'SIN USAR'
                                      : 'USADO',
                                  style: TextStyle(
                                    color:
                                        presupuestoPrincipal.presupuestoEstado
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fecha: ${presupuestoPrincipal.presupuestoFecha}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          if (widget.userCreoPresupuesto != null)
                            Text(
                              'Creado por: ${widget.userCreoPresupuesto!.user_Name}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(height: 10),
                          if (widget.padron != null)
                            Text(
                              'Padrón: ${widget.padron!.padronNombre}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Unidades: $totalUnidades',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total Costo: \$${totalCosto.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lista de productos del presupuesto
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos del Presupuesto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...widget.presupuestos.map((presupuesto) {
                            final producto =
                                _productosCache[presupuesto.idProducto];
                            return _buildProductoItem(presupuesto, producto);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductoItem(Presupuestos presupuesto, ProductosOptimizado? producto) {
    final unidadesController = _unidadesControllers[presupuesto.idPresupuesto];
    final totalController = _totalControllers[presupuesto.idPresupuesto];

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
          Text(
            producto?.prodDescripcion ?? 'Producto no encontrado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
                      'Unidades:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _editMode
                        ? CustomTextFielTexto(
                            controller: unidadesController!,
                            labelText: 'Unidades',
                            onChanged: (value) =>
                                _updateTotal(presupuesto.idPresupuesto),
                          )
                        : Text(
                            presupuesto.presupuestoUnidades.toString(),
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
                      '\$${producto?.prodCosto?.toStringAsFixed(2) ?? '0.00'}',
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
                    _editMode
                        ? CustomTextFielTexto(
                            controller: totalController!,
                            labelText: 'Total',
                          )
                        : Text(
                            '\$${presupuesto.presupuestoTotal.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }
}
