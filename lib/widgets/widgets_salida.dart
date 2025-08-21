import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmas_desktop/contollers/capturaInvIni_controller.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';

//Tabla de productos salida
Widget buildProductosAgregadosSalida(
  List<Map<String, dynamic>> productosAgregados,
  void Function(int) eliminarProductoSalida,
  void Function(int, double) actualizarCostoSalida,
) {
  if (productosAgregados.isEmpty) {
    return const Text(
      'No hay productos agregados.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Productos Agregados:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1), //ID
          1: FlexColumnWidth(3), //Descripción
          2: FlexColumnWidth(1), //Costo
          3: FlexColumnWidth(1), //Cantidad
          4: FlexColumnWidth(1), //% Incremento
          5: FlexColumnWidth(1), //Precio incrementado
          6: FlexColumnWidth(1), //Precio total
          7: FlexColumnWidth(1), //Eliminar
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              TableHeaderCell(texto: 'Calve'),
              TableHeaderCell(texto: 'Descripción'),
              TableHeaderCell(texto: 'Costo'),
              TableHeaderCell(texto: 'Cantidad'),
              TableHeaderCell(texto: '% Incremento'),
              TableHeaderCell(texto: 'Precio Incrementado'),
              TableHeaderCell(texto: 'Precio Total'),
              TableHeaderCell(texto: 'Eliminar'),
            ],
          ),
          ...productosAgregados.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> producto = entry.value;

            TextEditingController costoSalidaController =
                TextEditingController(text: producto['costo'].toString());

            return TableRow(
              children: [
                TableCellText(texto: producto['id'].toString()),
                TableCellText(texto: producto['descripcion'].toString()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: costoSalidaController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onSubmitted: (nuevoValor) {
                      double nuevoCosto =
                          double.tryParse(nuevoValor) ?? producto['costo'];
                      actualizarCostoSalida(index, nuevoCosto);
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      fillColor: Colors.blue.shade900,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                    ),
                  ),
                ),
                TableCellText(texto: producto['cantidad'].toString()),
                TableCellText(texto: producto['porcentaje'].toString() + '%'),
                TableCellText(
                    texto: '\$${producto['precioIncrementado'].toString()}'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '\$${((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0).toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarProductoSalida(index),
                  ),
                ),
              ],
            );
          }),
          TableRow(children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) => previousValue + ((producto['precioIncrementado'] * producto['cantidad']) ?? 0.0)).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
          ])
        ],
      ),
    ],
  );
}

//Buscar producto
class BuscarProductoWidgetSalida extends StatefulWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final ProductosController productosController;
  final CapturainviniController capturainviniController;
  final Productos? selectedProducto;
  final Function(Productos?) onProductoSeleccionado;
  final Function(String) onAdvertencia;
  final ValueNotifier<double> selectedIncremento;

  BuscarProductoWidgetSalida({
    super.key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
    required this.selectedIncremento,
    required this.capturainviniController,
  });

  @override
  State<BuscarProductoWidgetSalida> createState() =>
      _BuscarProductoWidgetSalidaState();
}

