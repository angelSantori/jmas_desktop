import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/solicitud_autorizaciones_controller.dart';
import 'package:jmas_desktop/contollers/solicitud_compras_controller.dart';
import 'package:jmas_desktop/widgets/formularios/custom_field_texto.dart';
import 'package:jmas_desktop/widgets/formularios/custom_lista_desplegable.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';

class AutorizacionDialog extends StatefulWidget {
  final String idUser;
  final String folio;
  const AutorizacionDialog(
      {super.key, required this.idUser, required this.folio});

  @override
  State<AutorizacionDialog> createState() => _AutorizacionDialogState();
}

class _AutorizacionDialogState extends State<AutorizacionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  String _estadoSeleccionado = 'Autorizar';
  bool _mostrarCampoComentario = false;

  @override
  void initState() {
    super.initState();
    _comentarioController.text = 'Autorizada';
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _onEstadoChanged(String? nuevoEstado) {
    setState(() {
      _estadoSeleccionado = nuevoEstado ?? 'Autorizar';
      _mostrarCampoComentario = _estadoSeleccionado == 'Rechazar';

      if (_estadoSeleccionado == 'Autorizar') {
        _comentarioController.text = 'Autorizada';
      } else {
        _comentarioController.text = '';
      }
    });
  }

  Future<void> _enviarAutorizacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final estadoAutorizacion =
            _estadoSeleccionado == 'Autorizar' ? 'Autorizada' : 'Rechazada';
        final idUserAutorizaInt = int.parse(widget.idUser);

        final autorizacion = SolicitudAutorizaciones(
          idSolicitudAutorizacion: 0,
          saFecha: DateTime.now(),
          saEstado: estadoAutorizacion,
          saComentario: _comentarioController.text,
          solicitudCompraFolio: widget.folio,
          idUserAutoriza: idUserAutorizaInt,
        );

        final successAutorizacion = await SolicitudAutorizacionesController()
            .addSolicitudAutorizacion(autorizacion);

        if (successAutorizacion) {
          final successUpdateSC = await SolicitudComprasController()
              .updateSolicitudComprasEstadoAutoriza(
            widget.folio,
            estadoAutorizacion,
            idUserAutorizaInt,
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
          print('Error _enviarAutorizacion | _AutorizacionDialogState: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Autorizar Solicitud'),
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
                items: const ['Autorizar', 'Rechazar'],
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
          onPressed: _enviarAutorizacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: _estadoSeleccionado == 'Autorizar'
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
