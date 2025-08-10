import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddConteoPage extends StatefulWidget {
  const AddConteoPage({super.key});

  @override
  State<AddConteoPage> createState() => _AddConteoPageState();
}

class _AddConteoPageState extends State<AddConteoPage> {
  final CapturainviniController _conteoController = CapturainviniController();
  final ProductosController _productosController = ProductosController();
  final AlmacenesController _almacenesController = AlmacenesController();

  // ignore: unused_field
  List<Productos> _productos = [];
  List<Productos> _productosFiltrados = [];
  List<Almacenes> _almacenes = [];
  final Map<int, TextEditingController> _cantidadControllers = {};
  final Map<int, TextEditingController> _justificacionControllers = {};
  final Map<int, int?> _almacenPorProducto = {};
  final Map<int, bool> _mostrarJustificacion = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      final productosFuture = _productosController.listProductos();
      final almacenesFuture = _almacenesController.listAlmacenes();
      final conteosMesActual =
          _conteoController.getConteoInicialByMonth(currentMonth, currentYear);

      final resultados = await Future.wait([
        productosFuture,
        almacenesFuture,
        conteosMesActual,
      ]);

      final todosProductos = resultados[0] as List<Productos>;
      final productosConConteo = (resultados[2] as List<Capturainvini>)
          .map((c) => c.id_Producto)
          .toSet();

      // Filtrar productos: excluir los que ya tienen conteo y los que son servicios
      final productosSinConteo = todosProductos
          .where((p) => !productosConConteo.contains(p.id_Producto))
          .where((p) =>
              p.prodUMedEntrada?.toLowerCase() != "servicio" &&
              p.prodUMedSalida?.toLowerCase() != "servicio")
          .toList();

      setState(() {
        _productos = todosProductos;
        _productosFiltrados = productosSinConteo;
        _almacenes = resultados[1] as List<Almacenes>;

        for (var producto in _productosFiltrados) {
          _cantidadControllers[producto.id_Producto!] = TextEditingController();
          _justificacionControllers[producto.id_Producto!] =
              TextEditingController();
          _almacenPorProducto[producto.id_Producto!] =
              _almacenes.isNotEmpty ? _almacenes.first.id_Almacen : null;
          _mostrarJustificacion[producto.id_Producto!] = false;

          // Listener para mostrar/ocultar justificación según cantidad
          _cantidadControllers[producto.id_Producto!]?.addListener(() {
            final cantidadText =
                _cantidadControllers[producto.id_Producto!]?.text ?? '';
            final cantidad = double.tryParse(cantidadText);
            if (cantidad != null && producto.prodExistencia != null) {
              // ignore: unused_local_variable
              final diferencia = (cantidad - producto.prodExistencia!).abs();
              setState(() {
                _mostrarJustificacion[producto.id_Producto!] =
                    cantidad != producto.prodExistencia;
              });
            }
          });
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showError(context, 'Error al cargar datos: $e');
    }
  }

  Future<void> _guardarConteos() async {
    if (_productosFiltrados.isEmpty) {
      showAdvertence(context, 'No hay productos para guardar');
      return;
    }

    // Validar antes de guardar
    for (var producto in _productosFiltrados) {
      final cantidadText =
          _cantidadControllers[producto.id_Producto]?.text ?? '';
      if (cantidadText.isEmpty) continue;

      final cantidad = double.tryParse(cantidadText);
      if (cantidad == null) continue;

      // Verificar si necesita justificación y si la tiene
      if (_mostrarJustificacion[producto.id_Producto] == true &&
          (_justificacionControllers[producto.id_Producto]?.text.isEmpty ??
              true)) {
        showAdvertence(context,
            'Debe proporcionar una justificación para el producto ${producto.prodDescripcion}');
        return;
      }
    }

    int conteosGuardados = 0;
    bool hasErrors = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Guardando conteos...'),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue.shade900),
            const SizedBox(height: 10),
            Text('$conteosGuardados/${_productosFiltrados.length} guardados'),
          ],
        ),
      ),
    );

    for (var producto in _productosFiltrados) {
      final cantidadText =
          _cantidadControllers[producto.id_Producto]?.text ?? '';
      if (cantidadText.isEmpty) continue;

      final cantidad = double.tryParse(cantidadText);
      final almacenId = _almacenPorProducto[producto.id_Producto];
      final justificacion =
          _justificacionControllers[producto.id_Producto]?.text;

      if (cantidad == null || almacenId == null) {
        hasErrors = true;
        continue;
      }

      final conteo = Capturainvini(
        idInvIni: 0,
        invIniFecha: DateFormat('dd/MM/yy').format(DateTime.now()),
        invIniConteo: cantidad,
        invIniEstado: false,
        invIniJustificacion: _mostrarJustificacion[producto.id_Producto] == true
            ? justificacion
            : null,
        id_Producto: producto.id_Producto,
        id_Almacen: almacenId,
      );

      try {
        final success = await _conteoController.addCapturaFisica(conteo);
        if (success) conteosGuardados++;
      } catch (e) {
        hasErrors = true;
        print(
            'Error al guardar conteo para producto ${producto.id_Producto}: $e');
      }
    }

    if (mounted) Navigator.of(context).pop();

    if (mounted) {
      if (hasErrors) {
        showAdvertence(context,
            'Se guardaron $conteosGuardados conteos, pero hubo algunos errores');
      } else {
        showOk(context, 'Se guardaron $conteosGuardados conteos correctamente');
        _loadData();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _cantidadControllers.values) {
      controller.dispose();
    }
    for (var controller in _justificacionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agregar Conteo: ${DateFormat('dd/MM/yy').format(DateTime.now())}',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _guardarConteos,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = _productosFiltrados[index];
                        return Card(
                          color: Colors.blue.shade100,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${producto.id_Producto} - ${producto.prodDescripcion}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Existencia actual: ${producto.prodExistencia?.toStringAsFixed(2) ?? "N/A"}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextFieldNumero(
                                        controller: _cantidadControllers[
                                            producto.id_Producto]!,
                                        labelText: 'Cantidad',
                                        prefixIcon: Icons.numbers,
                                        allowNegative: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomListaDesplegableTipo<int>(
                                        value: _almacenPorProducto[
                                            producto.id_Producto],
                                        labelText: 'Almacén',
                                        items: _almacenes
                                            .map((a) => a.id_Almacen!)
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _almacenPorProducto[
                                                producto.id_Producto!] = value;
                                          });
                                        },
                                        itemLabelBuilder: (id) {
                                          final almacen = _almacenes.firstWhere(
                                            (a) => a.id_Almacen == id,
                                            orElse: () => Almacenes(
                                                id_Almacen: id,
                                                almacen_Nombre: 'Almacén $id'),
                                          );
                                          return almacen.almacen_Nombre ??
                                              'Almacén $id';
                                        },
                                        icon: Icons.store,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_mostrarJustificacion[
                                        producto.id_Producto] ==
                                    true) ...[
                                  const SizedBox(height: 8),
                                  CustomTextFielTexto(
                                    controller: _justificacionControllers[
                                        producto.id_Producto]!,
                                    labelText: 'Justificación (requerida)',
                                    prefixIcon: Icons.note_add,
                                  ),
                                ],
                              ],
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
}
