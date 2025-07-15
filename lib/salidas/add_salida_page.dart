import 'package:flutter/material.dart';
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
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/buscar_calle_widget.dart';
import 'package:jmas_desktop/widgets/buscar_colonia_widget.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
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

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _busquedaUsuarioController =
      TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _idPadronController = TextEditingController();
  final TextEditingController _idColoniaController = TextEditingController();
  final TextEditingController _idCalleController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

  final _showDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? idUserReporte;
  String? folioTR;
  String? codFolio;

  //Empleados
  List<Users> _empleadosFiltrados = [];
  bool _buscandoEmpleados = false;
  Users? _selectedEmpleado;

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
    _loadFolioSalida();
    _loadFolioTR();
    _cargarOrdenesAprobadas();
  }

  // Future<void> _seleccionarFecha(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
  //     });
  //   }
  // }

  Future<void> _loadFolioSalida() async {
    final fetchedCodFolio = await _salidasController.getNextSalidaCodFolio();
    setState(() {
      codFolio = fetchedCodFolio;
    });
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

    setState(() {
      _almacenes = almacenes;
      _juntas = juntas;
    });
  }

  Future<void> _buscarEmpleados(String query) async {
    if (query.isEmpty) {
      setState(() {
        _empleadosFiltrados = [];
      });
      return;
    }
    setState(() => _buscandoEmpleados = true);
    final resultados = await _usersController.getUserXNombre(query);

    final empleados =
        resultados.where((users) => users.user_Rol == "Empleado").toList();
    setState(() {
      _empleadosFiltrados = empleados;
      _buscandoEmpleados = false;
    });
  }

  Future<void> _cargarOrdenesAprobadas() async {
    setState(() => _cargandoOrdenes = true);
    try {
      final todasOrdenes = await _ordenServicioController.listOrdenServicio();
      setState(() {
        _ordenesServicioAprobadas = todasOrdenes
            .where((orden) =>
                orden.estadoOS == 'Aprobada - S/A' ||
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
        final double precioUnitario = _selectedProducto!.prodPrecio ?? 0.0;
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': precioUnitario,
          'cantidad': cantidad,
          'precio': precioTotal
        });

        //Limpiar campos despuués de agregar
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
      for (var producto in _productosAgregados) {
        await _getUserId();

        //Crear salida
        final nuevaSalida = _crearSalida(producto);
        bool result = await _salidasController.addSalida(nuevaSalida);

        if (!result) {
          success = false;
          break; // Si hay error, no procesamos más productos y mostramos el error
        }

        if (producto['id'] == null) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Id nulo: ${producto['id_Producto']}, no se puede continuar');
          success = false;
          break;
        }

        final productoActualizado =
            await _productosController.getProductoById(producto['id']);

        if (productoActualizado == null) {
          // ignore: use_build_context_synchronously
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
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Error al actualizar las existencias del producto con ID ${producto['id_Producto']}');
          success = false;
          break;
        }
      }

      if (success && _selectedOrdenServicio != null) {
        final trabajoCreado = await _crearTrabajo();

        if (!trabajoCreado) {
          showAdvertence(context, 'Error al crear registro de servicio');
        }

        _selectedOrdenServicio!.estadoOS = "Aprobada - A";
        final estadoOrden = await _ordenServicioController
            .editOrdenServicio(_selectedOrdenServicio!);

        if (!estadoOrden) {
          showAdvertence(context, 'Error al actualizar estado de la orden');
        }
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Salida creada exitosamente.');
        setState(() {
          _isLoading = false;
          _loadFolioSalida();
          _loadFolioTR();
        });
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar salida');
        setState(() {
          _isLoading = false;
        });
      }

      _limpiarFormulario();
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
      salida_CodFolio: codFolio,
      salida_Referencia: _referenciaController.text,
      salida_Estado: true,
      salida_Unidades: double.tryParse(producto['cantidad'].toString()),
      salida_Costo: double.tryParse(
          (producto['precio'] * producto['cantidad']).toString()),
      salida_Fecha: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      salida_TipoTrabajo: _selectedTipoTrabajo,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!), // Usuario
      id_Junta: _selectedJunta?.id_Junta,
      id_Almacen: _selectedAlmacen?.id_Almacen ?? 0, // Almacen
      id_User_Asignado: _selectedEmpleado?.id_User,
      idPadron: _selectedPadron?.idPadron,
      idCalle: _selectedCalle?.idCalle,
      idColonia: _selectedColonia?.idColonia,
      idOrdenServicio: _selectedOrdenServicio?.idOrdenServicio,
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
      _selectedOrdenServicio = null;

      _referenciaController.clear();
      _idProductoController.clear();
      _idColoniaController.clear();
      _idCalleController.clear();
      _idPadronController.clear();
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
                            child: buildCabeceraItem(
                                'Movimiento', codFolio ?? 'Cargando...'),
                          ),
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
                            child: CustomTextFielTexto(
                              controller: _referenciaController,
                              labelText: 'Referencia',
                              validator: (p0) {
                                if (p0 == null || p0.isEmpty) {
                                  return 'Referencia obligatoria.';
                                }
                                return null;
                              },
                            ),
                          ),
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
                            child: CustomListaDesplegableTipo<Juntas>(
                              value: _selectedJunta,
                              labelText: 'Junta Destino',
                              items: _juntas,
                              onChanged: (junta) {
                                setState(() {
                                  _selectedJunta = junta;
                                });
                              },
                              validator: (junta) {
                                if (junta == null) {
                                  return 'Debe seleccionar una junta destino.';
                                }
                                return null;
                              },
                              itemLabelBuilder: (junta) =>
                                  '${junta.junta_Name} - (${junta.id_Junta})',
                            ),
                          ),
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
                                // Row(
                                //   children: [
                                //     const Text(
                                //       '¿Agregar orden de servicio?',
                                //       style: TextStyle(
                                //           fontWeight: FontWeight.bold,
                                //           fontSize: 16),
                                //     ),
                                //     const SizedBox(width: 10),
                                //     ToggleButtons(
                                //       isSelected: [
                                //         _mostrarOrdenServicio,
                                //         !_mostrarOrdenServicio
                                //       ],
                                //       onPressed: (index) {
                                //         setState(() {
                                //           _mostrarOrdenServicio = index == 0;
                                //           if (!_mostrarOrdenServicio) {
                                //             _selectedOrdenServicio = null;
                                //           }
                                //         });
                                //       },
                                //       children: const [
                                //         Padding(
                                //           padding: EdgeInsets.symmetric(
                                //               horizontal: 16),
                                //           child: Text('Sí'),
                                //         ),
                                //         Padding(
                                //           padding: EdgeInsets.symmetric(
                                //               horizontal: 16),
                                //           child: Text('No'),
                                //         ),
                                //       ],
                                //     ),
                                //     const SizedBox(width: 20),
                                //     if (_mostrarOrdenServicio)
                                //       Expanded(
                                //         child: Row(
                                //           children: [
                                //             SizedBox(
                                //               width: 300,
                                //               child: CustomListaDesplegableTipo<
                                //                   OrdenServicio>(
                                //                 value: _selectedOrdenServicio,
                                //                 labelText: 'Orden de Servicio',
                                //                 items:
                                //                     _ordenesServicioAprobadas,
                                //                 onChanged: (orden) {
                                //                   setState(() {
                                //                     _selectedOrdenServicio =
                                //                         orden;
                                //                   });
                                //                 },
                                //                 validator: (orden) {
                                //                   if (_mostrarOrdenServicio &&
                                //                       orden == null) {
                                //                     return 'Debe seleccionar una orden de servicio';
                                //                   }
                                //                   return null;
                                //                 },
                                //                 itemLabelBuilder: (orden) =>
                                //                     '${orden.folioOS} - ${orden.estadoOS} - ${orden.prioridadOS}',
                                //               ),
                                //             ),
                                //             Expanded(
                                //               child: Row(
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment.start,
                                //                 children: [
                                //                   IconButton(
                                //                     onPressed:
                                //                         _cargarOrdenesAprobadas,
                                //                     icon: const Icon(
                                //                         Icons.refresh),
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //   ],
                                // ),
                                const SizedBox(height: 20),

                                //Buscar Empleado
                                CustomTextFielTexto(
                                  controller: _busquedaUsuarioController,
                                  labelText: 'Buscar Empleado',
                                  onChanged: _buscarEmpleados,
                                  validator: (value) {
                                    if (_selectedEmpleado == null) {
                                      return 'Seleccione un empleado válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                if (_buscandoEmpleados)
                                  const CircularProgressIndicator(),
                                if (_empleadosFiltrados.isNotEmpty)
                                  Card(
                                    elevation: 3,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _empleadosFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final empleado =
                                              _empleadosFiltrados[index];
                                          return ListTile(
                                            leading: const Icon(
                                              Icons.person,
                                              color: Colors.blue,
                                            ),
                                            title: Text(
                                              empleado.user_Name ??
                                                  'Sin Nombre',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              'ID: ${empleado.id_User}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedEmpleado = empleado;
                                                _empleadosFiltrados = [];
                                                _busquedaUsuarioController
                                                    .clear();
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                if (_selectedEmpleado != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Chip(
                                      label: Text(
                                        _selectedEmpleado!.user_Name ??
                                            'Empleado seleccionado',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      backgroundColor: Colors.blue.shade800,
                                      deleteIcon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedEmpleado = null;
                                          _busquedaUsuarioController.clear();
                                        });
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 20),
                              ],
                            ),
                          ),
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
                                            await validarCamposAntesDeImprimir(
                                          context: context,
                                          productosAgregados:
                                              _productosAgregados,
                                          referenciaController:
                                              _referenciaController,
                                          padron: _idPadronController,
                                          colonia: _idColoniaController,
                                          calle: _idCalleController,
                                          selectedAlmacen: _selectedAlmacen,
                                          selectedJunta: _selectedJunta,
                                          selectedUser: _selectedEmpleado,
                                        );

                                        if (!datosCompletos) {
                                          return;
                                        }

                                        //2. Generar PDF
                                        await generarPdfSalida(
                                          movimiento: 'Salida',
                                          fecha: _fechaController.text,
                                          folio: codFolio!,
                                          referencia:
                                              _referenciaController.text,
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
                                          productos: _productosAgregados,
                                        );

                                        //3. Guardar registro
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
}
