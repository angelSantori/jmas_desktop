import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/orden_servicio_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/trabajo_realizado_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/salidas/widgets/pdf_salida.dart';
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

  final _formKey = GlobalKey<FormState>();

  //final TextEditingController _referenciaController = TextEditingController();
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

  List<Almacenes> _almacenes = [];
  List<Juntas> _juntas = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Almacenes? _selectedAlmacen;
  Juntas? _selectedJunta;
  Productos? _selectedProducto;
  Colonias? _selectedColonia;
  Calles? _selectedCalle;
  Padron? _selectedPadron;

  bool _isLoading = false;
  bool _isGeneratingPDF = false;
  bool _mostrarOrdenServicio = false;

  Uint8List? _imagenOrden;

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

    setState(() {
      _almacenes = almacenes;
      _juntas = juntas;
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

        // Aplicar descuento del 60% si el producto es 40050569 o 40050570
        // y la junta NO es 1, 6, 8 o 14
        if ((_selectedProducto!.id_Producto == 40050558 ||
                _selectedProducto!.id_Producto == 40050559) &&
            _selectedJunta != null &&
            ![1, 6, 8, 14].contains(_selectedJunta!.id_Junta)) {
          precioUnitario = precioUnitario *
              0.4; // 60% de descuento (40% del precio original)
        }

        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': precioUnitario,
          'cantidad': cantidad,
          'precio': precioTotal,
          'descuento_aplicado': (precioUnitario !=
              _selectedProducto!.prodCosto) // Marcar si se aplicó descuento
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
      salida_Referencia: null,
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
      _imagenOrden = null;
      _selectedOrdenServicio = null;
      _mostrarOrdenServicio = false;

      //_referenciaController.clear();
      _busquedaUsuarioController.clear();
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
                                      '¿Agregar orden de servicio?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    ToggleButtons(
                                      isSelected: [
                                        _mostrarOrdenServicio,
                                        !_mostrarOrdenServicio
                                      ],
                                      onPressed: (index) {
                                        setState(() {
                                          _mostrarOrdenServicio = index == 0;
                                          if (!_mostrarOrdenServicio) {
                                            _selectedOrdenServicio = null;
                                            _idColoniaController.clear();
                                            _idCalleController.clear();
                                            _idPadronController.clear();
                                            _selectedColonia = null;
                                            _selectedCalle = null;
                                            _selectedPadron = null;
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
                                    if (_mostrarOrdenServicio)
                                      Expanded(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 300,
                                              child: CustomListaDesplegableTipo<
                                                  OrdenServicio>(
                                                value: _selectedOrdenServicio,
                                                labelText: 'Orden de Servicio',
                                                items:
                                                    _ordenesServicioAprobadas,
                                                onChanged:
                                                    _onOrdenServicioSelected,
                                                validator: (orden) {
                                                  if (_mostrarOrdenServicio &&
                                                      orden == null) {
                                                    return 'Debe seleccionar una orden de servicio';
                                                  }
                                                  return null;
                                                },
                                                itemLabelBuilder: (orden) =>
                                                    '${orden.folioOS} - ${orden.estadoOS} - ${orden.prioridadOS}',
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    onPressed:
                                                        _cargarOrdenesAprobadas,
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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

                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const SizedBox(height: 30),

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
                      const SizedBox(height: 10),

                      //Tabla productos agregados
                      buildProductosAgregados(
                        _productosAgregados,
                        eliminarProductoSalida,
                        actualizarCostoSalida,
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
                                          productosAgregados:
                                              _productosAgregados,
                                          //referenciaController: _referenciaController,
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
