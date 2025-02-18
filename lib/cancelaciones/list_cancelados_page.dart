import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/cancelado_controller.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';

class ListCanceladosPage extends StatefulWidget {
  const ListCanceladosPage({super.key});

  @override
  State<ListCanceladosPage> createState() => _ListCanceladosPageState();
}

class _ListCanceladosPageState extends State<ListCanceladosPage> {
  final CanceladoController _canceladoController = CanceladoController();
  final UsersController _usersController = UsersController();
  final EntradasController _entradasController = EntradasController();

  List<Cancelados> _allCancelados = [];
  List<Cancelados> _filteredCancelados = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Entradas> _entradasCache = {};
  Map<int, Users> _usersCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cancelados = await _canceladoController.listCancelaciones();
      final entradas = await _entradasController.listEntradas();
      final users = await _usersController.listUsers();

      setState(() {
        _allCancelados = cancelados;
        _filteredCancelados = cancelados;

        _entradasCache = {for (var entr in entradas) entr.id_Entradas!: entr};
        _usersCache = {for (var us in users) us.id_User!: us};

        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos | ListCanceladosPage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCancelados() {
    setState(() {
      _filteredCancelados = _allCancelados.where((cancelado) {
        final fechaString = cancelado.cancelFecha;

        final fecha = fechaString != null ? parseDate(fechaString) : null;

        final matchesDate = fecha != null &&
            (_startDate == null || !fecha.isBefore(_startDate!)) &&
            (_endDate == null || !fecha.isAfter(_endDate!));

        return matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterCancelados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDateRange(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 201, 230, 242),
                          ),
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.black),
                          label: Text(
                            _startDate != null && _endDate != null
                                ? 'Desde: ${DateFormat('yyyy-MM-dd').format(_startDate!)} Hasta: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                                : 'Seleccionar rango de fechas',
                            style: const TextStyle(
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _filterCancelados();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // SOLUCIÓN: Envolver `_buildListView()` en `Expanded`
                  child: _buildListView(),
                ),
              ],
            ),
    );
  }

  Widget _buildListView() {
    return _filteredCancelados.isEmpty
        ? const Center(
            child: Text(
              'No hay cancelaciones disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _filteredCancelados.length,
            itemBuilder: (context, index) {
              final cancelado = _filteredCancelados[index];
              final entrada = _entradasCache[cancelado.id_Entrada];
              final user = _usersCache[cancelado.id_User];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                color: const Color.fromARGB(255, 201, 230, 242),
                child: ListTile(
                  title: Text(
                    'Id cancelación: ${cancelado.idCancelacion}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Realizado por: ${user?.user_Name ?? 'Usuario no encontrado'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Fecha: ${cancelado.cancelFecha ?? 'Fecha no disponible'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Motivo: ${cancelado.cancelMotivo ?? 'Motivo no encontrado'}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      if (entrada != null)
                        Text(
                          'Id de Entrada: ${entrada.id_Entradas} - Folio: ${entrada.entrada_CodFolio}',
                          style: const TextStyle(fontSize: 15),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
