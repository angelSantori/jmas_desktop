//Librerías
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/colonias_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/generales.dart';

class BuscarColoniaWidget extends StatefulWidget {
  final TextEditingController idColoniaController;
  final ColoniasController coloniasController;
  final Colonias? selectedColonia;
  final Function(Colonias?) onColoniaSeleccionada;
  final Function(String) onAdvertencia;

  const BuscarColoniaWidget(
      {super.key,
      required this.idColoniaController,
      required this.coloniasController,
      this.selectedColonia,
      required this.onColoniaSeleccionada,
      required this.onAdvertencia});

  @override
  State<BuscarColoniaWidget> createState() => _BuscarColoniaWidgetState();
}

class _BuscarColoniaWidgetState extends State<BuscarColoniaWidget> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final TextEditingController _nombreColonia = TextEditingController();
  List<Colonias> _coloniasSugeridas = [];
  Timer? _debounce;

  @override
  void dispose() {
    _nombreColonia.dispose();
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
            await widget.coloniasController.getColoniaXId(int.parse(id));
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
    });
  }

  Widget _buildBuscarXNombre() {
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
                    controller: _nombreColonia,
                    labelText: 'Escribe el nombre de la colonia',
                    prefixIcon: Icons.search,
                    onChanged: _getColoniaXNombre,
                  ),
                ),
              ],
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
          ],
        ))
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
