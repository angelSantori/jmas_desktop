import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_compras_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/buscar_producto.dart';
import 'package:jmas_desktop/widgets/formularios/custom_field_texto.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/tabla_productos.dart';

class AddSolicitudCompra extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddSolicitudCompra({super.key, this.userName, this.idUser});

  @override
  State<AddSolicitudCompra> createState() => _AddSolicitudCompraState();
}

class _AddSolicitudCompraState extends State<AddSolicitudCompra> {
  final AuthService _authService = AuthService();
  final SolicitudComprasController _solicitudComprasController =
      SolicitudComprasController();
  final ProductosController _productosController = ProductosController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _objetivoController = TextEditingController();
  final TextEditingController _especificacionesController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

  String? idUserSolicita;
  String? _selectedEstado = 'Tramite';

  List<Map<String, dynamic>> _productosAgregados = [];

  bool _isLoading = false;
  bool _objetivoCompletado = false;
  bool _especificacionesCompletado = false;
  bool _observacionesCompletado = false;

  Productos? _selectedProducto;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserSolicita = decodeToken?['Id_User'] ?? '0';
  }

  void _validarCampo(String campo, TextEditingController controller) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        switch (campo) {
          case 'objetivo':
            _objetivoCompletado = true;
            break;
          case 'especificaciones':
            _especificacionesCompletado = true;
            break;
          case 'observaciones':
            _observacionesCompletado = true;
            break;
        }
      });
    }
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final double cantidad = double.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      setState(() {
        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': _selectedProducto!.prodCosto ?? 0.0,
          'cantidad': cantidad,
          'precio': (_selectedProducto!.prodCosto ?? 0.0) * cantidad,
        });

        // Limpiar campos después de agregar
        _idProductoController.clear();
        _cantidadController.clear();
        _selectedProducto = null;
      });
    } else {
      showAdvertence(
          context, 'Debe seleccionar un producto y definir la cantidad.');
    }
  }

  void eliminarProductoSolicitud(int index) {
    setState(() {
      _productosAgregados.removeAt(index);
    });
  }

  Future<void> _guardarSolicitud() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(context,
          'Debe agregar productos antes de guardar la solicitud de compra.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _getUserId();

        // Crear lista de solicitudes para todos los productos
        List<SolicitudCompras> solicitudesParaGuardar = [];
        for (var producto in _productosAgregados) {
          final nuevaSolicitud = _crearSolicitudCompra(producto);
          solicitudesParaGuardar.add(nuevaSolicitud);
        }

        // Guardar todas las solicitudes con el mismo folio
        final solicitudesGuardadas = await _solicitudComprasController
            .addMultipleSolicitudCompras(solicitudesParaGuardar);

        if (solicitudesGuardadas == null || solicitudesGuardadas.isEmpty) {
          if (mounted) {
            showError(context, 'Error al registrar solicitud de compra');
          }
        } else {
          // Limpiar formulario
          _limpiarFormulario();

          if (mounted) {
            showOk(context, 'Solicitud de compra creada exitosamente.');
          }
        }
      } catch (e) {
        print('Error en _guardarSolicitud: $e');
        if (mounted) {
          showError(context, 'Error al procesar la solicitud de compra');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  SolicitudCompras _crearSolicitudCompra(Map<String, dynamic> producto) {
    return SolicitudCompras(
      idSolicitudCompra: 0,
      scFolio: '', // Se generará automáticamente en el backend
      scEstado: _selectedEstado!,
      scFecha: DateTime.now(),
      scObjetivo: _objetivoController.text,
      scEspecificaciones: _especificacionesController.text,
      scObservaciones: _observacionesController.text,
      idProducto: producto['id'] ?? 0,
      scCantidadProductos: producto['cantidad'] ?? 0,
      scTotalCostoProductos: producto['precio'] ?? 0,
      idUserSolicita: int.parse(idUserSolicita!),
      idUserValida: null, // Se asignará en otra pantalla
      idUserAutoriza: null, // Se asignará en otra pantalla
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedProducto = null;
      _objetivoCompletado = false;
      _especificacionesCompletado = false;
      _observacionesCompletado = false;

      _objetivoController.clear();
      _especificacionesController.clear();
      _observacionesController.clear();
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: buildCabeceraItem(
                                'Fecha', _fechaController.text)),
                        Expanded(
                            child: buildCabeceraItem(
                                'Solicita', widget.userName!)),
                        Expanded(
                            child:
                                buildCabeceraItem('Estado', _selectedEstado!)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Campo Objetivo
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFielTexto(
                            controller: _objetivoController,
                            labelText: 'Objetivo de la solicitud*',
                            prefixIcon: Icons.flag,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El objetivo es obligatorio';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _validarCampo('objetivo', _objetivoController);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Campo Especificaciones
                        Expanded(
                          child: CustomTextFielTexto(
                            controller: _especificacionesController,
                            labelText: 'Especificaciones*',
                            prefixIcon: Icons.description,
                            enabled: _objetivoCompletado,
                            validator: (value) {
                              if (_objetivoCompletado &&
                                  (value == null || value.isEmpty)) {
                                return 'Las especificaciones son obligatorias';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _validarCampo('especificaciones',
                                  _especificacionesController);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Campo Observaciones
                        Expanded(
                          child: CustomTextFielTexto(
                            controller: _observacionesController,
                            labelText: 'Observaciones*',
                            prefixIcon: Icons.notes,
                            enabled: _especificacionesCompletado,
                            validator: (value) {
                              if (_especificacionesCompletado &&
                                  (value == null || value.isEmpty)) {
                                return 'Las observaciones son obligatorias';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _validarCampo(
                                  'observaciones', _observacionesController);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Selección de productos (solo disponible cuando todos los campos anteriores están completos)
                    if (_observacionesCompletado) ...[
                      BuscarProductoWidget(
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
                      const SizedBox(height: 20),

                      // Tabla de productos agregados
                      buildProductosAgregadosGeneral(
                        _productosAgregados,
                        eliminarProductoSolicitud,
                        mostrarEliminar: true,
                        tipoOperacion: 'solicitud',
                      ),
                      const SizedBox(height: 30),

                      // Botón de guardar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _guardarSolicitud,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              elevation: 8,
                              shadowColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
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
                                        'Guardando...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Guardar Solicitud',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _limpiarFormulario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            child: const Text(
                              'Limpiar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Mensaje informativo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade800),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Complete los campos anteriores para habilitar la selección de productos',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
