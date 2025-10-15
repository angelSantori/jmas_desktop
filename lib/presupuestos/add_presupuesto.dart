import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/presupuestos_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/presupuestos/widgets/pdf_presupuesto.dart';
import 'package:jmas_desktop/salidas/widgets/tabla_productos_salida.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios/custom_autocomplete_field.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AddPresupuesto extends StatefulWidget {
  final String? idUser;
  final String? userName;
  const AddPresupuesto({super.key, this.idUser, this.userName});

  @override
  State<AddPresupuesto> createState() => _AddPresupuestoState();
}

class _AddPresupuestoState extends State<AddPresupuesto> {
  final PadronController _padronController = PadronController();
  final ProductosController _productosController = ProductosController();
  final PresupuestosController _presupuestosController =
      PresupuestosController();

  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _showDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final _fecha = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  final List<Map<String, dynamic>> _productosAgregados = [];

  Productos? _selectedProducto;

  bool _isLoading = false;

  //  Padrones
  Padron? _selectedPadron;
  List<Padron> _padrones = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Padron> padrones = await _padronController.listPadron();

    setState(() {
      _padrones = padrones;
    });
  }

  void _agregarProducto() async {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final double cantidad = double.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      final double existenciaActual = _selectedProducto!.prodExistencia ?? 0.0;
      final double nuevaExistencia = existenciaActual - cantidad;
      final double totalDeficit =
          nuevaExistencia - (_selectedProducto!.prodMin!);

      // Mostrar advertencia si la existencia queda negativa
      if (nuevaExistencia < 0) {
        final bool confirmado = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Column(
                  children: [
                    Icon(Icons.warning_amber_sharp,
                        color: Colors.yellow.shade800),
                    Text('Advertencia',
                        style: TextStyle(
                          color: Colors.yellow.shade800,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                content: Text(
                  'Está intentando registrar una salida que dejará el producto con existencia negativa:\n\n'
                  'Producto: ${_selectedProducto!.prodDescripcion}\n'
                  'Existencia actual: $existenciaActual\n'
                  'Cantidad a descontar: $cantidad\n'
                  'Nueva existencia: $nuevaExistencia\n\n'
                  '¿Desea continuar?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continuar',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ) ??
            false;

        if (!confirmado) {
          return; // El usuario canceló la operación
        }
      }
      // Mostrar advertencia si está por debajo del mínimo (pero no negativo)
      else if (nuevaExistencia < (_selectedProducto!.prodMin!)) {
        showAdvertence(context,
            'La cantidad está por debajo de las existencias mínimas del producto: ${_selectedProducto!.prodDescripcion}. \nCantidad mínima: ${_selectedProducto!.prodMin} \nTotal unidades tras salida: $nuevaExistencia  \nDeficit: $totalDeficit unidades de menos.');
      }

      setState(() {
        double precioUnitario = _selectedProducto!.prodCosto ?? 0.0;
        final double precioTotal = (precioUnitario * 1.16) * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': precioUnitario,
          'cantidad': cantidad,
          'precio': precioTotal,
        });

        //Limpiar campos después de agregar
        _idProductoController.clear();
        _cantidadController.clear();
        _selectedProducto = null;
      });
    } else {
      showAdvertence(
          context, 'Debe seleccionar un producto y definir la cantidad.');
    }
  }

  void eliminarProductoSalida(int index) {
    setState(() {
      _productosAgregados.removeAt(index);
    });
  }

  Presupuestos _crearPresupuesto(Map<String, dynamic> producto) {
    return Presupuestos(
      idPresupuesto: 0,
      presupuestoFolio: '',
      presupuestoFecha:
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      presupuestoEstado: true,
      presupuestoUnidades: double.parse(producto['cantidad'].toString()),
      presupuestoTotal: double.parse(producto['precio'].toString()),
      idUser: int.parse(widget.idUser!),
      idPadron: _selectedPadron!.idPadron!,
      idProducto: producto['id'] ?? 0,
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedPadron = null;
    });
  }

  Future<void> _generarPDFPresupuesto(String folio) async {
    setState(() => _isLoading = true);
    try {
      await generarPDFPresupuesto(
        movimiento: 'Presupuesto',
        fecha: _fecha,
        folio: folio,
        userName: widget.userName!,
        idUser: widget.idUser!,
        padron: _selectedPadron!,
        productos: _productosAgregados,
      );
    } catch (e) {
      print('Error _generarPDFPresupuesto | Try: $e');
      if (mounted) {
        showError(context, 'Error al generar PDF');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarPresupuesto() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(context, 'Debe agregar productos antes de guardar');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // ignore: unused_local_variable
      bool success = true;
      List<Presupuestos>? presupuestosGuardados;
      String? folioGenerado;

      try {
        //  Crear lista de presupuestos para todos los productos
        List<Presupuestos> presupuestosParaGuardar = [];
        for (var producto in _productosAgregados) {
          final nuevosPresupuestos = _crearPresupuesto(producto);
          presupuestosParaGuardar.add(nuevosPresupuestos);
        }

        //  Guardar todos los presupuestos con el mismo folio
        presupuestosGuardados = await _presupuestosController
            .postPresupuestosMultiple(presupuestosParaGuardar);

        if (presupuestosGuardados == null || presupuestosGuardados.isEmpty) {
          success = false;
          if (mounted) {
            showError(context,
                'Error al registrar presupuesto - No se guardaron datos');
          }
        } else {
          // OBTENER EL FOLIO DEL PRIMER PRESUPUESTO GUARDADO
          folioGenerado = presupuestosGuardados.first.presupuestoFolio;

          // Verificar que el folio no sea null o vacío
          if (folioGenerado.isNotEmpty) {
            await _generarPDFPresupuesto(folioGenerado);
            _limpiarFormulario();

            if (mounted) {
              showOk(context, 'Presupuesto creado exitosamente.');
            }
          } else {
            success = false;
            if (mounted) {
              showError(
                  context, 'Error: No se generó folio para el presupuesto');
            }
          }
        }
      } catch (e) {
        print('➡️❌Error en _guardarPresupuesto: $e');
        if (mounted) {
          showError(context, 'Error al procesar la salida');
        }
        success = false;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 15,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Text(
                'Agregar Presupuesto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(child: buildCabeceraItem('Fecha', _showDate)),
            Expanded(child: buildCabeceraItem('Captura', widget.userName!)),
          ],
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Padron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomAutocompleteField<Padron>(
                                  value: _selectedPadron,
                                  labelText: 'Padrón',
                                  items: _padrones,
                                  prefixIcon: Icons.search,
                                  onChanged: (padron) {
                                    setState(() {
                                      _selectedPadron = padron;
                                    });
                                  },
                                  itemLabelBuilder: (padron) =>
                                      '${padron.idPadron ?? 0} - ${padron.padronNombre ?? 'N/A'}',
                                  itemValueBuilder: (padron) =>
                                      padron.idPadron.toString(),
                                  validator: (padron) {
                                    if (padron == null) {
                                      return 'Debe seleccionar un padrón';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_selectedPadron != null) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Id Padrón: ${_selectedPadron?.idPadron}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nombre: ${_selectedPadron?.padronNombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Dirección: ${_selectedPadron?.padronDireccion}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 30),

                      //  Productos
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: BuscarProductoWidget(
                                idProductoController: _idProductoController,
                                cantidadController: _cantidadController,
                                productosController: _productosController,
                                selectedProducto: _selectedProducto,
                                onProductoSeleccionado: (producto) {
                                  setState(() => _selectedProducto = producto);
                                },
                                onAdvertencia: (message) {
                                  showAdvertence(context, message);
                                },
                                onEnterPressed: _agregarProducto,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      //Tabla
                      buildProductosAgregadosSalidaX(
                        _productosAgregados,
                        eliminarProductoSalida,
                        tipoOperacion: 'presupuesto',
                      ),
                      const SizedBox(height: 30),

                      //  Botón
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              elevation: 8,
                              shadowColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);

                                    try {
                                      //  Validar campos
                                      bool datosCompletos =
                                          await validarCamposPresupuesto(
                                        context: context,
                                        productosAgregados: _productosAgregados,
                                        selectedPadron: _selectedPadron,
                                      );

                                      if (!datosCompletos) {
                                        return;
                                      }

                                      //  Guardar registro
                                      await _guardarPresupuesto();
                                    } catch (e) {
                                      showError(
                                          context, 'Error al guardar datos');
                                      print(
                                          '➡️❌Error al guardar datos addPresupuesto: $e');
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                            child: _isLoading
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Procesando...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  )
                                : const Text(
                                    'Guardar y Generar PDF',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
