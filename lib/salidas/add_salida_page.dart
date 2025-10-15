import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/contratistas_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/presupuestos_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/trabajo_realizado_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/salidas/widgets/pdf_salida.dart';
import 'package:jmas_desktop/salidas/widgets/tabla_productos_salida.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/buscar_calle_widget.dart';
import 'package:jmas_desktop/widgets/buscar_colonia_widget.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/formularios/custom_autocomplete_field.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/widgets_salida.dart';

class AddSalidaPage extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddSalidaPage({super.key, this.userName, this.idUser});

  @override
  State<AddSalidaPage> createState() => _AddSalidaPageState();
}

class _AddSalidaPageState extends State<AddSalidaPage> {
  final AuthService _authService = AuthService();
  final SalidasController _salidasController = SalidasController();
  final JuntasController _juntasController = JuntasController();
  final AlmacenesController _almacenesController = AlmacenesController();
  final ProductosController _productosController = ProductosController();
  final ColoniasController _coloniasController = ColoniasController();
  final CallesController _callesController = CallesController();
  final UsersController _usersController = UsersController();
  final PadronController _padronController = PadronController();
  final OrdenServicioController _ordenServicioController =
      OrdenServicioController();
  final TrabajoRealizadoController _trabajoRealizadoController =
      TrabajoRealizadoController();
  final PresupuestosController _presupuestosController =
      PresupuestosController();
  final ContratistasController _contratistasController =
      ContratistasController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _busquedaUsuarioController =
      TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _idPadronController = TextEditingController();
  final TextEditingController _idColoniaController = TextEditingController();
  final TextEditingController _idCalleController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _folioPresupuestoController =
      TextEditingController(text: 'PRE');
  final TextEditingController _folioOSTController = TextEditingController();

  final _showDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? idUserReporte;
  String? folioTR;

  //Empleados
  List<Users> _empleados = [];
  Users? _selectedEmpleado;

  //Autotiza
  List<Users> _listaAutoriza = [];
  Users? _selectedAutoriza;

  //Odenes aprobadas
  List<OrdenServicio> _ordenesServicioAprobadas = [];
  // ignore: unused_field
  bool _cargandoOrdenes = false;
  OrdenServicio? _selectedOrdenServicio;

  //Presupuestos
  List<Presupuestos> _presupuestosSeleccionados = [];
  bool _cargandoPresupuestos = false;
  Padron? _padronPresupuesto;

  List<Almacenes> _almacenes = [];
  List<Juntas> _juntas = [];
  List<Contratistas> _contratistas = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Almacenes? _selectedAlmacen;
  Juntas? _selectedJunta;
  Productos? _selectedProducto;
  Colonias? _selectedColonia;
  Calles? _selectedCalle;
  Padron? _selectedPadron;
  Contratistas? _selectedContratista;

  bool _isLoading = false;
  bool _isGeneratingPDF = false;
  bool _mostrarOrdenServicio = false;
  bool _mostrarPresupuesto = false;
  bool _mostrarContratista = false;

  Uint8List? _imagenOrden;

  // Lista de juntas especiales que NO aplican descuento
  final List<int> _juntasEspeciales = [1, 6, 8, 14];

  String? _selectedTipoTrabajo;
  final List<String> _tipoTrabajos = [
    'Mantenimiento',
    'Preventivo',
    'Emergencia',
  ];

  @override
  void initState() {
    super.initState();
    _loadDataSalidas();
    _loadFolioTR();
    _cargarOrdenesAprobadas();
  }

  void _recalcularPreciosPorCambioDeJunta() {
    if (_productosAgregados.isEmpty) return;

    setState(() {
      for (int i = 0; i < _productosAgregados.length; i++) {
        var producto = _productosAgregados[i];

        // Solo recalcular para productos especiales
        if (producto['id'] == 40050558 || producto['id'] == 40050557) {
          double cantidad = producto['cantidad'];
          double costoOriginal =
              producto['costo_original'] ?? producto['costo'];

          // Recalcular precio unitario
          double nuevoPrecioUnitario = costoOriginal;
          if (_selectedJunta != null &&
              !_juntasEspeciales.contains(_selectedJunta!.id_Junta)) {
            nuevoPrecioUnitario = costoOriginal * 0.4; // 60% descuento
          }

          _productosAgregados[i]['costo'] = nuevoPrecioUnitario;
          _productosAgregados[i]['precio'] = nuevoPrecioUnitario * cantidad;
          _productosAgregados[i]['descuento_aplicado'] =
              (nuevoPrecioUnitario != costoOriginal);
        }
      }
    });
  }

  double _calcularPrecioConDescuento(Productos producto, double cantidad) {
    double precioUnitario = producto.prodCosto ?? 0.0;

    // Aplicar descuento del 60% si el producto es 40050558 o 40050557
    // y la junta NO está en la lista de especiales
    if ((producto.id_Producto == 40050558 ||
            producto.id_Producto == 40050557) &&
        _selectedJunta != null &&
        !_juntasEspeciales.contains(_selectedJunta!.id_Junta)) {
      precioUnitario =
          precioUnitario * 0.4; // 60% de descuento (40% del precio original)
    }

    return precioUnitario * cantidad;
  }

