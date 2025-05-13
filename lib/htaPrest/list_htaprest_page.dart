import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/htaprestamo_controller.dart';
import 'package:jmas_desktop/contollers/herramientas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';
import 'package:jmas_desktop/widgets/mensajes.dart';
import 'package:jmas_desktop/widgets/permission_widget.dart';

class ListHtaprestPage extends StatefulWidget {
  const ListHtaprestPage({super.key});

  @override
  State<ListHtaprestPage> createState() => _ListHtaprestPageState();
}

class _ListHtaprestPageState extends State<ListHtaprestPage> {
  final HtaprestamoController _htaprestamoController = HtaprestamoController();
  final UsersController _usersController = UsersController();
  final HerramientasController _herramientasController =
      HerramientasController();
  final TextEditingController _searchController = TextEditingController();

  List<HtaPrestamo> _allHtasPest = [];
  Map<String, List<HtaPrestamo>> _groupedPrestamos = {};
  List<String> _filteredFolios = [];

  bool _isLoading = false;
  String? _selectedFolio;
  List<HtaPrestamo> _selectedPrestamoDetails = [];

  Map<int, Herramientas> _htasCache = {};
  Map<int, Users> _userCache = {};

  // Función para mostrar diálogo de confirmación
  Future<bool> showConfirmationDialog(
      BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPrestamos);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final htaPrest = await _htaprestamoController.listHtaPrest();
      final htas = await _herramientasController.listHtas();
      final users = await _usersController.listUsers();
      setState(() {
        _allHtasPest = htaPrest;
        _groupPrestamos(htaPrest);
        _filteredFolios = _groupedPrestamos.keys.toList();
        _isLoading = false;

        _htasCache = {for (var ht in htas) ht.idHerramienta!: ht};
        _userCache = {for (var us in users) us.id_User!: us};
      });
    } catch (e) {
      print('Error loadData | ListHtaPrest | Try: $e');
      setState(() => _isLoading = false);
    }
  }

  void _groupPrestamos(List<HtaPrestamo> prestamos) {
    _groupedPrestamos = {};
    for (var prestamo in prestamos) {
      final folio = prestamo.prestCodFolio ?? 'Sin folio';
      if (!_groupedPrestamos.containsKey(folio)) {
        _groupedPrestamos[folio] = [];
      }
      _groupedPrestamos[folio]!.add(prestamo);
    }
  }

  void _filterPrestamos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFolios = _groupedPrestamos.keys.where((folio) {
        return folio.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showPrestamoDetails(String folio) {
    setState(() {
      _selectedFolio = folio;
      _selectedPrestamoDetails = _groupedPrestamos[folio] ?? [];
    });
  }

  Future<void> _registrarDevolucion(String folio) async {
    final confirm = await showConfirmationDialog(
        context,
        '¿Registrar devolución del préstamo $folio?',
        'Esta acción cambiará el estado de las herramientas a "Disponible"');

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final prestamos = _groupedPrestamos[folio] ?? [];
      final now = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

      bool success = true;
      for (var prestamo in prestamos) {
        // Actualizar préstamo
        final updatedPrestamo = prestamo.copyWith(
          prestFechaDevol: now,
        );

        final result =
            await _htaprestamoController.editHtaPrest(updatedPrestamo);
        if (!result) success = false;

        // Actualizar estado de herramienta
        final herramienta = await _herramientasController
            .getHtaXId(prestamo.idHerramienta ?? 0);
        if (herramienta != null) {
          final updatedHerramienta =
              herramienta.copyWith(htaEstado: 'Disponible');
          final estadoCambiado =
              await _herramientasController.editHta(updatedHerramienta);
          if (!estadoCambiado) success = false;
        }
      }

      if (success) {
        showOk(context, 'Devolución registrada exitosamente');
        await _loadData(); // Recargar datos
      } else {
        showError(context, 'Error al registrar algunas devoluciones');
      }
    } catch (e) {
      showError(context, 'Error al registrar la devolución: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Préstamos de Herramientas'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFielTexto(
                      controller: _searchController,
                      labelText: 'Buscar préstamo por folio',
                      prefixIcon: Icons.search,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista de préstamos o detalles
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Colors.blue.shade900))
                  : _selectedFolio == null
                      ? _buildListaFolios()
                      : _buildDetallesPrestamo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaFolios() {
    return _filteredFolios.isEmpty
        ? const Center(child: Text('No hay préstamos registrados'))
        : ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredFolios.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final folio = _filteredFolios[index];
              final prestamos = _groupedPrestamos[folio]!;
              final firstPrestamo = prestamos.first;

              return GestureDetector(
                onTap: () => _showPrestamoDetails(folio),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
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
                        // Icono
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.construction,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Información
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Folio
                              Text(
                                folio,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Cantidad de herramientas
                              Text(
                                'Herramientas: ${prestamos.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Fecha préstamo
                              Text(
                                'Fecha: ${firstPrestamo.prestFechaPrest ?? 'No disponible'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              // Estado
                              Text(
                                'Estado: ${firstPrestamo.prestFechaDevol == null || firstPrestamo.prestFechaDevol!.isEmpty ? 'Prestada' : 'Devuelto'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: firstPrestamo.prestFechaDevol ==
                                              null ||
                                          firstPrestamo.prestFechaDevol!.isEmpty
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildDetallesPrestamo() {
    return Column(
      children: [
        // Encabezado con botón de regreso
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedFolio = null;
                    _selectedPrestamoDetails = [];
                  });
                },
              ),
              Text(
                'Detalles del préstamo: $_selectedFolio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const Spacer(),
              if (_selectedPrestamoDetails.isNotEmpty &&
                  (_selectedPrestamoDetails.first.prestFechaDevol == null ||
                      _selectedPrestamoDetails.first.prestFechaDevol!.isEmpty))
                PermissionWidget(
                  permission: 'edit',
                  child: ElevatedButton(
                    onPressed: () => _registrarDevolucion(_selectedFolio!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                    ),
                    child: const Text(
                      'Registrar Devolución',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Lista de herramientas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _selectedPrestamoDetails.length,
            itemBuilder: (context, index) {
              final prestamo = _selectedPrestamoDetails[index];
              final herramienta = _htasCache[prestamo.idHerramienta];
              final user = _userCache[prestamo.id_UserAsignado];

              String asignadoInfo;
              if (prestamo.id_UserAsignado != null && user != null) {
                asignadoInfo =
                    '\n${user.id_User ?? '0'} - ${user.user_Name ?? 'Sin nombre'}';
              } else if (prestamo.externoNombre != null ||
                  prestamo.externoNombre!.isNotEmpty) {
                asignadoInfo =
                    '\nExterno: ${prestamo.externoNombre ?? 'Sin nombre'} \nContacto: ${prestamo.externoContacto ?? 'Sin contacto'}';
              } else {
                asignadoInfo = 'No especificado';
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Herramienta: ${herramienta?.idHerramienta ?? '0'} - ${herramienta?.htaNombre ?? 'Sin nombre'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha préstamo: ${prestamo.prestFechaPrest ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha devolución: ${prestamo.prestFechaDevol ?? 'Pendiente'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: prestamo.prestFechaDevol == null
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Asignado a: $asignadoInfo',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
