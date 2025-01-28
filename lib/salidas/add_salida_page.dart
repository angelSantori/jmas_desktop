import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/almacenes_controller.dart';
import 'package:jmas_desktop/contollers/juntas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/widgets_salida.dart';

class AddSalidaPage extends StatefulWidget {
  final String? userName;
  const AddSalidaPage({super.key, this.userName});

  @override
  State<AddSalidaPage> createState() => _AddSalidaPageState();
}

class _AddSalidaPageState extends State<AddSalidaPage> {
  final AuthService _authService = AuthService();
  final SalidasController _salidasController = SalidasController();
  final JuntasController _juntasController = JuntasController();
  final AlmacenesController _entidadesController = AlmacenesController();
  final ProductosController _productosController = ProductosController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  String? idUserReporte;

  String? codFolio;

  final ValueNotifier<double> _selectedIncremento = ValueNotifier(0.0);

  List<Almacenes> _entidades = [];
  List<Juntas> _juntas = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Almacenes? _selectedAlmacen;
  Juntas? _selectedJunta;
  Productos? _selectedProducto;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDataSalidas();
  }

  Future<void> _loadDataSalidas() async {
    final fetchedCodFolio = await _salidasController.getNextSalidaCodFolio();
    List<Almacenes> entidades = await _entidadesController.listAlmacenes();
    List<Juntas> juntas = await _juntasController.listJuntas();
    setState(() {
      codFolio = fetchedCodFolio;
      _entidades = entidades;
      _juntas = juntas;
    });
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      if (cantidad > (_selectedProducto!.prodExistencia ?? 0)) {
        showAdvertence(context,
            'La cantidad no puede ser mayor a la existencia del producto.');
        return;
      }

      setState(() {
        final double precioUnitario = _selectedProducto!.prodPrecio ?? 0.0;
        final double? porcentaje = _selectedIncremento.value;
        final double precioAjustado =
            precioUnitario + (precioUnitario * (porcentaje! / 100));
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': precioUnitario,
          'porcentaje': porcentaje,
          'precioIncrementado': precioAjustado,
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
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Salida creada exitosamente.');
        setState(() {
          _isLoading = false;
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

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserReporte = decodeToken?['Id_User'] ?? '0';
  }

  Salidas _crearSalida(Map<String, dynamic> producto) {
    return Salidas(
      id_Salida: 0,
      salida_CodFolio: codFolio,
      salida_Referencia: _referenciaController.text,
      salida_Unidades: double.tryParse(producto['cantidad'].toString()),
      salida_Costo: double.tryParse(
          (producto['precioIncrementado'] * producto['cantidad']).toString()),
      salida_Fecha: _fecha,
      idProducto: producto['id'] ?? 0,
      id_User: int.parse(idUserReporte!), // Usuario
      id_Junta: _selectedJunta?.id_Junta ?? 0, // Junta
      id_Almacen: _selectedAlmacen?.id_Almacen ?? 0, // Almacen
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedAlmacen = null;
      _selectedJunta = null;
      _selectedProducto = null;
      _referenciaController.clear();
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salida: ${codFolio ?? "Cargando..."}'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  //Fecha
                  Text(
                    _fecha,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
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
                        child: CustomListaDesplegableTipo(
                          value: _selectedAlmacen,
                          labelText: 'Almacen',
                          items: _entidades,
                          onChanged: (ent) {
                            setState(() {
                              _selectedAlmacen = ent;
                            });
                          },
                          validator: (ent) {
                            if (ent == null) {
                              return 'Debe seleccionar una entidad.';
                            }
                            return null;
                          },
                          itemLabelBuilder: (ent) =>
                              ent.almacen_Nombre ?? 'Sin nombre',
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        //Junta
                        child: CustomListaDesplegableTipo(
                          value: _selectedJunta,
                          labelText: 'Junta',
                          items: _juntas,
                          onChanged: (junt) {
                            setState(() {
                              _selectedJunta = junt;
                            });
                          },
                          validator: (jun) {
                            if (jun == null) {
                              return 'Debe seleccionar una junta.';
                            }
                            return null;
                          },
                          itemLabelBuilder: (jun) =>
                              jun.junta_Name ?? 'Sin nombre',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  BuscarProductoWidgetSalida(
                    idProductoController: _idProductoController,
                    cantidadController: _cantidadController,
                    productosController: _productosController,
                    selectedProducto: _selectedProducto,
                    onProductoSeleccionado: (p0) {
                      setState(() {
                        _selectedProducto = p0;
                      });
                    },
                    onAdvertencia: (p0) {
                      showAdvertence(context, p0);
                    },
                    selectedIncremento: _selectedIncremento,
                  ),
                  const SizedBox(height: 10),

                  //Botón para agregar producto a la tabla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _agregarProducto,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Tabla productos agregados
                  buildProductosAgregadosSalida(_productosAgregados),
                  const SizedBox(height: 30),

                  //Botónes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Pdf e imprimir
                      ElevatedButton(
                        onPressed: () async {
                          bool datosCompletos =
                              await validarCamposAntesDeImprimir(
                            context: context,
                            productosAgregados: _productosAgregados,
                            referenciaController: _referenciaController,
                            selectedAlmacen: _selectedAlmacen,
                            selectedJunta: _selectedJunta,
                          );

                          if (!datosCompletos) {
                            return;
                          }

                          await generateAndPrintPdfSalida(
                            movimiento: 'Salida',
                            fecha: _fecha,
                            salidaCodFolio: codFolio!,
                            referencia: _referenciaController.text,
                            entidad: _selectedAlmacen?.almacen_Nombre ??
                                'Sin Almacen',
                            junta: _selectedJunta?.junta_Name ?? 'Sin Junta',
                            usuario: widget.userName!,
                            productos: _productosAgregados,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),

                      //Guardar
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarSalida,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900),
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
                                'Guardar Salida',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
      ),
    );
  }
}