  Future<void> _buscarPrespuestoByFolio() async {
    String folio = _folioPresupuestoController.text.trim();

    // Validar que el folio tenga al menos 4 caracteres (PRE + al menos 1 número)
    if (folio.isEmpty || folio.length < 4) {
      showAdvertence(
          context, 'Ingrese un folio de presupuesto válido (ej: PRE1)');
      return;
    }

    // Validar que el folio empiece con PRE
    if (!folio.toUpperCase().startsWith('PRE')) {
      showAdvertence(context, 'El folio debe comenzar con "PRE"');
      return;
    }

    setState(() => _cargandoPresupuestos = true);

    try {
      final presupuestos =
          await _presupuestosController.getPresupuestoByFolio(folio);

      if (presupuestos == null || presupuestos.isEmpty) {
        showAdvertence(
            context, 'No se encontró el presupuesto con el folio: $folio');
        setState(() {
          _presupuestosSeleccionados.clear();
          _padronPresupuesto = null;
        });
        return;
      }

      //  Verificar si hay presupuesto ya utilizdos (estado = false)
      final presupuestoUtilizado =
          presupuestos.where((p) => !p.presupuestoEstado).toList();
      if (presupuestoUtilizado.isNotEmpty) {
        showAdvertence(context,
            'El presupuesto contiene ${presupuestoUtilizado.length} productos(s) ya utilizados. No se puede seleccionar.');
        setState(() {
          _presupuestosSeleccionados.clear();
          _padronPresupuesto = null;
        });
        return;
      }

      // Obtener información del padrón del primer presupuesto
      final primerPresupuesto = presupuestos.first;
      final padron =
          await _padronController.getPadronById(primerPresupuesto.idPadron);

      setState(() {
        _presupuestosSeleccionados = presupuestos;
        _padronPresupuesto = padron;
        _selectedPadron = padron;

        if (padron != null) {
          _idPadronController.text = padron.idPadron.toString();
        }
      });

      // AUTOMÁTICAMENTE cargar los productos del presupuesto en la salida
      _cargarProductosPresupuestoEnSalida();
    } catch (e) {
      print('Error _buscarPresupuestoPorFolio: $e');
      showError(context, 'Error al buscar presupuesto');
    } finally {
      setState(() => _cargandoPresupuestos = false);
    }
  }

  void _cargarProductosPresupuestoEnSalida() async {
    if (_presupuestosSeleccionados.isEmpty) {
      return;
    }

    setState(() {
      // Limpiar productos actuales
      _productosAgregados.clear();
    });

    // Cargar todos los productos del presupuesto
    for (var presupuesto in _presupuestosSeleccionados) {
      try {
        final producto =
            await _productosController.getProductoById(presupuesto.idProducto);
        if (producto != null) {
          // CALCULAR PRECIO UNITARIO CORRECTO DEL PRESUPUESTO
          final double precioUnitarioPresupuesto =
              presupuesto.presupuestoUnidades > 0
                  ? presupuesto.presupuestoTotal /
                      presupuesto.presupuestoUnidades
                  : 0.0;

          setState(() {
            _productosAgregados.add({
              'id': producto.id_Producto,
              'descripcion': producto.prodDescripcion,
              'costo':
                  precioUnitarioPresupuesto, // USAR PRECIO DEL PRESUPUESTO, NO DEL PRODUCTO
              'cantidad': presupuesto.presupuestoUnidades,
              'precio': presupuesto.presupuestoTotal,
              'presupuesto_original': true,
            });
          });
        }
      } catch (e) {
        print('Error cargando producto ${presupuesto.idProducto}: $e');
      }
    }

    showOk(context, 'Presupuesto cargado automáticamente en la salida');
  }

