import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class EditProductoPage extends StatefulWidget {
  final Productos producto;
  const EditProductoPage({super.key, required this.producto});

  @override
  State<EditProductoPage> createState() => _EditProductoPageState();
}

class _EditProductoPageState extends State<EditProductoPage> {
  final ProductosController _productosController = ProductosController();
  final _formkey = GlobalKey<FormState>();

  late TextEditingController _descripcionController;
  late TextEditingController _costoController;
  late TextEditingController _precio1Controller;
  late TextEditingController _precio2Controller;
  late TextEditingController _precio3Controller;
  late TextEditingController _existenciaController;
  late TextEditingController _existenciaInicialController;
  late TextEditingController _existenciaConFisController;

  String? _selectedUMedida;
  final List<String> _unidadesMedidas = ['Mts', 'Kg', 'Gr', 'Lts', 'Cm'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descripcionController =
        TextEditingController(text: widget.producto.producto_Descripcion);
    _costoController = TextEditingController(
        text: (widget.producto.producto_Costo ?? 0.0).toString());
    _selectedUMedida = widget.producto.producto_UMedida;
    _precio1Controller = TextEditingController(
        text: (widget.producto.producto_Precio1 ?? 0.0).toString());
    _precio2Controller = TextEditingController(
        text: (widget.producto.producto_Precio2 ?? 0.0).toString());
    _precio3Controller = TextEditingController(
        text: (widget.producto.producto_Precio3 ?? 0.0).toString());
    _existenciaController = TextEditingController(
        text: (widget.producto.producto_Existencia ?? 0.0).toString());
    _existenciaInicialController = TextEditingController(
        text: (widget.producto.producto_ExistenciaInicial ?? 0.0).toString());
    _existenciaConFisController = TextEditingController(
        text: (widget.producto.producto_ExistenciaConFis ?? 0.0).toString());
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _costoController.dispose();
    _precio1Controller.dispose();
    _precio2Controller.dispose();
    _precio3Controller.dispose();
    _existenciaController.dispose();
    _existenciaInicialController.dispose();
    _existenciaConFisController.dispose();
    super.dispose();
  }

  Future<void> _saveChange() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      final updateProducto = widget.producto.copyWith(
        producto_Descripcion: _descripcionController.text,
        producto_Costo: double.parse(_costoController.text),
        producto_UMedida: _selectedUMedida!,
        producto_Precio1: double.parse(_precio1Controller.text),
        producto_Precio2: double.parse(_precio2Controller.text),
        producto_Precio3: double.parse(_precio3Controller.text),
        producto_Existencia: double.parse(_existenciaController.text),
        producto_ExistenciaInicial:
            double.parse(_existenciaInicialController.text),
        producto_ExistenciaConFis:
            double.parse(_existenciaConFisController.text),
      );

      final result = await _productosController.editProducto(updateProducto);
      setState(() {
        _isLoading = false;
      });

      if (result) {
        await showOk(context, 'Producto editado correctamente.');
        Navigator.pop(context, true);
      } else {
        showError(context, 'Error al editar el producto.');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  //Descripción
                  buildFormRow(
                    label: 'Descripción:',
                    child: TextFormField(
                      controller: _descripcionController,
                      decoration:
                          const InputDecoration(labelText: 'Descipción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción no puede estar vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Costo
                  buildFormRow(
                    label: 'Costo:',
                    child: TextFormField(
                      controller: _costoController,
                      decoration: const InputDecoration(labelText: 'Costo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El costo no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Unidad Medida
                  buildFormRow(
                    label: 'Unidad de Medida:',
                    child: DropdownButtonFormField<String>(
                      value: _selectedUMedida,
                      items: _unidadesMedidas
                          .map((umedida) => DropdownMenuItem(
                                value: umedida,
                                child: Text(umedida),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUMedida = value!;
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Unidad de Medida'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe de seleccionar una unidad de medida.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Pecio 1
                  buildFormRow(
                    label: 'Precio 1:',
                    child: TextFormField(
                      controller: _precio1Controller,
                      decoration: const InputDecoration(labelText: 'Precio 1'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio1 no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Pecio 2
                  buildFormRow(
                    label: 'Precio 2:',
                    child: TextFormField(
                      controller: _precio2Controller,
                      decoration: const InputDecoration(labelText: 'Precio 2'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio2 no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Pecio 3
                  buildFormRow(
                    label: 'Precio 3:',
                    child: TextFormField(
                      controller: _precio3Controller,
                      decoration: const InputDecoration(labelText: 'Precio 3'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio3 no puede estar vacío.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Existencias
                  buildFormRow(
                    label: 'Existencias:',
                    child: TextFormField(
                      controller: _existenciaController,
                      decoration:
                          const InputDecoration(labelText: 'Existencia'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La existencia no puede estar vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Existencia Inicial
                  buildFormRow(
                    label: 'Existencia incial:',
                    child: TextFormField(
                      controller: _existenciaInicialController,
                      decoration: const InputDecoration(
                          labelText: 'Existencia inicial'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La existencia inicial no puede estar vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Existencia confis
                  buildFormRow(
                    label: 'Existencia conteo físico:',
                    child: TextFormField(
                      controller: _existenciaConFisController,
                      decoration: const InputDecoration(
                          labelText: 'Existencia conteo físico'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La existencia conteo físico no puede estar vacía.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Botón
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChange,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
