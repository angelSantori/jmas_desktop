import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/ajuste_mas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/service/auth_service.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/pdf_ajustemas.dart';

class AddAjusteMasPage extends StatefulWidget {
  final String? userName;
  final String? idUser;
  const AddAjusteMasPage({
    super.key,
    this.userName,
    this.idUser,
  });

  @override
  State<AddAjusteMasPage> createState() => _AddAjusteMasPageState();
}

class _AddAjusteMasPageState extends State<AddAjusteMasPage> {
  final AuthService _authService = AuthService();
  final AjusteMasController _ajusteMasController = AjusteMasController();
  final ProductosController _productosController = ProductosController();

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _descripctionController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _productosAgregados = [];

  bool _isLoadingGaurdando = false;
  bool _isGeneratingPDF = false;

  String? idUserReporte;
  String? codFolio;

  Productos? _selectedProducto;

  @override
  void initState() {
    _loadCodFolioAJM();
    super.initState();
  }

  Future<void> _loadCodFolioAJM() async {
    final fetchedCodFolio = await _ajusteMasController.getNextFolioAJM();
    setState(() => codFolio = fetchedCodFolio);
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      setState(() {
        final double precioUnitario = _selectedProducto!.prodPrecio ?? 0.0;
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.prodDescripcion,
          'costo': _selectedProducto!.prodPrecio,
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

  void eliminarProducto(int index) {
    setState(() {
      _productosAgregados.removeAt(index);
    });
  }

  void actualizarCosto(int index, double nuevoCosto) {
    setState(() {
      _productosAgregados[index]['costo'] = nuevoCosto;
      _productosAgregados[index]['precio'] =
          nuevoCosto * (_productosAgregados[index]['cantidad'] ?? 1);
    });
  }

  Future<void> _guardarAjusteMas() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(context, 'Debe agregar al menos un producto.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingGaurdando = true;
      });
      bool success = true;
      for (var producto in _productosAgregados) {
        await _getUserId();
        final nuevoAjusteMas = _crearAjusteMas(producto);
        bool result = await _ajusteMasController.addAjusteMas(nuevoAjusteMas);

        if (!result) {
          success = false;
          break;
        }

        if (producto['id'] == null) {
          showAdvertence(context,
              'Id nulo: ${producto['id_Producto']}, no se puede continuar.');
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
            (productoActualizado.prodExistencia!) + producto['cantidad'];

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
        await _pdfAjusteMas();
        // ignore: use_build_context_synchronously
        showOk(context, 'Ajuste Más creado exitosamente.');
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar ajuste más');
      }

      _limpiarFormulario();

      setState(() {
        _isLoadingGaurdando = false;
      });
    }
  }

  Future<void> _pdfAjusteMas() async {
    try {
      // Obtener el usuario actual
      final decodeToken = await _authService.decodeToken();
      final userId = decodeToken?['Id_User'] ?? '0';
      final userName = decodeToken?['User_Name'] ?? 'Usuario no identificado';

      // Crear objeto User con los datos mínimos necesarios
      final user = Users(
        id_User: int.tryParse(userId) ?? 0,
        user_Name: userName,
      );
      await generarPdfAjusteMas(
        fecha: _fecha,
        motivo: _descripctionController.text,
        folio: codFolio ?? 'Sin folio',
        user: user,
        almacen: 'JMAS MEOQUI',
        productos: _productosAgregados,
      );
    } catch (e) {
      print('Errro al generar PDF | pdfAjusteMas | Try: $e');
      showAdvertence(context, 'Error al generar el PDF');
    }
  }

  Future<void> _getUserId() async {
    final decodeToken = await _authService.decodeToken();
    idUserReporte = decodeToken?['Id_User'] ?? '0';
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _descripctionController.clear();
      _cantidadController.clear();
      _idProductoController.clear();
      _productosAgregados.clear();
      _selectedProducto = null;
    });
  }

  AjusteMas _crearAjusteMas(Map<String, dynamic> producto) {
    return AjusteMas(
      id_AjusteMas: 0,
      ajusteMas_CodFolio: codFolio ?? 'Sin Folio',
      ajuesteMas_Descripcion: _descripctionController.text,
      ajusteMas_Cantidad: double.parse(producto['cantidad'].toString()),
      ajusteMas_Fecha: _fecha,
      id_Producto: producto['id'],
      id_User: int.parse(idUserReporte ?? '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Más'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Fecha
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildCabeceraItem(
                            'Ajuste Más', codFolio ?? 'Cargando...'),
                      ),
                      Expanded(
                        child: buildCabeceraItem('Fecha', _fecha),
                      ),
                      Expanded(
                          child: buildCabeceraItem('Captura', widget.userName!))
                    ],
                  ),
                  const SizedBox(height: 30),

                  //Descripción
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _descripctionController,
                          labelText: 'Descripción',
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Descripción obligatoria.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  //Buscar producto
                  BuscarProductoWidget(
                    idProductoController: _idProductoController,
                    cantidadController: _cantidadController,
                    productosController: _productosController,
                    selectedProducto: _selectedProducto,
                    onProductoSeleccionado: (producto) {
                      setState(() {
                        _selectedProducto = producto;
                      });
                    },
                    onAdvertencia: (p0) {
                      showAdvertence(context, p0);
                    },
                    onEnterPressed: _agregarProducto,
                  ),
                  const SizedBox(height: 20),

                  buildProductosAgregados(
                    _productosAgregados,
                    eliminarProducto,
                    actualizarCosto,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Guardar entrada
                      ElevatedButton(
                        onPressed: (_isLoadingGaurdando || _isGeneratingPDF)
                            ? null
                            : _guardarAjusteMas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: _isLoadingGaurdando
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
                                'Guardar Ajuste +',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