  Widget _buildTablaPresupuesto() {
    if (_presupuestosSeleccionados.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Productos del Presupuesto:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(1), // ID Producto
            1: FlexColumnWidth(3), // Descripción
            2: FlexColumnWidth(0.5), // Unidades
            3: FlexColumnWidth(1), // Precio Unitario
            4: FlexColumnWidth(1), // Precio Total
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.green.shade800,
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Clave',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Descripción',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Unidades',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'P. Unitario',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'P. Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            ..._presupuestosSeleccionados.map((presupuesto) {
              // Calcular precio unitario
              final precioUnitario = presupuesto.presupuestoUnidades > 0
                  ? presupuesto.presupuestoTotal /
                      presupuesto.presupuestoUnidades
                  : 0.0;

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      presupuesto.idProducto.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FutureBuilder<Productos?>(
                    future: _productosController
                        .getProductoById(presupuesto.idProducto),
                    builder: (context, snapshot) {
                      final descripcion = snapshot.hasData
                          ? snapshot.data!.prodDescripcion
                          : 'Cargando...';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          descripcion ?? 'N/A',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      presupuesto.presupuestoUnidades.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '\$${precioUnitario.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '\$${presupuesto.presupuestoTotal.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
            // Fila de totales
            TableRow(
              children: [
                const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '\$${_presupuestosSeleccionados.fold<double>(0.0, (sum, presupuesto) => sum + presupuesto.presupuestoTotal).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoPadronPresupuesto() {
    if (_padronPresupuesto == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Información del Padrón del Presupuesto:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Padrón: ${_padronPresupuesto!.idPadron}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nombre: ${_padronPresupuesto!.padronNombre ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dirección: ${_padronPresupuesto!.padronDireccion ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      final Uint8List bytes = await imagen.readAsBytes();

      setState(() {
        _imagenOrden = bytes;
      });
    }
  }

  Future<void> _loadFolioTR() async {
    final fetchedFolioTR = await _trabajoRealizadoController.getNextTRFolio();
    setState(() {
      folioTR = fetchedFolioTR;
    });
  }

  Future<void> _loadDataSalidas() async {
    List<Almacenes> almacenes = await _almacenesController.listAlmacenes();
    List<Juntas> juntas = await _juntasController.listJuntas();
    List<Users> usuarios = await _usersController.listUsers();
    List<Contratistas> contratistas =
        await _contratistasController.listContratistas();

    setState(() {
      _almacenes = almacenes;
      _juntas = juntas;
      _contratistas = contratistas;
      _listaAutoriza = usuarios;
      _empleados = usuarios
          .where((empleados) => empleados.user_Rol == 'Empleado')
          .toList();
    });
  }

  Future<void> _cargarOrdenesAprobadas() async {
    setState(() => _cargandoOrdenes = true);
    try {
      final todasOrdenes = await _ordenServicioController.listOrdenServicio();
      setState(() {
        _ordenesServicioAprobadas = todasOrdenes
            .where((orden) =>
                orden.estadoOS == 'Requiere Material' ||
                orden.estadoOS == 'Devuelta')
            .toList();
        _cargandoOrdenes = false;
      });
    } catch (e) {
      print('Error _cargarOrdenesAprobadas | AddSalida : $e');
      setState(() => _cargandoOrdenes = false);
    }
  }

  void actualizarCostoSalida(int index, double nuevoCosto) {
    setState(() {
      _productosAgregados[index]['costo'] = nuevoCosto;
      _productosAgregados[index]['precio'] =
          nuevoCosto * (_productosAgregados[index]['cantidad'] ?? 1);
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
      if (nuevaExistencia < 0 &&
          _selectedProducto!.prodUMedEntrada != "Servicio") {
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

      setState(() {
        final double precioTotal =
            _calcularPrecioConDescuento(_selectedProducto!, cantidad);
        final double precioUnitario = precioTotal / cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': precioUnitario,
          'cantidad': cantidad,
          'precio': precioTotal,
          'descuento_aplicado':
              (precioUnitario != _selectedProducto!.prodCosto),
          'costo_original': _selectedProducto!.prodCosto,
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

  Future<void> _actualizarEstadoPresupuestos() async {
    try {
      // Crear una lista de presupuestos actualizados con estado = false
      final presupuestosActualizados =
          _presupuestosSeleccionados.map((presupuesto) {
        return presupuesto.copyWith(
          presupuestoEstado: false,
        );
      }).toList();

      // Llamar al controlador para ACTUALIZAR los presupuestos (no crear nuevos)
      final resultado = await _presupuestosController
          .updatePresupuestosMultiple(presupuestosActualizados);

      if (resultado == null) {
        print('Error al actualizar el estado de los presupuestos');
        showAdvertence(context, 'Error al marcar presupuestos como utilizados');
      } else {
        print(
            'Presupuestos actualizados exitosamente: ${resultado.length} registros');
      }
    } catch (e) {
      print('Error en _actualizarEstadoPresupuestos: $e');
      showAdvertence(context, 'Error al actualizar estado de presupuestos');
    }
  }

  Future<void> _guardarSalida() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(
          context, 'Debe agregar productos antes de guardar la salida.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      bool success = true;
      List<Salidas>? salidasGuardadas;
      String? folioGenerado;

      try {
        await _getUserId();

        // Crear lista de salidas para todos los productos
        List<Salidas> salidasParaGuardar = [];
        for (var producto in _productosAgregados) {
          final nuevaSalida = _crearSalida(producto);
          salidasParaGuardar.add(nuevaSalida);
        }

        // Guardar todas las salidas con el mismo folio
        salidasGuardadas =
            await _salidasController.addMultipleSalidas(salidasParaGuardar);

        if (salidasGuardadas == null || salidasGuardadas.isEmpty) {
          success = false;
        } else {
          // Obtener el folio generado (de la primera salida)
          folioGenerado = salidasGuardadas.first.salida_CodFolio;
          if (_presupuestosSeleccionados.isNotEmpty) {
            await _actualizarEstadoPresupuestos();
          }

          // Actualizar existencias de productos
          for (int i = 0; i < _productosAgregados.length; i++) {
            var producto = _productosAgregados[i];

            if (producto['id'] == null) {
              showAdvertence(context,
                  'Id nulo: ${producto['id_Producto']}, no se puede continuar');
              success = false;
              break;
            }

            final productoActualizado =
                await _productosController.getProductoById(producto['id']);

            if (productoActualizado == null) {
              showAdvertence(context,
                  'Producto con ID ${producto['id']} no encontrado en la base de datos.');
              success = false;
              break;
            }

            productoActualizado.prodExistencia =
                (productoActualizado.prodExistencia!) - producto['cantidad'];

            bool editResult =
                await _productosController.editProducto(productoActualizado);

            if (!editResult) {
              showAdvertence(context,
                  'Error al actualizar las existencias del producto con ID ${producto['id_Producto']}');
              success = false;
              break;
            }
          }
        }

        if (success && folioGenerado != null) {
          // Crear trabajo realizado si hay orden de servicio
          if (_selectedOrdenServicio != null) {
            final trabajoCreado = await _crearTrabajo();
            if (!trabajoCreado) {
              showAdvertence(context, 'Error al crear registro de servicio');
            }
            _selectedOrdenServicio!.estadoOS = 'Aprobada - A';
            final estadoOrden = await _ordenServicioController
                .editOrdenServicio(_selectedOrdenServicio!);
            if (!estadoOrden) {
              showAdvertence(context, 'Error al actualizar estado de la orden');
            }
          }

          // Generar PDF con el folio único
          await _generarPDFConFolio(folioGenerado);

          // Limpiar formulario
          _limpiarFormulario();

          if (mounted) {
            showOk(context, 'Salida creada exitosamente.');
          }
        } else {
          if (mounted) {
            showError(context, 'Error al registrar salida');
          }
        }
      } catch (e) {
        print('Error en _guardarSalida: $e');
        if (mounted) {
          showError(context, 'Error al procesar la salida');
        }
        success = false;
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _generarPDFConFolio(String folio) async {
    setState(() => _isGeneratingPDF = true);

    try {
      await generarPdfSalida(
        movimiento: 'Salida',
        fecha: _fechaController.text,
        folio: folio,
        presupuestoFolio:
            !_mostrarPresupuesto ? 'N/A' : _folioPresupuestoController.text,
        userName: widget.userName!,
        idUser: widget.idUser!,
        alamcenA: _selectedAlmacen!,
        userAsignado: _selectedEmpleado!,
        tipoTrabajo: _selectedTipoTrabajo!,
        padron: _selectedPadron!,
        colonia: _selectedColonia!,
        calle: _selectedCalle!,
        junta: _selectedJunta!,
        ordenServicio: _selectedOrdenServicio,
        userAutoriza: _selectedAutoriza!,
        comentario: _comentarioController.text,
        productos: _productosAgregados,
        folioOST: _folioOSTController.text,
        contratista: _selectedContratista,
      );
    } catch (e) {
      print('Error al generar PDF: $e');
      if (mounted) {
        showError(context, 'Error al generar PDF');
      }
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  void eliminarProductoSalida(int index) {
    setState(() {
      _productosAgregados.removeAt(index);
    });
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserReporte = decodeToken?['Id_User'] ?? '0';
  }

  Salidas _crearSalida(Map<String, dynamic> producto) {
    return Salidas(
      id_Salida: 0,
      salida_CodFolio: '',
      salida_PresupuestoFolio:
          !_mostrarPresupuesto ? 'N/A' : _folioPresupuestoController.text,
      salida_Estado: true,
      salida_Unidades: double.tryParse(producto['cantidad'].toString()),
      salida_Costo: double.tryParse(producto['precio'].toString()),
      salida_Fecha: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      salida_TipoTrabajo: _selectedTipoTrabajo,
      salida_Comentario: _comentarioController.text,
      salida_DocumentoFirma: false,
      salida_Pagado: false,
      salida_Imag64Orden:
          _imagenOrden != null ? base64Encode(_imagenOrden!) : null,
      salidaFolioOST: _folioOSTController.text,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!), // Usuario
      id_Junta: _selectedJunta?.id_Junta,
      id_Almacen: _selectedAlmacen?.id_Almacen ?? 0, // Almacen
      id_User_Asignado: _selectedEmpleado?.id_User,
      idPadron: _selectedPadron?.idPadron,
      idCalle: _selectedCalle?.idCalle,
      idColonia: _selectedColonia?.idColonia,
      idOrdenServicio: _selectedOrdenServicio?.idOrdenServicio,
      idUserAutoriza: _selectedAutoriza?.id_User,
      idContratista: _selectedContratista?.idContratista,
    );
  }

  Future<bool> _crearTrabajo() async {
    if (_selectedOrdenServicio == null || _selectedEmpleado == null)
      return false;
    try {
      final trabajo = TrabajoRealizado(
        idTrabajoRealizado: 0,
        folioTR: folioTR,
        idUserTR: _selectedEmpleado?.id_User,
        idOrdenServicio: _selectedOrdenServicio?.idOrdenServicio,
        folioOS: _selectedOrdenServicio!.folioOS,
        padronDireccion: _selectedPadron!.padronDireccion,
        padronNombre: _selectedPadron!.padronNombre,
        problemaNombre: _selectedTipoTrabajo,
      );

      return await _trabajoRealizadoController.addTrabajoRealizado(trabajo);
    } catch (e) {
      print('Error _crearTrabajo | addSalidaPage: $e');
      return false;
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedAlmacen = null;
      _selectedJunta = null;
      _selectedProducto = null;
      _selectedColonia = null;
      _selectedCalle = null;
      _selectedPadron = null;
      _selectedEmpleado = null;
      _selectedTipoTrabajo = null;
      _selectedAutoriza = null;
      _selectedContratista = null;
      _imagenOrden = null;
      _selectedOrdenServicio = null;
      _mostrarOrdenServicio = false;
      _mostrarPresupuesto = false;
      _mostrarContratista = false;

      _presupuestosSeleccionados.clear();
      _padronPresupuesto = null;
      _folioPresupuestoController.text = 'PRE';

      _busquedaUsuarioController.clear();
      _folioOSTController.clear();
      _comentarioController.clear();
      _idProductoController.clear();
      _idColoniaController.clear();
      _idCalleController.clear();
      _idPadronController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const SizedBox(height: 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: buildCabeceraItem('Fecha', _showDate)),
                          Expanded(
                            child:
                                buildCabeceraItem('Captura', widget.userName!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          // Expanded(
                          //   child: CustomTextFielTexto(
                          //     controller: _folioPresupuestoController,
                          //     prefixIcon: Icons.receipt,
                          //     labelText: 'Folio de presupuesto (ej, PRE1)',
                          //     inputFormatters: [
                          //       // No permite espacios
                          //       FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          //       // Permite solo letras, números y algunos caracteres especiales
                          //       FilteringTextInputFormatter.allow(
                          //           RegExp(r'[a-zA-Z0-9]')),
                          //     ],
                          //     validator: (folio) {
                          //       if (folio == null ||
                          //           folio.isEmpty ||
                          //           folio.length < 4) {
                          //         return 'Ingrese un folio válido (ej: PRE1)';
                          //       }
                          //       if (!folio.toUpperCase().startsWith('PRE')) {
                          //         return 'El folio debe comenzar con "PRE"';
                          //       }
                          //       return null;
                          //     },
                          //     onFieldSubmitted: (value) {
                          //       if (value.isNotEmpty &&
                          //           value.toUpperCase().startsWith('PRE')) {
                          //         _buscarPrespuestoByFolio();
                          //       }
                          //     },
                          //     onChanged: (value) {
                          //       // Mantener "PRE" siempre al principio y en mayúsculas
                          //       if (value.isNotEmpty &&
                          //           (aqui iba un signo de admiración !)value.toUpperCase().startsWith('PRE')) {
                          //         // Si el usuario borra parte de "PRE", restaurarlo
                          //         if (value.length < 3) {
                          //           _folioPresupuestoController.text = 'PRE';
                          //           _folioPresupuestoController.selection =
                          //               TextSelection.collapsed(offset: 3);
                          //         } else {
                          //           // Forzar que empiece con PRE
                          //           final cleanedValue =
                          //               'PRE${value.substring(3)}';
                          //           _folioPresupuestoController.text =
                          //               cleanedValue.toUpperCase();
                          //           _folioPresupuestoController.selection =
                          //               TextSelection.collapsed(
                          //                   offset: cleanedValue.length);
                          //         }
                          //       } else if (value.isNotEmpty) {
                          //         // Convertir a mayúsculas automáticamente
                          //         _folioPresupuestoController.text =
                          //             value.toUpperCase();
                          //         _folioPresupuestoController.selection =
                          //             TextSelection.collapsed(
                          //                 offset: value.length);
                          //       }
                          //     },
                          //   ),
                          // ),
                          // const SizedBox(width: 20),
                          Expanded(
                              child: CustomTextFielTexto(
                            controller: _folioOSTController,
                            labelText: 'Orden de Servicio Técnico',
                            prefixIcon: Icons.border_outer_outlined,
                            validator: (ost) {
                              if (ost == null || ost.isEmpty) {
                                return 'Introduzca la orden de servicio técnico';
                              }
                              return null;
                            },
                          )),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CustomListaDesplegable(
                              value: _selectedTipoTrabajo,
                              labelText: 'Tipo de trabajo',
                              items: _tipoTrabajos,
                              onChanged: (trabajo) {
                                setState(() {
                                  _selectedTipoTrabajo = trabajo;
                                });
                              },
                              validator: (trabajo) {
                                if (trabajo == null || trabajo.isEmpty) {
                                  return 'Seleccione un tipo de trabajo.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CustomListaDesplegableTipo<Almacenes>(
                              value: _selectedAlmacen,
                              labelText: 'Almacen',
                              items: _almacenes,
                              onChanged: (ent) {
                                setState(() {
                                  _selectedAlmacen = ent;
                                });
                              },
                              validator: (ent) {
                                if (ent == null) {
                                  return 'Debe seleccionar una almacen.';
                                }
                                return null;
                              },
                              itemLabelBuilder: (ent) =>
                                  ent.almacen_Nombre ?? 'Sin nombre',
                            ),
                          ),
                          const SizedBox(width: 20),

                          //Junta destino
                          Expanded(
                            child: CustomAutocompleteField<Juntas>(
                              value: _selectedJunta,
                              labelText: 'Junta Destino',
                              items: _juntas,
                              prefixIcon: Icons.search,
                              onChanged: (junta) {
                                setState(() {
                                  _selectedJunta = junta;
                                });
                                _recalcularPreciosPorCambioDeJunta();
                              },
                              itemLabelBuilder: (junta) =>
                                  '${junta.id_Junta ?? 0} - ${junta.junta_Name ?? 'N/A'}',
                              itemValueBuilder: (junta) =>
                                  junta.id_Junta.toString(),
                              validator: (junta) {
                                if (junta == null) {
                                  return 'Debe seleccionar una junta destino.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _imagenOrden != null
                                    ? Image.memory(
                                        _imagenOrden!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : const Text(
                                        'No se ah seleccionado ninguna orden',
                                        textAlign: TextAlign.center,
                                      ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                    onPressed: _seleccionarImagen,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900),
                                    icon: const Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Seleccionar orden',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          //  Empleados
                          Expanded(
                            child: CustomAutocompleteField<Users>(
                              value: _selectedEmpleado,
                              labelText: 'Buscar Empleado',
                              items: _empleados,
                              prefixIcon: Icons.person,
                              onChanged: (empleados) {
                                setState(() {
                                  _selectedEmpleado = empleados;
                                });
                              },
                              itemLabelBuilder: (empleado) =>
                                  '${empleado.id_User} - ${empleado.user_Name}',
                              itemValueBuilder: (empleado) =>
                                  empleado.id_User.toString(),
                              validator: (value) {
                                if (_selectedEmpleado == null) {
                                  return 'Seleccione un empleado válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          //  Autoriza
                          Expanded(
                            child: CustomAutocompleteField<Users>(
                              value: _selectedAutoriza,
                              labelText: 'Buscar Autorizador',
                              items: _listaAutoriza,
                              prefixIcon: Icons.person,
                              onChanged: (autoriza) {
                                setState(() {
                                  _selectedAutoriza = autoriza;
                                });
                              },
                              itemLabelBuilder: (autoriza) =>
                                  '${autoriza.id_User} - ${autoriza.user_Name}',
                              itemValueBuilder: (autoriza) =>
                                  autoriza.id_User.toString(),
                              validator: (autoriza) {
                                if (_selectedAutoriza == null) {
                                  return 'Seleccione quien autoriza';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          //  Comentario
                          Expanded(
                              child: CustomTextFielTexto(
                            controller: _comentarioController,
                            labelText: 'Comentario*',
                            prefixIcon: Icons.remove_red_eye,
                          )),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '¿Agregar presupuesto?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    ToggleButtons(
                                      isSelected: [
                                        _mostrarPresupuesto,
                                        !_mostrarPresupuesto
                                      ],
                                      onPressed: (index) {
                                        setState(() {
                                          _mostrarPresupuesto = index == 0;
                                          if (!_mostrarPresupuesto) {
                                            // Limpiar datos del presupuesto cuando se desactiva
                                            _presupuestosSeleccionados.clear();
                                            _padronPresupuesto = null;
                                            _folioPresupuestoController.text =
                                                'PRE';
                                            _selectedPadron = null;
                                            _idPadronController.clear();
                                          }
                                        });
                                      },
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text('Sí')),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text('No')),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    if (_mostrarPresupuesto)
                                      Expanded(
                                        child: CustomTextFielTexto(
                                          controller:
                                              _folioPresupuestoController,
                                          prefixIcon: Icons.receipt,
                                          labelText:
                                              'Folio de presupuesto (ej, PRE1)',
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'\s')),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-zA-Z0-9]')),
                                          ],
                                          validator: (folio) {
                                            if (_mostrarPresupuesto &&
                                                (folio == null ||
                                                    folio.isEmpty ||
                                                    folio.length < 4)) {
                                              return 'Ingrese un folio válido (ej: PRE1)';
                                            }
                                            if (_mostrarPresupuesto &&
                                                !folio!
                                                    .toUpperCase()
                                                    .startsWith('PRE')) {
                                              return 'El folio debe comenzar con "PRE"';
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (value) {
                                            if (_mostrarPresupuesto &&
                                                value.isNotEmpty &&
                                                value
                                                    .toUpperCase()
                                                    .startsWith('PRE')) {
                                              _buscarPrespuestoByFolio();
                                            }
                                          },
                                          onChanged: (value) {
                                            if (_mostrarPresupuesto &&
                                                value.isNotEmpty) {
                                              if (!value
                                                  .toUpperCase()
                                                  .startsWith('PRE')) {
                                                if (value.length < 3) {
                                                  _folioPresupuestoController
                                                      .text = 'PRE';
                                                  _folioPresupuestoController
                                                          .selection =
                                                      const TextSelection
                                                          .collapsed(offset: 3);
                                                } else {
                                                  final cleanedValue =
                                                      'PRE${value.substring(3)}';
                                                  _folioPresupuestoController
                                                          .text =
                                                      cleanedValue
                                                          .toUpperCase();
                                                  _folioPresupuestoController
                                                          .selection =
                                                      TextSelection.collapsed(
                                                          offset: cleanedValue
                                                              .length);
                                                }
                                              } else if (value.isNotEmpty) {
                                                _folioPresupuestoController
                                                    .text = value.toUpperCase();
                                                _folioPresupuestoController
                                                        .selection =
                                                    TextSelection.collapsed(
                                                        offset: value.length);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text(
                                      '¿Agregar Contratista?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    ToggleButtons(
                                      isSelected: [
                                        _mostrarContratista,
                                        !_mostrarContratista
                                      ],
                                      onPressed: (index) {
                                        setState(() {
                                          _mostrarContratista = index == 0;
                                          if (!_mostrarPresupuesto) {
                                            _selectedContratista = null;
                                          }
                                        });
                                      },
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text('Sí')),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text('No')),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    if (_mostrarContratista) ...[
                                      Expanded(
                                        child: CustomAutocompleteField<
                                            Contratistas>(
                                          value: _selectedContratista,
                                          labelText: 'Buscar Contratista',
                                          items: _contratistas,
                                          prefixIcon: Icons.person,
                                          onChanged: (contratista) {
                                            setState(() {
                                              _selectedContratista =
                                                  contratista;
                                            });
                                          },
                                          itemLabelBuilder: (contratista) =>
                                              '${contratista.idContratista} - ${contratista.contratistaNombre}',
                                          itemValueBuilder: (contratista) =>
                                              contratista.idContratista
                                                  .toString(),
                                          validator: (value) {
                                            if (_selectedContratista == null) {
                                              return 'Seleccione un contratista válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     const SizedBox(width: 10),
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Row(
                      //             children: [
                      //               const Text(
                      //                 '¿Agregar orden de servicio?',
                      //                 style: TextStyle(
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: 16),
                      //               ),
                      //               const SizedBox(width: 10),
                      //               ToggleButtons(
                      //                 isSelected: [
                      //                   _mostrarOrdenServicio,
                      //                   !_mostrarOrdenServicio
                      //                 ],
                      //                 onPressed: (index) {
                      //                   setState(() {
                      //                     _mostrarOrdenServicio = index == 0;
                      //                     if (!_mostrarOrdenServicio) {
                      //                       _selectedOrdenServicio = null;
                      //                       _idColoniaController.clear();
                      //                       _idCalleController.clear();
                      //                       _idPadronController.clear();
                      //                       _selectedColonia = null;
                      //                       _selectedCalle = null;
                      //                       _selectedPadron = null;
                      //                     }
                      //                   });
                      //                 },
                      //                 children: const [
                      //                   Padding(
                      //                       padding: EdgeInsets.symmetric(
                      //                           horizontal: 16),
                      //                       child: Text('Sí')),
                      //                   Padding(
                      //                       padding: EdgeInsets.symmetric(
                      //                           horizontal: 16),
                      //                       child: Text('No')),
                      //                 ],
                      //               ),
                      //               const SizedBox(width: 20),
                      //               if (_mostrarOrdenServicio)
                      //                 Expanded(
                      //                   child: Row(
                      //                     children: [
                      //                       SizedBox(
                      //                         width: 300,
                      //                         child: CustomListaDesplegableTipo<
                      //                             OrdenServicio>(
                      //                           value: _selectedOrdenServicio,
                      //                           labelText: 'Orden de Servicio',
                      //                           items:
                      //                               _ordenesServicioAprobadas,
                      //                           onChanged:
                      //                               _onOrdenServicioSelected,
                      //                           validator: (orden) {
                      //                             if (_mostrarOrdenServicio &&
                      //                                 orden == null) {
                      //                               return 'Debe seleccionar una orden de servicio';
                      //                             }
                      //                             return null;
                      //                           },
                      //                           itemLabelBuilder: (orden) =>
                      //                               '${orden.folioOS} - ${orden.estadoOS} - ${orden.prioridadOS}',
                      //                         ),
                      //                       ),
                      //                       Expanded(
                      //                         child: Row(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.start,
                      //                           children: [
                      //                             IconButton(
                      //                               onPressed:
                      //                                   _cargarOrdenesAprobadas,
                      //                               icon: const Icon(
                      //                                   Icons.refresh),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      //const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          //Colonia
                          Expanded(
                            child: BuscarColoniaWidget(
                              idColoniaController: _idColoniaController,
                              coloniasController: _coloniasController,
                              selectedColonia: _selectedColonia,
                              onColoniaSeleccionada: (colonia) {
                                setState(() => _selectedColonia = colonia);
                              },
                              onAdvertencia: (message) {
                                showAdvertence(context, message);
                              },
                            ),
                          ),
                          const SizedBox(width: 20),

                          //Calle
                          Expanded(
                            child: BuscarCalleWidget(
                              idCalleController: _idCalleController,
                              callesController: _callesController,
                              selectedCalle: _selectedCalle,
                              onCalleSeleccionada: (calle) {
                                setState(() => _selectedCalle = calle);
                              },
                              onAdvertencia: (message) {
                                showAdvertence(context, message);
                              },
                            ),
                          ),

                          //  Buscar Padrón
                          if (!_mostrarPresupuesto) ...[
                            const SizedBox(width: 20),
                            Expanded(
                              child: BuscarPadronWidgetSalida(
                                idPadronController: _idPadronController,
                                padronController: _padronController,
                                selectedPadron: _selectedPadron,
                                onPadronSeleccionado: (padron) {
                                  setState(() {
                                    _selectedPadron = padron;
                                  });
                                },
                                onAdvertencia: (p0) {
                                  showAdvertence(context, p0);
                                },
                              ),
                            ),
                          ],

                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 30),

                      //  Buscar producto
                      if (!_mostrarPresupuesto) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
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
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Mostrar información del padrón del presupuesto
                      _buildInfoPadronPresupuesto(),

                      //Tabla productos agregados
                      buildProductosAgregadosSalidaX(
                        _productosAgregados,
                        eliminarProductoSalida,
                        mostrarEliminar: !_mostrarPresupuesto,
                      ),
                      const SizedBox(height: 30),

                      //Botón
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: (_isGeneratingPDF || _isLoading)
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isGeneratingPDF = true;
                                        _isLoading = true;
                                      });

                                      try {
                                        //1. Validar campos
                                        bool datosCompletos =
                                            await validarCamposAntesDeImprimirSalida(
                                          context: context,
                                          folioOST: _folioOSTController,
                                          productosAgregados:
                                              _productosAgregados,
                                          padron: _idPadronController,
                                          colonia: _idColoniaController,
                                          calle: _idCalleController,
                                          selectedAlmacen: _selectedAlmacen,
                                          selectedJunta: _selectedJunta,
                                          tipoTrabajo: _selectedTipoTrabajo,
                                          selectedUser: _selectedEmpleado,
                                          selectedUserAutoriza:
                                              _selectedAutoriza,
                                        );

                                        if (!datosCompletos) {
                                          return;
                                        }

                                        //2. Guardar registro
                                        await _guardarSalida();
                                      } catch (e) {
                                        showError(
                                            context, 'Error al guardar datos');
                                        print('Error al guardar datos: $e');
                                      } finally {
                                        setState(() {
                                          _isGeneratingPDF = false;
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                elevation: 8,
                                shadowColor: Colors.blue.shade900,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              child: (_isGeneratingPDF || _isLoading)
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
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Guardar y Generar PDF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isGeneratingPDF)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
          // Indicador de carga centrado
          if (_isGeneratingPDF)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Generando PDF...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onOrdenServicioSelected(OrdenServicio? orden) async {
    if (orden == null) return;

    setState(() {
      _selectedOrdenServicio = orden;
    });

    // Si la orden tiene datos de ubicación, buscamos y establecemos los valores correspondientes
    if (orden.idUserAsignado != null) {
      final userAsignado =
          await _usersController.getUserById(orden.idUserAsignado!);
      setState(() {
        _selectedEmpleado = userAsignado;
      });
    }

    if (orden.idColonia != null) {
      final colonia =
          await _coloniasController.getColoniaById(orden.idColonia!);
      setState(() {
        _selectedColonia = colonia;
        _idColoniaController.text = colonia?.idColonia.toString() ?? '';
      });
    }

    if (orden.idCalle != null) {
      final calle = await _callesController.getCalleById(orden.idCalle!);
      setState(() {
        _selectedCalle = calle;
        _idCalleController.text = calle?.idCalle.toString() ?? '';
      });
    }

    if (orden.idPadron != null) {
      final padron = await _padronController.getPadronById(orden.idPadron!);
      setState(() {
        _selectedPadron = padron;
        _idPadronController.text = padron?.idPadron.toString() ?? '';
      });
    }
  }
}
