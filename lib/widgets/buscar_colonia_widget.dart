//Librerías
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class BuscarColoniaWidget extends StatefulWidget {
  final TextEditingController idColoniaController;
  final ColoniasController coloniasController;
  final Colonias? selectedColonia;
  final Function(Colonias?) onColoniaSeleccionada;
  final Function(String) onAdvertencia;
  final bool mostrarOpcionAgregar;

  const BuscarColoniaWidget({
    super.key,
    required this.idColoniaController,
    required this.coloniasController,
    this.selectedColonia,
    required this.onColoniaSeleccionada,
    required this.onAdvertencia,
    this.mostrarOpcionAgregar = true,
  });

  @override
  State<BuscarColoniaWidget> createState() => _BuscarColoniaWidgetState();
}

class _BuscarColoniaWidgetState extends State<BuscarColoniaWidget> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final TextEditingController _nombreColonia = TextEditingController();
  List<Colonias> _coloniasSugeridas = [];
  Timer? _debounce;
  bool _mostrarFormularioAgregar = false;
  final TextEditingController _nuevoNombreColonia = TextEditingController();

  @override
  void dispose() {
    _nombreColonia.dispose();
    _nuevoNombreColonia.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _buscarColonia() async {
    final id = widget.idColoniaController.text;
    if (id.isNotEmpty) {
      widget.onColoniaSeleccionada(null);
      _isLoading.value = true;

      try {
        final colonia =
            await widget.coloniasController.getColoniaById(int.parse(id));
        if (colonia != null) {
          widget.onColoniaSeleccionada(colonia);
        } else {
          widget.onAdvertencia('Colonia con ID: $id, no ecnotrada');
        }
      } catch (e) {
        widget.onAdvertencia('Error al buscar la colonia: $e');
      } finally {
        _isLoading.value = false;
      }
    } else {
      widget.onAdvertencia('Por favor, ingrese un ID de colonia');
    }
  }

  Future<void> _getColoniaXNombre(String query) async {
    if (query.isEmpty) {
      setState(() => _coloniasSugeridas = []);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          final colonias =
              await widget.coloniasController.coloniaByNombre(query);

          if (mounted) {
            setState(() => _coloniasSugeridas = colonias);
          }
        } catch (e) {
          widget.onAdvertencia('Error al buscar colonia: $e');
          setState(() => _coloniasSugeridas = []);
        }
      },
    );
  }

  void _seleccionarColonia(Colonias colonia) {
    widget.idColoniaController.text = colonia.idColonia.toString();
    widget.onColoniaSeleccionada(colonia);
    setState(() {
      _coloniasSugeridas = [];
      _nombreColonia.clear();
      _mostrarFormularioAgregar = false;
    });
  }

  void _toggleFormularioAgregar() {
    setState(() {
      _mostrarFormularioAgregar = !_mostrarFormularioAgregar;
      if (!_mostrarFormularioAgregar) {
        _nuevoNombreColonia.clear();
      }
    });
  }

  Future<void> _agregarNuevaColonia() async {
    if (_nuevoNombreColonia.text.isEmpty) {
      widget.onAdvertencia('Por favor, ingrese un nombre para la colonia');
      return;
    }

    _isLoading.value = true;
    try {
      final nuevaColonia = Colonias(
        idColonia: 0,
        nombreColonia: _nuevoNombreColonia.text,
      );
      final resultado =
          await widget.coloniasController.addColonia(nuevaColonia);

      if (resultado) {
        // Buscar la colonia recién agregada para obtener su ID
        final colonias = await widget.coloniasController
            .coloniaByNombre(_nuevoNombreColonia.text);
        if (colonias.isNotEmpty) {
          final coloniaAgregada = colonias.first;
          _seleccionarColonia(coloniaAgregada);
          showOk(context, 'Colonia agregada exitosamente');
        } else {
          widget.onAdvertencia('Colonia agregada pero no se pudo recuperar');
        }
      } else {
        widget.onAdvertencia('Error al agregar la colonia');
      }
    } catch (e) {
      print('Error al agregar la colonia: $e');
      widget.onAdvertencia('Error al agregar la colonia: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Widget _buildBuscarXNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFielTexto(
                controller: _nombreColonia,
                labelText: 'Escribe el nombre de la colonia',
                prefixIcon: Icons.search,
                onChanged: _getColoniaXNombre,
              ),
            ),
            if (widget.mostrarOpcionAgregar && !_mostrarFormularioAgregar)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Agregar nueva colonia',
                onPressed: _toggleFormularioAgregar,
              ),
          ],
        ),
        if (_mostrarFormularioAgregar)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFielTexto(
                    controller: _nuevoNombreColonia,
                    labelText: 'Nombre de la nueva colonia',
                    prefixIcon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _agregarNuevaColonia,
                      child: const Text('Guardar'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _toggleFormularioAgregar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (_coloniasSugeridas.isNotEmpty)
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
              itemCount: _coloniasSugeridas.length,
              itemBuilder: (context, index) {
                final colonia = _coloniasSugeridas[index];
                return ListTile(
                  title: Text(colonia.nombreColonia ?? 'Sin nombre'),
                  subtitle: Text(
                      'ID: ${colonia.idColonia}  \nNombre: ${colonia.nombreColonia}'),
                  onTap: () => _seleccionarColonia(colonia),
                );
              },
            ),
          ),
        if (_coloniasSugeridas.isEmpty &&
            _nombreColonia.text.isNotEmpty &&
            !_mostrarFormularioAgregar &&
            widget.mostrarOpcionAgregar)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Text('No se encontraron colonias.'),
                TextButton(
                  onPressed: _toggleFormularioAgregar,
                  child: const Text('¿Desea agregar una nueva colonia?'),
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
        const DividerWithText(text: 'Selección de Colonia'),
        const SizedBox(height: 20),
        _buildBuscarXNombre(),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Campo para ID de la colonia
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: CustomTextFieldNumero(
                    controller: widget.idColoniaController,
                    prefixIcon: Icons.search,
                    labelText: 'Id Colonia',
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _buscarColonia();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),

            if (widget.selectedColonia != null)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inromación de la Colonia:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: ${widget.selectedColonia!.idColonia ?? 'No disponible'}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Nombre: ${widget.selectedColonia!.nombreColonia ?? 'No disponible'}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ))
                  ],
                ),
              )
            else
              const Expanded(
                flex: 2,
                child: Text(
                  'No se ha buscado una colonia',
                  style: TextStyle(fontSize: 14),
                ),
              ),
          ],
        )
      ],
    );
  }
}
