import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/contollers/cancelado_salida_controller.dart';
import 'package:jmas_desktop/contollers/salidas_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/componentes.dart';

//TODO: sumar en capturainvini

class ListCancelacioensSalidaPage extends StatefulWidget {
  const ListCancelacioensSalidaPage({super.key});

  @override
  State<ListCancelacioensSalidaPage> createState() =>
      _ListCancelacioensSalidaPageState();
}

class _ListCancelacioensSalidaPageState
    extends State<ListCancelacioensSalidaPage> {
  final CanceladoSalidaController _canceladoSalidaController =
      CanceladoSalidaController();
  final UsersController _usersController = UsersController();
  final SalidasController _salidasController = SalidasController();

  List<CanceladoSalidas> _allCanceladosSalida = [];
  List<CanceladoSalidas> _filteredCanceladosSalida = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Salidas> _salidasCache = {};
  Map<int, Users> _usersCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cancelados = await _canceladoSalidaController.listCanceladoSalida();
      final salidas = await _salidasController.listSalidas();
      final users = await _usersController.listUsers();

      setState(() {
        _allCanceladosSalida = cancelados;
        _filteredCanceladosSalida = cancelados;

        _salidasCache = {for (var sali in salidas) sali.id_Salida!: sali};
        _usersCache = {for (var use in users) use.id_User!: use};

        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos | ListCancelacionesSalida: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCanceladosSalida() {
    setState(() {
      _filteredCanceladosSalida = _allCanceladosSalida.where(
        (canceladoSalida) {
          final fechaString = canceladoSalida.cancelSalidaFecha;

          final fecha = fechaString != null ? parseDate(fechaString) : null;

          final matchesDate = fecha != null &&
              (_startDate == null || !fecha.isBefore(_startDate!)) &&
              (_endDate == null || !fecha.isAfter(_endDate!));

          return matchesDate;
        },
      ).toList();
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
      _filterCanceladosSalida();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de salidas canceladas'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
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
                      )),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _filterCanceladosSalida();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildListView(),
                )
              ],
            ),
    );
  }

  Widget _buildListView() {
    return _filteredCanceladosSalida.isEmpty
        ? const Center(
            child: Text(
              'No hay cancelaciones diponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _filteredCanceladosSalida.length,
            itemBuilder: (context, index) {
              final canceladoSalida = _filteredCanceladosSalida[index];
              final salida = _salidasCache[canceladoSalida.id_Salida];
              final user = _usersCache[canceladoSalida.id_User];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                color: const Color.fromARGB(255, 201, 230, 242),
                child: ListTile(
                  title: Text(
                    'Id cancelación: ${canceladoSalida.idCanceladoSalida}',
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
                        'Fecha: ${canceladoSalida.cancelSalidaFecha ?? 'Fecha no disponible'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Motivo: ${canceladoSalida.cancelSalidaMotivo ?? 'Motivo no encontrado'}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      if (salida != null)
                        Text(
                          'Id de Salida: ${salida.id_Salida} - Folio: ${salida.salida_CodFolio}',
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
