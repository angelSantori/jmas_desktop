import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/calles_controller.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
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

  final CapturainviniController _capturainviniController =
      CapturainviniController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _idPadronController = TextEditingController();
  final TextEditingController _idColoniaController = TextEditingController();
  final TextEditingController _idCalleController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));

  String? idUserReporte;

  String? codFolio;

  List<Almacenes> _almacenes = [];
  // ignore: unused_field
  List<Juntas> _juntas = [];
  List<Users> _users = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Almacenes? _selectedAlmacen;
  // ignore: unused_field
  Juntas? _selectedJunta;
  Productos? _selectedProducto;
  Colonias? _selectedColonia;
  Calles? _selectedCalle;
  Users? _selectedUser;
  Padron? _selectedPadron;

  bool _isLoading = false;
  bool _isGeneratingPDF = false;

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
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _loadFolioSalida() async {
    final fetchedCodFolio = await _salidasController.getNextSalidaCodFolio();
    setState(() {
      codFolio = fetchedCodFolio;
    });
  }

  Future<void> _loadDataSalidas() async {
    List<Almacenes> almacenes = await _almacenesController.listAlmacenes();
    List<Juntas> juntas = await _juntasController.listJuntas();
    List<Users> users = await _usersController.listUsers();

    //Filtro usuario donde rol sea empleado
    List<Users> empleados =
        users.where((user) => user.user_Rol == "Empleado").toList();
    setState(() {
      _almacenes = almacenes;
      _juntas = juntas;
      _users = empleados;
    });
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
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      // Obtener el valor de invIniConteo desde Capturainvini
      final capturaList = await _capturainviniController.listCapturaI();
      final captura = capturaList.firstWhere(
        (captura) => captura.id_Producto == _selectedProducto!.id_Producto,
        orElse: () => Capturainvini(invIniConteo: 0.0),
      );

      final double invIniConteo = captura.invIniConteo ?? 0.0;

      if (cantidad > (invIniConteo)) {
        showAdvertence(context,
            'La cantidad no puede ser mayor a la existencia del producto.');
        return;
      }

      final double nuevaExistencia = invIniConteo - cantidad;
      final double totalDeficit =
          nuevaExistencia - (_selectedProducto!.prodMin!);

      if (nuevaExistencia < (_selectedProducto!.prodMin!)) {
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
      setState(() {
        _isLoading = true;
      });
      bool success = true; // Para verificar si al menos una entrada fue exitosa
      for (var producto in _productosAgregados) {
        await _getUserId();
        final nuevaSalida = _crearSalida(producto);
        print('Cuerpo enviado: $nuevaSalida');
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

        // Actualizar las existencias en la tabla Capturainvini
        final capturaList = await _capturainviniController.listCapturaI();
        final captura = capturaList.firstWhere(
          (captura) => captura.id_Producto == producto['id'],
          orElse: () => Capturainvini(
            id_Producto: producto['id'],
            invIniConteo: 0.0,
          ),
        );

        final nuevaCantidadCaptura =
            (captura.invIniConteo ?? 0.0) - producto['cantidad'];

        final updatedCaptura = captura.copyWith(
          invIniConteo: nuevaCantidadCaptura,
        );

        bool capturaResult =
            await _capturainviniController.editCapturaI(updatedCaptura);

        if (!capturaResult) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Error al actualizar las existencias en Capturainvini para el producto con ID ${producto['id']}');
          success = false;
          break;
        }
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Salida creada exitosamente.');
        setState(() {
          _isLoading = false;
          _loadFolioSalida();
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
      salida_Fecha: _fechaController.text,
      salida_TipoTrabajo: _selectedTipoTrabajo,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!), // Usuario
      id_Junta: 1, // Junta
      id_Almacen: _selectedAlmacen?.id_Almacen ?? 0, // Almacen
      id_User_Asignado: _selectedUser?.id_User,
      idPadron: _selectedPadron?.idPadron,
      idCalle: _selectedCalle?.idCalle,
      idColonia: _selectedColonia?.idColonia,
    );
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
  
      _selectedUser = null;
      _selectedTipoTrabajo = null;
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            child:
                                buildCabeceraItem('Captura', widget.userName!),
                          ),
                          Expanded(
                            child: buildCabeceraItem('Junta', 'Meoqui'),
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
                          const SizedBox(width: 30),
                          Expanded(
                            child: CustomTextFielFecha(
                              controller: _fechaController,
                              labelText: 'Fecha',
                              onTap: () => _seleccionarFecha(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Debe seleccionar una fecha';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 30),
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
                            child: CustomListaDesplegableTipo(
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
                          const SizedBox(width: 30),
                          Expanded(
                            child: CustomListaDesplegableTipo(
                              value: _selectedUser,
                              labelText: 'Asignar empleado',
                              items: _users,
                              onChanged: (user) {
                                setState(() {
                                  _selectedUser = user;
                                });
                              },
                              validator: (user) {
                                if (user == null) {
                                  return 'Debe asignar un empleado.';
                                }
                                return null;
                              },
                              itemLabelBuilder: (user) =>
                                  user.user_Name ?? 'Sin nombre',
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
                              capturainviniController: _capturainviniController,
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

                      //Botón para agregar producto a la tabla
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     ElevatedButton.icon(
                      //       onPressed: _agregarProducto,
                      //       icon: const Icon(
                      //         Icons.add,
                      //         color: Colors.white,
                      //       ),
                      //       label: const Text(
                      //         'Agregar',
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.blue.shade900,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),

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
                                          selectedUser: _selectedUser,
                                          selectedTrabajo: _selectedTipoTrabajo,
                                        );

                                        if (!datosCompletos) {
                                          return;
                                        }

                                        //2. Generar PDF
                                        await generateAndPrintPdfSalida(
                                          movimiento: 'Salida',
                                          fecha: _fechaController.text,
                                          folio: codFolio!,
                                          referencia:
                                              _referenciaController.text,
                                          userName: widget.userName!,
                                          idUser: widget.idUser!,
                                          alamcenA: _selectedAlmacen!,
                                          userAsignado: _selectedUser!,
                                          tipoTrabajo: _selectedTipoTrabajo!,
                                          padron: _selectedPadron!,
                                          colonia: _selectedColonia!,
                                          calle: _selectedCalle!,
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