class _BuscarProductoWidgetSalidaState
    extends State<BuscarProductoWidgetSalida> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  double? _invIniConteo;

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
          // Buscar el valor de invIniConteo para el producto
          final capturaList =
              await widget.capturainviniController.listCapturaI();
          final captura = capturaList.firstWhere(
            (captura) => captura.id_Producto == producto.id_Producto,
            orElse: () => Capturainvini(invIniConteo: null),
          );

          setState(() {
            _invIniConteo = captura.invIniConteo; // Almacenar el valor
          });
          widget.onProductoSeleccionado(producto);
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

  @override
  Widget build(BuildContext context) {
    return Row(
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

        // Botón para buscar producto
        ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, child) {
            return ElevatedButton(
              onPressed: isLoading ? null : _buscarProducto,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? Colors.grey
                    : Colors.blue.shade900, // Cambiar color si está cargando
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Buscar producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
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
                      Text(
                        'Precio: \$${widget.selectedProducto!.prodPrecio?.toStringAsFixed(2) ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Existencia: ${_invIniConteo ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ValueListenableBuilder<double?>(
                        valueListenable: widget.selectedIncremento,
                        builder: (context, porcentaje, child) {
                          final double precioUnitario =
                              widget.selectedProducto!.prodPrecio ?? 0.0;
                          final double precioAjustado = precioUnitario +
                              (precioUnitario * (porcentaje! / 100));
                          return Text(
                            'Precio ajustad: \$${precioAjustado.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      DropdownButton<double>(
                        value: widget.selectedIncremento.value,
                        items: const [
                          DropdownMenuItem(value: 0.0, child: Text('0%')),
                          DropdownMenuItem(value: 5.0, child: Text('5%')),
                          DropdownMenuItem(value: 10.0, child: Text('10%'))
                        ],
                        onChanged: (value) {
                          setState(() {
                            widget.selectedIncremento.value = value!;
                          });
                        },
                      ),
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
                              _decodeImage(
                                      widget.selectedProducto!.prodImgB64) !=
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
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
                prefixIcon: Icons.numbers_outlined,
                labelText: 'Cantidad',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//Padron
class BuscarPadronWidgetSalida extends StatefulWidget {
  final TextEditingController idPadronController;
  final PadronController padronController;
  final Padron? selectedPadron;
  final Function(Padron?) onPadronSeleccionado;
  final Function(String) onAdvertencia;

  BuscarPadronWidgetSalida({
    super.key,
    required this.idPadronController,
    required this.padronController,
    required this.selectedPadron,
    required this.onPadronSeleccionado,
    required this.onAdvertencia,
  });

  @override
  State<BuscarPadronWidgetSalida> createState() =>
      _BuscarPadronWidgetSalidaState();
}

class _BuscarPadronWidgetSalidaState extends State<BuscarPadronWidgetSalida> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final TextEditingController _busquedaController = TextEditingController();
  List<Padron> _resultadosBusqueda = [];
  Timer? _debounce;

  final FocusNode _busquedaFocusNode = FocusNode();
  bool _showReults = false;

  @override
  void initState() {
    super.initState();
    _busquedaFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounce?.cancel();
    _busquedaFocusNode.removeListener(_onFocusChange);
    _busquedaFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_busquedaFocusNode.hasFocus) {
      setState(() => _showReults = false);
    }
  }

  Future<void> _buscarPadronXId() async {
    final id = widget.idPadronController.text;
    if (id.isNotEmpty) {
      widget.onPadronSeleccionado(null); // Limpiar el padrón antes de buscar
      _isLoading.value = true; // Iniciar el estado de carga

      try {
        final padronList = await widget.padronController.listPadron();
        final foundPadron = padronList.firstWhere(
          (p) => p.idPadron.toString() == id,
          orElse: () => Padron(),
        );
        if (foundPadron.idPadron != null) {
          widget.onPadronSeleccionado(foundPadron);
        } else {
          widget.onAdvertencia('Padrón con ID: $id, no encontrado');
          widget.idPadronController.clear();
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar el padrón: $e');
      } finally {
        _isLoading.value = false; // Finalizar el estado de carga
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de padrón.');
    }
  }

  Future<void> _buscarPadron(String query) async {
    try {
      final resultados = await widget.padronController.getBuscar(query);
      setState(() => _resultadosBusqueda = resultados);
    } catch (e) {
      widget.onAdvertencia('Error al buscar padron: $e');
      setState(() => _resultadosBusqueda = []);
    }
  }

  void _onBusquedaChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (query.isNotEmpty) {
          setState(() => _showReults = true);
          _buscarPadron(query);
        } else {
          setState(() {
            _resultadosBusqueda = [];
            _showReults = false;
          });
        }
      },
    );
  }

  void _seleccionarPadron(Padron padron) {
    widget.idPadronController.text = padron.idPadron.toString();
    widget.onPadronSeleccionado(padron);
    setState(() {
      _resultadosBusqueda = [];
      _showReults = false;
      _busquedaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DividerWithText(text: 'Selección de Padrón'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _busquedaController,
                labelText: 'Buscar padron por nombre o dirección',
                onChanged: _onBusquedaChanged,
              ),
            ),
          ],
        ),
        // Resultados de búsqueda
        if (_showReults && _resultadosBusqueda.isNotEmpty)
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
              itemCount: _resultadosBusqueda.length,
              itemBuilder: (context, index) {
                final padron = _resultadosBusqueda[index];
                return ListTile(
                  title: Text(padron.padronNombre ?? 'Sin nombre'),
                  subtitle: Text(padron.padronDireccion ?? 'Sin dirección'),
                  onTap: () => _seleccionarPadron(padron),
                );
              },
            ),
          ),
        const SizedBox(height: 30),
        // Campo para ID del Padrón
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              child: CustomTextFieldNumero(
                controller: widget.idPadronController,
                prefixIcon: Icons.search,
                labelText: 'Id Padrón',
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _buscarPadronXId();
                  }
                },
              ),
            ),
            const SizedBox(width: 15),

            // Botón para buscar padrón
            // ValueListenableBuilder<bool>(
            //   valueListenable: _isLoading,
            //   builder: (context, isLoading, child) {
            //     return ElevatedButton(
            //       onPressed: isLoading ? null : _buscarPadronXId,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: isLoading
            //             ? Colors.grey
            //             : Colors
            //                 .blue.shade900, // Cambiar color si está cargando
            //       ),
            //       child: isLoading
            //           ? const SizedBox(
            //               height: 16,
            //               width: 16,
            //               child: CircularProgressIndicator(
            //                 strokeWidth: 2,
            //                 color: Colors.white,
            //               ),
            //             )
            //           : const Text(
            //               'Buscar padrón',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //     );
            //   },
            // ),
            const SizedBox(width: 15),
            // Información del Padrón
            if (widget.selectedPadron != null &&
                widget.selectedPadron!.idPadron != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Padrón:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Nombre: ${widget.selectedPadron!.padronNombre ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Dirección: ${widget.selectedPadron!.padronDireccion ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                flex: 2,
                child: Text(
                  'No se ha buscado un padrón.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
