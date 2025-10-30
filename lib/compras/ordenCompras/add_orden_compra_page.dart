import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/orden_compra_controller.dart';
import 'package:jmas_desktop/contollers/proveedores_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_orden_compra.dart';

class AddOrdenCompraPage extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddOrdenCompraPage({super.key, this.userName, this.idUser});

  @override
  State<AddOrdenCompraPage> createState() => _AddOrdenCompraPageState();
}

class _AddOrdenCompraPageState extends State<AddOrdenCompraPage> {
  final OrdenCompraController _ordenCompraController = OrdenCompraController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _requisicionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _fechaEntregaController = TextEditingController();
  final TextEditingController _busquedaProveedorController =
      TextEditingController();

  List<ArticuloOrdenCompra> _articulos = [];
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioUnitarioController =
      TextEditingController();

  String? _codFolioOC;
  final String _showFecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  DateTime? _selectedFechaEntrega;

  String? _selectedCentroCosto;
  final List<String> _listCentroCostos = [
    'CC1',
    'CC2',
    'CC3',
    'CC4',
  ];

  String? _selectedCentroBeneficio;
  final List<String> _listCentroBeneficio = [
    'CB1',
    'CB2',
    'CB3',
    'CB4',
  ];

  String? _selectedUnidadMedida;
  final List<String> _listUnidadesMedida = [
    'Pieza',
    'Kilo',
    'Metro',
    'Otro',
  ];

  bool _isLoading = false;

  List<Proveedores> _proveedoresFiltrados = [];
  bool _buscandoProveedores = false;
  Proveedores? _selectedProveedor;

  // Variables para controlar el estado de habilitación de los campos
  bool _requisicionCompleta = false;
  bool _proveedorCompleto = false;
  bool _fechaEntregaCompleta = false;
  bool _direccionCompleta = false;
  bool _centroCostoCompleto = false;
  bool _centroBeneficioCompleto = false;
  bool _articulosAgregados = false;

  @override
  void initState() {
    super.initState();
    _loadFolioOC();
  }

  //Eliminar Artículo
  void _eliminarArticulo(int index) {
    setState(() {
      _articulos.removeAt(index);
      _articulosAgregados = _articulos.isNotEmpty;
      _updateGuardarButtonState();
    });
  }

  //Agregar Artículo
  void _agregarArticulo() {
    if (_descripcionController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _precioUnitarioController.text.isEmpty ||
        _selectedUnidadMedida == null) {
      showAdvertence(context, 'Complete todos los campos del artículo');
      return;
    }

    setState(() {
      _articulos.add(ArticuloOrdenCompra(
        descripcion: _descripcionController.text,
        cantidad: double.parse(_cantidadController.text),
        unidadMedida: _selectedUnidadMedida!,
        precioUnitario: double.parse(_precioUnitarioController.text),
      ));

      // Limpiar campos
      _descripcionController.clear();
      _cantidadController.clear();
      _precioUnitarioController.clear();
      _selectedUnidadMedida = null;

      _articulosAgregados = true;
      _updateGuardarButtonState();
    });
  }

  Future<void> _loadFolioOC() async {
    final fetchFolioOC = await _ordenCompraController.getNextOCFolio();
    setState(() => _codFolioOC = fetchFolioOC);
  }

  Future<void> _buscarProveedores(String query) async {
    if (query.isEmpty) {
      setState(() {
        _proveedoresFiltrados = [];
      });
      return;
    }
    setState(() => _buscandoProveedores = true);
    final resultados = await _proveedoresController.getProvXNombre(query);

    setState(() {
      _proveedoresFiltrados = resultados;
      _buscandoProveedores = false;
    });
  }

