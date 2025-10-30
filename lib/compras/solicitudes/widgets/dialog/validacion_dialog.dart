import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/solicitud_compras_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_validaciones_controller.dart';
import 'package:jmas_desktop/widgets/formularios/custom_field_texto.dart';
import 'package:jmas_desktop/widgets/formularios/custom_lista_desplegable.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class ValidacionDialog extends StatefulWidget {
  final String idUser;
  final String folio;

  const ValidacionDialog({
    super.key,
    required this.folio,
    required this.idUser,
  });

  @override
  State<ValidacionDialog> createState() => _ValidacionDialogState();
}

class _ValidacionDialogState extends State<ValidacionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  String _estadoSeleccionado = 'Validar';
  bool _mostrarCampoComentario = false;

  @override
  void initState() {
    super.initState();
    _comentarioController.text = 'Validada';
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _onEstadoChanged(String? nuevoEstado) {
    setState(() {
      _estadoSeleccionado = nuevoEstado ?? 'Validar';
      _mostrarCampoComentario = _estadoSeleccionado == 'Rechazar';

      if (_estadoSeleccionado == 'Validar') {
        _comentarioController.text = 'Validada';
      } else {
        _comentarioController.text = '';
      }
    });
  }

  Future<void> _enviarValidacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final estadoValidacion =
            _estadoSeleccionado == 'Validar' ? 'Validada' : 'Rechazada';
        final idUserValidaInt = int.parse(widget.idUser);

        final validacion = SolicitudValidaciones(
          idSolicitudValidacion: 0,
          svFecha: DateTime.now(),
          svEstado: estadoValidacion,
          svComentario: _comentarioController.text,
          solicitudCompraFolio: widget.folio,
          idUserValida: int.parse(widget.idUser),
        );

        final successValidacion = await SolicitudValidacionesController()
            .addSolicitudValidacion(validacion);

        if (successValidacion) {
          final successUpdateSC =
              await SolicitudComprasController().updateSolicitudComprasEstadoValida(
            widget.folio,
            estadoValidacion,
            idUserValidaInt,
          );

          if (successUpdateSC && mounted) {
            Navigator.pop(context, true);
            showOk(context,
                'Solicitud ${_estadoSeleccionado.toLowerCase()} exitosamente');
          } else {
            if (mounted) {
              showError(
                  context, 'Error al actualizar el estado de las solicitudes');
            }
          }
        } else {
          if (mounted) {
            showError(context,
                'Error al ${_estadoSeleccionado.toLowerCase()} la solicitud');
          }
        }
      } catch (e) {
        if (mounted) {
          showError(context, 'Error');
          print('Error _enviarValidacion | ValidacionDialog: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Validar Solicitud'),
      content: Form(
        key: _formKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomListaDesplegable(
                value: _estadoSeleccionado,
                labelText: 'Acción',
                items: const ['Validar', 'Rechazar'],
                onChanged: _onEstadoChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione una acción';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 20),
            if (_mostrarCampoComentario)
              Expanded(
                child: CustomTextFielTexto(
                  controller: _comentarioController,
                  labelText: 'Justificación del rechazo',
                  prefixIcon: Icons.comment,
                  validator: (value) {
                    if (_mostrarCampoComentario &&
                        (value == null || value.isEmpty)) {
                      return 'Ingrese la justificación del rechazo';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _enviarValidacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: _estadoSeleccionado == 'Validar'
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
          child: Text(
            _estadoSeleccionado,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
