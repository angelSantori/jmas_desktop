import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/formularios/custom_field_numero.dart';
import 'package:jmas_desktop/widgets/formularios/custom_field_texto.dart';
import 'package:jmas_desktop/widgets/generales.dart';

class BuscarProductoWidget extends StatefulWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final ProductosController productosController;
  final Productos? selectedProducto;
  final Function(Productos?) onProductoSeleccionado;
  final Function(String) onAdvertencia;
  final VoidCallback? onEnterPressed;

  const BuscarProductoWidget({
    super.key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
    this.onEnterPressed,
  });

  @override
  State<BuscarProductoWidget> createState() => _BuscarProductoWidgetState();
}

class _BuscarProductoWidgetState extends State<BuscarProductoWidget> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  // ignore: unused_field
  double? _existencia;
  final TextEditingController _nombreProducto = TextEditingController();
  final FocusNode _cantidadFocusNode = FocusNode();
  List<Productos> _productosSugeridos = [];
  Timer? _debounce;

  @override
  void dispose() {
    _nombreProducto.dispose();
    _debounce?.cancel();
    _cantidadFocusNode.dispose();
    super.dispose();
  }

  Uint8List? _decodeImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64Image);
    } catch (e) {
      print('Error al decodificar la imagen: $e');
      return null;
    }
  }

  Future<void> _buscarProducto() async {
    final id = widget.idProductoController.text;
    if (id.isNotEmpty) {
      widget
          .onProductoSeleccionado(null); // Limpiar el producto antes de buscar
      _isLoading.value = true; // Iniciar el estado de carga

      try {
        final producto =
            await widget.productosController.getProductoById(int.parse(id));
        if (producto != null) {
          widget.onProductoSeleccionado(producto);
          FocusScope.of(context).requestFocus(_cantidadFocusNode);
        } else {
          widget.onAdvertencia('Producto con ID: $id, no encontrado');
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar el producto: $e');
      } finally {
        _isLoading.value = false; // Finalizar el estado de carga
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de producto.');
    }
  }

  Future<void> _buscarProductoXNombre(String query) async {
    if (query.isEmpty) {
      setState(() => _productosSugeridos = []);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final productos =
            await widget.productosController.getProductoByNombre(query);

        if (mounted) {
          setState(() => _productosSugeridos = productos);
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar productos: $e');
        setState(() => _productosSugeridos = []);
      }
    });
  }

  void _seleccionarProducto(Productos producto) {
    widget.idProductoController.text = producto.id_Producto.toString();
    widget.onProductoSeleccionado(producto);
    setState(() {
      _productosSugeridos = [];
      _nombreProducto.clear();
      _existencia = producto.prodExistencia;
    });
  }

  // Widget de búsqueda por nombre (modificado ligeramente)
  Widget _buildBuscadorPorNombre() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextFielTexto(
                      controller: _nombreProducto,
                      labelText: 'Escribe el nombre del producto',
                      prefixIcon: Icons.search,
                      onChanged: _buscarProductoXNombre,
                    ),
                  ),
                ],
              ),
              if (_productosSugeridos.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _productosSugeridos.length,
                    itemBuilder: (context, index) {
                      final producto = _productosSugeridos[index];
                      return ListTile(
                        title: Text(producto.prodDescripcion ?? 'Sin nombre'),
                        subtitle: Text(
                          'ID: ${producto.id_Producto} - Costo: \$${producto.prodCosto ?? 'No disponible'} - Existencias: ${producto.prodExistencia} - Ubicación: ${producto.prodUbFisica ?? 'Sin ubicación'}',
                        ),
                        onTap: () => _seleccionarProducto(producto),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DividerWithText(text: 'Selección de Productos'),
        const SizedBox(height: 20),
        _buildBuscadorPorNombre(),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo para ID del Producto
            SizedBox(
              width: 160,
              child: CustomTextFieldNumero(
                controller: widget.idProductoController,
                prefixIcon: Icons.search,
                labelText: 'Id Producto',
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _buscarProducto();
                  }
                },
              ),
            ),
            const SizedBox(width: 15),

            // Información del Producto
            if (widget.selectedProducto != null)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Información del Producto:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Descripción: ${widget.selectedProducto!.prodDescripcion ?? 'No disponible'}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selectedProducto!.prodUMedEntrada !=
                              'Servicio') ...[
                            Text(
                              'Ubicación: ${widget.selectedProducto!.prodUbFisica ?? 'Sin ubicación'}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          Text(
                            'Costo: \$${widget.selectedProducto!.prodCosto?.toStringAsFixed(2) ?? 'No disponible'}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selectedProducto!.prodUMedEntrada !=
                              'Servicio') ...[
                            Text(
                              'Existencia: ${widget.selectedProducto?.prodExistencia?.toStringAsFixed(2) ?? 'No disponible'}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Imagen del producto
                    Row(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.shade200,
                          ),
                          child: widget.selectedProducto!.prodImgB64 != null &&
                                  _decodeImage(widget
                                          .selectedProducto!.prodImgB64) !=
                                      null
                              ? Image.memory(
                                  _decodeImage(
                                      widget.selectedProducto!.prodImgB64)!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/sinFoto.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            else
              const Expanded(
                flex: 2,
                child: Text(
                  'No se ha buscado un producto.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(width: 10),

            // Campo para la cantidad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: CustomTextFieldNumero(
                    controller: widget.cantidadController,
                    focusNode: _cantidadFocusNode,
                    prefixIcon: Icons.numbers_outlined,
                    labelText: 'Cantidad',
                    onFieldSubmitted: (value) {
                      if (widget.selectedProducto != null && value.isNotEmpty) {
                        widget.onEnterPressed?.call();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