  //Selector de fecha
  Future<void> _selectFechaEntrega(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedFechaEntrega) {
      setState(() {
        _selectedFechaEntrega = picked;
        _fechaEntregaController.text = DateFormat('dd/MM/yyyy').format(picked);
        _fechaEntregaCompleta = true;
        _updateGuardarButtonState();
      });
    }
  }

  // Actualizar el estado del botón de guardar
  void _updateGuardarButtonState() {
    setState(() {
      // El botón se habilita solo cuando todos los campos requeridos están completos
    });
  }

  // Verificar si todos los campos requeridos están completos
  bool _todosCamposCompletos() {
    return _requisicionCompleta &&
        _proveedorCompleto &&
        _fechaEntregaCompleta &&
        _direccionCompleta &&
        _centroCostoCompleto &&
        _centroBeneficioCompleto &&
        _articulosAgregados;
  }

  Future<void> _mostrarDialogoAgregarProveedor() async {
    final nombreProveedor = _busquedaProveedorController.text;
    if (nombreProveedor.isEmpty) {
      showAdvertence(context, 'Ingrese el nombre del proveedor');
      return;
    }

    final nuevoProveedor = Proveedores(
      id_Proveedor: 0,
      proveedor_Name: nombreProveedor,
      proveedor_Address: '',
      proveedor_Phone: '',
    );

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Desea agregar el proveedor "$nombreProveedor"?'),
            const SizedBox(height: 20),
            const Text('Nota: Puede editar los detalles más tarde.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              elevation: 8,
              shadowColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text(
              'Agregar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      final success = await _proveedoresController.addProveedor(nuevoProveedor);
      if (success) {
        // Actualizar la lista de proveedores y seleccionar el nuevo
        final proveedores =
            await _proveedoresController.getProvXNombre(nombreProveedor);
        if (proveedores.isNotEmpty) {
          setState(() {
            _selectedProveedor = proveedores.first;
            _proveedorCompleto = true;
            _busquedaProveedorController.clear();
            _updateGuardarButtonState();
          });
          showOk(context, 'Proveedor agregado con éxito');
        }
      } else {
        showError(context, 'Error al agregar el proveedor');
      }
    }
  }

  Future<void> _guardarOrdenCompra() async {
    if (!_todosCamposCompletos()) {
      showAdvertence(context, 'Complete todos los campos requeridos');
      return;
    }

    setState(() => _isLoading = true);

    bool success = true;
    String? errorMessage;

    try {
      // Crear una orden de compra por cada artículo
      for (var articulo in _articulos) {
        final nuevaOrden = OrdenCompra(
          idOrdenCompra: 0,
          folioOC: _codFolioOC!,
          estadoOC: 'Pendiente',
          fechaOC: _showFecha,
          requisicionOC: int.parse(_requisicionController.text),
          fechaEntregaOC: _fechaEntregaController.text,
          direccionEntregaOC: _direccionController.text,
          centroCostoOC: _selectedCentroCosto!,
          centroBeneficioOC: _selectedCentroBeneficio!,
          descripcionOC: articulo.descripcion,
          cantidadOC: articulo.cantidad,
          unidadMedidaOC: articulo.unidadMedida,
          precioUnitarioOC: articulo.precioUnitario,
          totalOC: articulo.importeTotal,
          notasOC: _notasController.text,
          idProveedor: _selectedProveedor!.id_Proveedor!,
        );

        final result = await _ordenCompraController.addOrdenCompra(nuevaOrden);
        if (!result) {
          success = false;
          errorMessage =
              'Error al guardar el artículo: ${articulo.descripcion}';
          break;
        }
      }

      if (success) {
        showOk(context, 'Orden de compra creada exitosamente');

        // Convertir artículos a formato de mapa para el PDF
        List<Map<String, dynamic>> productosParaPDF =
            _articulos.map((articulo) {
          return {
            'descripcion': articulo.descripcion,
            'cantidad': articulo.cantidad,
            'unidadMedida': articulo.unidadMedida,
            'precioUnitario': articulo.precioUnitario,
            'importeTotal': articulo.importeTotal,
          };
        }).toList();

        // Generar PDF
        await generarPdfOrdenCompraFile(
          folioOC: _codFolioOC!,
          fechaOC: _showFecha,
          requisicionOC: _requisicionController.text,
          fechaEntregaOC: _fechaEntregaController.text,
          direccionEntregaOC: _direccionController.text,
          centroCostoOC: _selectedCentroCosto!,
          centroBeneficioOC: _selectedCentroBeneficio!,
          notasOC: _notasController.text,
          proveedorName: _selectedProveedor!.proveedor_Name ?? '',
          userName: widget.userName!,
          productos: productosParaPDF,
        );

        _limpiarFormulario();
        await _loadFolioOC();
      } else {
        showError(
            context, errorMessage ?? 'Error al guardar la orden de compra');
      }
    } catch (e) {
      showError(context, 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _articulos.clear();
      _selectedProveedor = null;
      _selectedCentroCosto = null;
      _selectedCentroBeneficio = null;
      _selectedFechaEntrega = null;
      _busquedaProveedorController.clear();
      _requisicionController.clear();
      _direccionController.clear();
      _fechaEntregaController.clear();
      _notasController.clear();

      // Resetear estados de validación
      _requisicionCompleta = false;
      _proveedorCompleto = false;
      _fechaEntregaCompleta = false;
      _direccionCompleta = false;
      _centroCostoCompleto = false;
      _centroBeneficioCompleto = false;
      _articulosAgregados = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal =
        _articulos.fold(0, (sum, item) => sum + item.importeTotal);
    double iva = subtotal * 0.16;
    double total = subtotal + iva;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Orden de Compra',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: buildCabeceraItem('Fecha', _showFecha)),
                            Expanded(
                                child: buildCabeceraItem(
                                    'Folio', _codFolioOC ?? 'Cargando...')),
                            Expanded(
                                child: buildCabeceraItem(
                                    'Captura', widget.userName!)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        //
                        const DividerWithText(text: 'Información General'),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            //Requisición
                            Expanded(
                              child: CustomTextFieldNumero(
                                controller: _requisicionController,
                                labelText: 'Requisición No.',
                                prefixIcon: Icons.numbers,
                                enabled: true, // Siempre habilitado
                                validator: (requisicion) {
                                  if (requisicion == null ||
                                      requisicion.isEmpty) {
                                    return 'Debe introducir un número de requisición';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _requisicionCompleta =
                                        value?.isNotEmpty ?? false;
                                    _updateGuardarButtonState();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 30),

                            //Proveedor
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextFielTexto(
                                    controller: _busquedaProveedorController,
                                    labelText: 'Buscar Proveedor',
                                    enabled: _requisicionCompleta,
                                    onChanged: (value) {
                                      _buscarProveedores(value);
                                      setState(() {
                                        _proveedorCompleto =
                                            _selectedProveedor != null;
                                        _updateGuardarButtonState();
                                      });
                                    },
                                    validator: (value) {
                                      if (_selectedProveedor == null) {
                                        return 'Seleccione un proveedor válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  if (_buscandoProveedores)
                                    const CircularProgressIndicator(),
                                  if (_proveedoresFiltrados.isNotEmpty &&
                                      _requisicionCompleta)
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
                                          itemCount:
                                              _proveedoresFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final proveedor =
                                                _proveedoresFiltrados[index];
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.business,
                                                color: Colors.blue,
                                              ),
                                              title: Text(
                                                proveedor.proveedor_Name ??
                                                    'Sin Nombre',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                'ID: ${proveedor.id_Proveedor}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _selectedProveedor =
                                                      proveedor;
                                                  _proveedoresFiltrados = [];
                                                  _busquedaProveedorController
                                                      .clear();
                                                  _proveedorCompleto = true;
                                                  _updateGuardarButtonState();
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  if (_proveedoresFiltrados.isEmpty &&
                                      _busquedaProveedorController
                                          .text.isNotEmpty)
                                    ListTile(
                                      title: Text(
                                          'No se encontró "${_busquedaProveedorController.text}"'),
                                      trailing: ElevatedButton(
                                        onPressed:
                                            _mostrarDialogoAgregarProveedor,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          elevation: 8,
                                          shadowColor: Colors.blue.shade900,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 15),
                                        ),
                                        child: const Text(
                                          'Agregar Proveedor',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_selectedProveedor != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Chip(
                                        label: Text(
                                          _selectedProveedor!.proveedor_Name ??
                                              'Proveedor seleccionado',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        backgroundColor: Colors.blue.shade800,
                                        deleteIcon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedProveedor = null;
                                            _busquedaProveedorController
                                                .clear();
                                            _proveedorCompleto = false;
                                            _updateGuardarButtonState();
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            //Fecha de entrega
                            Expanded(
                              child: CustomTextFielFecha(
                                controller: _fechaEntregaController,
                                labelText: 'Fecha de Entrega',
                                enabled: _proveedorCompleto,
                                onTap: () => _selectFechaEntrega(context),
                                validator: (fecha) {
                                  if (fecha == null || fecha.isEmpty) {
                                    return 'Debe seleccionar una fecha de entrega';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 30),

                            //Dirección de entrega
                            Expanded(
                              child: CustomTextFielTexto(
                                controller: _direccionController,
                                labelText: 'Dirección de Entrega',
                                prefixIcon: Icons.location_on,
                                enabled: _fechaEntregaCompleta,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la dirección de entrega';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _direccionCompleta =
                                        value?.isNotEmpty ?? false;
                                    _updateGuardarButtonState();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 30),

                        //Sección listas desplegables
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 10),
                            //Centro de Costo
                            Expanded(
                              child: CustomListaDesplegable(
                                value: _selectedCentroCosto,
                                labelText: 'Centro de Costo',
                                items: _listCentroCostos,
                                enabled: _direccionCompleta,
                                onChanged: (cc) {
                                  setState(() {
                                    _selectedCentroCosto = cc;
                                    _centroCostoCompleto = cc != null;
                                    _updateGuardarButtonState();
                                  });
                                },
                                validator: (cc) {
                                  if (cc == null || cc.isEmpty) {
                                    return 'Debe seleccionar un centro de costo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 30),

                            //Centro de Beneficio
                            Expanded(
                              child: CustomListaDesplegable(
                                value: _selectedCentroBeneficio,
                                labelText: 'Centro de Beneficio',
                                items: _listCentroBeneficio,
                                enabled: _centroCostoCompleto,
                                onChanged: (cb) {
                                  setState(() {
                                    _selectedCentroBeneficio = cb;
                                    _centroBeneficioCompleto = cb != null;
                                    _updateGuardarButtonState();
                                  });
                                },
                                validator: (cb) {
                                  if (cb == null || cb.isEmpty) {
                                    return 'Debe seleccionar un centro de beneficio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 60),

                        const DividerWithText(text: 'Artículos'),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Formulario para agregar artículos
                            Card(
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Descripción
                                        Expanded(
                                          flex: 3,
                                          child: CustomTextFielTexto(
                                            controller: _descripcionController,
                                            labelText: 'Descripción',
                                            enabled: _centroBeneficioCompleto,
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Cantidad
                                        Expanded(
                                          child: CustomTextFieldNumero(
                                            controller: _cantidadController,
                                            labelText: 'Cantidad',
                                            prefixIcon: Icons.numbers,
                                            enabled: _centroBeneficioCompleto,
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Unidad de medida
                                        Expanded(
                                          child: CustomListaDesplegable(
                                            value: _selectedUnidadMedida,
                                            labelText: 'Unidad de Medida',
                                            items: _listUnidadesMedida,
                                            enabled: _centroBeneficioCompleto,
                                            onChanged: (um) {
                                              setState(() {
                                                _selectedUnidadMedida = um;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        //Precio Unitario
                                        Expanded(
                                          flex: 3,
                                          child: CustomTextFieldNumero(
                                            controller:
                                                _precioUnitarioController,
                                            labelText: 'Precio Unitario',
                                            prefixIcon:
                                                Icons.attach_money_outlined,
                                            enabled: _centroBeneficioCompleto,
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Botón para agregar
                                        ElevatedButton(
                                          onPressed: _centroBeneficioCompleto
                                              ? _agregarArticulo
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            elevation: 8,
                                            shadowColor: Colors.blue.shade900,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 15),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Agregar',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tabla de artículos agregados
                            if (_articulos.isNotEmpty)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth),
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('No.')),
                                          DataColumn(
                                              label: Text('Descripción')),
                                          DataColumn(label: Text('Cantidad')),
                                          DataColumn(label: Text('Unidad')),
                                          DataColumn(
                                              label: Text('Precio Unitario')),
                                          DataColumn(
                                              label: Text('Importe Total')),
                                          DataColumn(label: Text('Acciones')),
                                        ],
                                        rows: _articulos
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final articulo = entry.value;
                                          return DataRow(cells: [
                                            DataCell(Text('${index + 1}')),
                                            DataCell(
                                                Text(articulo.descripcion)),
                                            DataCell(Text(articulo.cantidad
                                                .toStringAsFixed(2))),
                                            DataCell(
                                                Text(articulo.unidadMedida)),
                                            DataCell(Text(
                                                '\$${articulo.precioUnitario.toStringAsFixed(2)}')),
                                            DataCell(Text(
                                                '\$${articulo.importeTotal.toStringAsFixed(2)}')),
                                            DataCell(
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _eliminarArticulo(index),
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Sección de información y resumen
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información de entrega
                            const Expanded(
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PARA ENTREGA DE MATERIAL:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text('1. Copia de Orden de Compra'),
                                      Text(
                                          '2. Original y copia de factura de acuerdo a la orden de compra con fecha del mes en curso'),
                                      Text(
                                          '3. Sólo se reciben facturas para pago del mes en curso hasta del día 25 (excepto en Diciembre que es hasta el día 15)'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Resumen financiero
                            Expanded(
                              child: Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      // Subtotal
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Subtotal:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '\$${subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // IVA
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'IVA 16%:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '\$${iva.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Total
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'TOTAL:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            '\$${total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Notas adicionales
                        const DividerWithText(text: 'Notas Adicionales'),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(width: 10),
                            const SizedBox(height: 10),
                            CustomTextFielTexto(
                              controller: _notasController,
                              labelText:
                                  'Escriba aquí cualquier nota adicional',
                              enabled: _articulosAgregados,
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Botón para guardar
                        ElevatedButton(
                          onPressed: _todosCamposCompletos()
                              ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _guardarOrdenCompra();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            elevation: 8,
                            shadowColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: const Text(
                            'Guardar Orden de Compra',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}

class ArticuloOrdenCompra {
  String descripcion;
  double cantidad;
  String unidadMedida;
  double precioUnitario;
  double importeTotal;

  ArticuloOrdenCompra({
    required this.descripcion,
    required this.cantidad,
    required this.unidadMedida,
    required this.precioUnitario,
  }) : importeTotal = cantidad * precioUnitario;
}
