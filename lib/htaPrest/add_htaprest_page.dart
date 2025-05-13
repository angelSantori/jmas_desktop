import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/herramientas_controller.dart';
import 'package:jmas_desktop/contollers/htaprestamo_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_prestamo_widget.dart';

class AddHtaprestPage extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddHtaprestPage({super.key, this.userName, this.idUser});

  @override
  State<AddHtaprestPage> createState() => _AddHtaprestPageState();
}

class _AddHtaprestPageState extends State<AddHtaprestPage> {
  final AuthService _authService = AuthService();
  final HtaprestamoController _htaprestamoController = HtaprestamoController();

  final HerramientasController _herramientasController =
      HerramientasController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fechaPrestamoController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()));
  final TextEditingController _fechaDevolucionController =
      TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _busquedaUsuarioController =
      TextEditingController();

  String? idUserReporte;
  String? codFolio;

  List<Herramientas> _herramientasDisponibles = [];
  final List<Map<String, dynamic>> _herramientasPrestadas = [];
  Herramientas? _selectedHerramienta;

  bool _isLoading = false;

  //Users
  final UsersController _usersController = UsersController();
  Users? _selectedEmpleado;
  List<Users> _empleadosFiltrados = [];
  bool _buscandoEmpleados = false;

  //Externos
  final TextEditingController _externoNombreController =
      TextEditingController();
  final TextEditingController _externoContactoController =
      TextEditingController();
  bool _esExterno = false;

  @override
  void initState() {
    super.initState();
    _loadCodFolio();
    _loadHerramientasDisponibles();
    _getUserId();
  }

  Future<void> _loadCodFolio() async {
    final fetchedCodFolio = await _htaprestamoController.nextPrestCodFolio();
    setState(() {
      codFolio = fetchedCodFolio;
    });
  }

  Future<void> _loadHerramientasDisponibles() async {
    setState(() => _isLoading = true);
    final herramientas =
        await _herramientasController.getHtasXEstado("Disponible");
    setState(() {
      _herramientasDisponibles = herramientas;
      _isLoading = false;
    });
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    setState(() {
      idUserReporte = decodeToken?['Id_User'] ?? '0';
    });
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esPrestamo) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (esPrestamo) {
          _fechaPrestamoController.text =
              DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _fechaDevolucionController.text =
              DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
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

  void _agregarHerramienta() async {
    if (_selectedHerramienta != null) {
      setState(() {
        _herramientasPrestadas.add({
          'id': _selectedHerramienta!.idHerramienta,
          'nombre': _selectedHerramienta!.htaNombre,
          'fechaPrestamo': _fechaPrestamoController.text,
          'fechaDevolucion': _fechaDevolucionController.text.isEmpty
              ? 'Pendiente'
              : _fechaDevolucionController.text,
        });

        // Limpiar selección y campos
        _selectedHerramienta = null;
        _busquedaController.clear();
        _fechaDevolucionController.clear();
      });
    } else {
      showAdvertence(context, 'Debe seleccionar una herramienta');
    }
  }

  void _eliminarHerramienta(int index) {
    setState(() {
      _herramientasPrestadas.removeAt(index);
    });
  }

  Future<void> _guardarPrestamo() async {
    if (_herramientasPrestadas.isEmpty) {
      showAdvertence(context, 'Debe agregar al menos una herramienta');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = true;
      for (var herramienta in _herramientasPrestadas) {
        // Registrar el préstamo
        final nuevoPrestamo = HtaPrestamo(
            idHtaPrestamo: 0,
            prestCodFolio: codFolio,
            prestFechaPrest: herramienta['fechaPrestamo'],
            prestFechaDevol: herramienta['fechaDevolucion'] == 'Pendiente'
                ? ''
                : herramienta['fechaDevolucion'],
            externoNombre: _esExterno ? _externoNombreController.text : null,
            externoContacto:
                _esExterno ? _externoContactoController.text : null,
            idHerramienta: herramienta['id'],
            id_UserAsignado: _esExterno ? null : _selectedEmpleado?.id_User,
            idUserResponsable: int.tryParse(widget.idUser!));

        bool result = await _htaprestamoController.addHtaPrest(nuevoPrestamo);
        if (!result) {
          success = false;
          break;
        }

        // Cambiar estado de la herramienta a "Prestada"
        final herramientaActual =
            await _herramientasController.getHtaXId(herramienta['id']);
        if (herramientaActual != null) {
          final herramientaActualizada =
              herramientaActual.copyWith(htaEstado: 'Prestada');

          bool estadoCambiado =
              await _herramientasController.editHta(herramientaActualizada);
          if (!estadoCambiado) {
            success = false;
            break;
          }
        } else {
          success = false;
          break;
        }
      }

      if (success) {
        showOk(context, 'Préstamo registrado exitosamente');

        //Generar PDF del prestamo
        await generarPdfPrestamoHerramientas(
          folio: codFolio ?? 'Sin folio',
          fechaPrestamo: _fechaPrestamoController.text,
          fechaDevolucion:
              _herramientasPrestadas.first['fechaDevolucion'] ?? 'Pendiente',
          responsable: Users(
            id_User: int.tryParse(widget.idUser ?? '0'),
            user_Name: widget.userName,
          ),
          empleadoAsignado: _selectedEmpleado,
          externoNombre: _externoNombreController.text.isNotEmpty
              ? _externoNombreController.text
              : null,
          externoContacto: _externoContactoController.text.isNotEmpty
              ? _externoContactoController.text
              : null,
          herramientas: _herramientasPrestadas,
        );

        _limpiarFormulario();
        await _loadHerramientasDisponibles();
      } else {
        showError(context, 'Error al registrar algunos préstamos');
      }

      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _herramientasPrestadas.clear();
      _fechaDevolucionController.clear();
      _selectedHerramienta = null;
      _busquedaController.clear();
      _externoContactoController.clear();
      _externoNombreController.clear();
      _esExterno = false;
      _busquedaUsuarioController.clear();
      _selectedEmpleado = null;
    });
    _loadCodFolio();
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Préstamo de Herramientas'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera con información del préstamo
                  Row(
                    children: [
                      Expanded(
                        child: buildCabeceraItem(
                            'Folio', codFolio ?? 'Cargando...'),
                      ),
                      Expanded(
                        child: buildCabeceraItem(
                            'Responsable', widget.userName ?? ''),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielFecha(
                          controller: _fechaPrestamoController,
                          labelText: 'Fecha de Préstamo',
                          onTap: () => _seleccionarFecha(context, true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Fecha obligatoria';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: _esExterno,
                                  onChanged: (value) {
                                    setState(() {
                                      _esExterno = false;
                                      _externoContactoController.clear();
                                      _externoContactoController.clear();
                                    });
                                  },
                                ),
                                const Text('Empleado'),
                                const SizedBox(width: 20),
                                Radio<bool>(
                                  value: true,
                                  groupValue: _esExterno,
                                  onChanged: (value) {
                                    setState(() {
                                      _esExterno = true;
                                      _selectedEmpleado = null;
                                    });
                                  },
                                ),
                                const Text('Externo'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            //Empleados
                            if (!_esExterno)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextFielTexto(
                                    controller: _busquedaUsuarioController,
                                    labelText: 'Buscar Empleado',
                                    onChanged: _buscarEmpleados,
                                    validator: (value) {
                                      if (!_esExterno &&
                                          _selectedEmpleado == null) {
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
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _empleadosFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final empleado =
                                                _empleadosFiltrados[index];
                                            return ListTile(
                                              leading: const Icon(Icons.person,
                                                  color: Colors.blue),
                                              title: Text(
                                                empleado.user_Name ??
                                                    'Sin nombre',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                empleado.user_Contacto ?? '',
                                                style: const TextStyle(
                                                    fontSize: 12),
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
                                              color: Colors.white,
                                              fontSize: 20),
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
                                ],
                              ),
                            if (_esExterno) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextFielTexto(
                                      controller: _externoNombreController,
                                      labelText: 'Nombre de externo',
                                      validator: (value) {
                                        if (_esExterno &&
                                            (value == null || value.isEmpty)) {
                                          return 'Nombre obligatorio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: CustomTextFielTexto(
                                      controller: _externoContactoController,
                                      labelText: 'Contacto de externo',
                                      validator: (value) {
                                        if (_esExterno &&
                                            (value == null || value.isEmpty)) {
                                          return 'Contacto obligatorio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Búsqueda y selección de herramientas
                  Row(
                    children: [
                      Expanded(
                        child: CustomAutocomplete<Herramientas>(
                          controller: _busquedaController,
                          labelText: 'Buscar Herramienta',
                          options: _herramientasDisponibles,
                          displayStringForOption: (option) =>
                              option.htaNombre ?? '',
                          onSelected: (selection) {
                            setState(() {
                              _selectedHerramienta = selection;
                            });
                          },
                          onSelectionConfirmed: _agregarHerramienta,
                          clearOnSelect: true,
                          validator: (value) {
                            if (_selectedHerramienta == null &&
                                value!.isNotEmpty) {
                              return 'Seleccione una herramienta válida';
                            }
                            return null;
                          },
                        ),
                      ),
                      // const SizedBox(width: 10),
                      // ElevatedButton(
                      //   onPressed: _agregarHerramienta,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blue.shade900,
                      //   ),
                      //   child: const Text('Agregar',
                      //       style: TextStyle(color: Colors.white)),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Lista de herramientas prestadas
                  if (_herramientasPrestadas.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Herramientas en préstamo:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ..._herramientasPrestadas.map(
                              (herramienta) => ListTile(
                                title: Text(herramienta['nombre']),
                                subtitle: Text(
                                  'Préstamo: ${herramienta['fechaPrestamo']}\n'
                                  'Devolución: ${herramienta['fechaDevolucion']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _eliminarHerramienta(
                                      _herramientasPrestadas
                                          .indexOf(herramienta)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Botón de guardar
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarPrestamo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Registrar Préstamo',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
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
