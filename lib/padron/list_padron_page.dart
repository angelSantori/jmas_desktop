import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/padron_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';

class ListPadronPage extends StatefulWidget {
  const ListPadronPage({
    super.key,
  });

  @override
  State<ListPadronPage> createState() => _ListPadronPageState();
}

class _ListPadronPageState extends State<ListPadronPage> {
  final PadronController _padronController = PadronController();
  final TextEditingController _searchController = TextEditingController();

  List<Padron> _allPadron = [];
  List<Padron> _filteredPadron = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPadron);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final padrones = await _padronController.listPadron();

      setState(() {
        _allPadron = padrones;
        _filteredPadron = padrones;
        _isLoading = false;
      });
    } catch (e) {
      print('Error list_padron_page: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPadron() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPadron = _allPadron.where((padron) {
        final nombre = padron.padronNombre?.toLowerCase() ?? '';
        final direccion = padron.padronDireccion?.toLowerCase() ?? '';
        final id = padron.idPadron.toString();

        return nombre.contains(query) ||
            direccion.contains(query) ||
            id.contains(query);
      }).toList();
    });
  }

  Future<void> _importFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.bytes != null) {
      // Crear un archivo temporal desde los bytes
      final bytes = result.files.single.bytes!;

      bool? updateExisting = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Opciones de importación'),
            content: const Text('¿Desea actualizar los padrones existentes?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              // TextButton(
              //   child: Text('Solo agregar nuevos'),
              //   onPressed: () => Navigator.of(context).pop(false),
              // ),
              TextButton(
                child: const Text('Agregar y Actualizar'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (updateExisting == null) return; // Usuario canceló

      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Importando padrones..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        final result = await _padronController.importPadronesExcel(bytes,
            updateExisting: updateExisting);

        Navigator.of(context).pop(); // Cerrar diálogo de progreso

        if (result['success'] == true) {
          // Mostrar resultados
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Importación completada'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Padrones importados: ${result['imported']}'),
                    Text('Padrones actualizados: ${result['updated']}'),
                    if (result['errors'] != null && result['errors'].length > 0)
                      Text('Errores: ${result['errors'].length}'),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadData(); // Recargar datos
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error en importación'),
                content: Text(result['error'] ?? 'Error desconocido'),
                actions: [
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar diálogo de progreso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Ocurrió un error durante la importación: $e'),
              actions: [
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Padrón'),
        centerTitle: true,
        actions: [
          PermissionWidget(
            permission: 'edit',
            child: IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: _importFromExcel,
              tooltip: 'Importar desde Excel',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CustomTextFielTexto(
                controller: _searchController,
                labelText: 'Busqueda por Nombre, Dirección o ID',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade900,
                      ),
                    )
                  : _filteredPadron.isEmpty
                      ? const Center(
                          child: Text(
                              'No hay algún padron que conicida con la búsqueda.'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredPadron.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final padron = _filteredPadron[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_pin_sharp,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //Nombre
                                          Text(
                                            padron.padronNombre ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.fmd_good_sharp,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                padron.padronDireccion ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          //ID
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.numbers,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'ID ${padron.idPadron ?? ''}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
