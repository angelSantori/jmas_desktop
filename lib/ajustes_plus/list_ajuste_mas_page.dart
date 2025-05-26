import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_desktop/ajustes_plus/details_ajuste_mas_page.dart';
import 'package:jmas_desktop/contollers/ajuste_mas_controller.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListAjusteMasPage extends StatefulWidget {
  final String? userRole;
  const ListAjusteMasPage({
    super.key,
    this.userRole,
  });

  @override
  State<ListAjusteMasPage> createState() => _ListAjusteMasPageState();
}

class _ListAjusteMasPageState extends State<ListAjusteMasPage> {
  final AjusteMasController _ajusteMasController = AjusteMasController();
  final ProductosController _productosController = ProductosController();
  final UsersController _usersController = UsersController();

  final TextEditingController _searchController = TextEditingController();

  List<AjusteMas> _allAjustes = [];
  List<AjusteMas> _filteredAjustes = [];

  DateTime? _startDate;
  DateTime? _endDate;

  Map<int, Productos> _productosCache = {};
  Map<int, Users> _usersCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAjustes);
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      _allAjustes.clear();
      _filteredAjustes.clear();

      final ajustes = await _ajusteMasController.listAjustesMas();
      final productos = await _productosController.listProductos();
      final users = await _usersController.listUsers();

      setState(() {
        _allAjustes = ajustes;
        _filteredAjustes = ajustes;
        _productosCache = {for (var prod in productos) prod.id_Producto!: prod};
        _usersCache = {for (var us in users) us.id_User!: us};
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterAjustes() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredAjustes = _allAjustes.where((ajuste) {
        final codFolio = (ajuste.ajusteMas_CodFolio ?? '').toLowerCase();
        final idProducto = ajuste.id_Producto?.toString() ?? '';

        // Parsear fecha del string y obtener solo la parte de la fecha (sin hora)
        final fechaAjuste = ajuste.ajusteMas_Fecha != null
            ? DateFormat('dd/MM/yyyy HH:mm').parse(ajuste.ajusteMas_Fecha!)
            : null;

        final fechaAjusteSoloDia = fechaAjuste != null
            ? DateTime(fechaAjuste.year, fechaAjuste.month, fechaAjuste.day)
            : null;

        // Validar texto
        final matchesText = query.isEmpty ||
            codFolio.contains(query) ||
            idProducto.contains(query);

        // Validar rango fechas (comparando solo días)
        bool matchesDate = true;
        if (_startDate != null || _endDate != null) {
          if (fechaAjusteSoloDia == null) return false;

          if (_startDate != null) {
            matchesDate = matchesDate &&
                !fechaAjusteSoloDia.isBefore(DateTime(
                    _startDate!.year, _startDate!.month, _startDate!.day));
          }

          if (_endDate != null) {
            matchesDate = matchesDate &&
                !fechaAjusteSoloDia.isAfter(
                    DateTime(_endDate!.year, _endDate!.month, _endDate!.day));
          }
        }

        return matchesText && matchesDate;
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
      _filterAjustes();
    }
  }

  DateTime? parseDate(String dateString) {
    try {
      final fechaCompleta = DateFormat('dd/MM/yyyy HH:mm').parse(dateString);
      return DateTime(
          fechaCompleta.year, fechaCompleta.month, fechaCompleta.day);
    } catch (e) {
      print('Error al parsear fecha: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Ajuste Más',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade900))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: CustomTextFielTexto(
                          controller: _searchController,
                          labelText: 'Buscar por Folio o ID Producto',
                          prefixIcon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade900,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDateRange(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 201, 230, 242),
                            ),
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            label: Text(
                              _startDate != null && _endDate != null
                                  ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                  : 'Seleccionar rango de fechas',
                              style: const TextStyle(
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                            _filterAjustes();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: _buildListView(),
                ),
              ],
            ),
    );
  }

  Widget _buildListView() {
    if (_filteredAjustes.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No hay ajustes que coincidan con la búsqueda'
              : (_startDate != null || _endDate != null)
                  ? 'No hay ajustes que coincidan con el rango de fechas'
                  : 'No hay ajustes disponibles',
        ),
      );
    }

    // Agrupar ajustes por CodFolio
    Map<String, List<AjusteMas>> groupedAjustes = {};
    for (var ajuste in _filteredAjustes) {
      groupedAjustes.putIfAbsent(ajuste.ajusteMas_CodFolio!, () => []);
      groupedAjustes[ajuste.ajusteMas_CodFolio]!.add(ajuste);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1.4,
      ),
      itemCount: groupedAjustes.keys.length,
      itemBuilder: (context, index) {
        String codFolio = groupedAjustes.keys.elementAt(index);
        List<AjusteMas> ajustes = groupedAjustes[codFolio]!;

        // Tomar el primer ajuste para datos generales
        final ajustePrincipal = ajustes.first;

        // Calcular total de unidades
        double totalUnidades = ajustes.fold(
            0, (sum, item) => sum + (item.ajusteMas_Cantidad ?? 0));

        // Obtener usuario
        final user = _usersCache[ajustePrincipal.id_User];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: const Color.fromARGB(255, 201, 230, 242),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsAjusteMasPage(
                    ajustes: ajustes, // Pasar la lista de ajustes agrupados
                    user: user ??
                        Users(
                            id_User: 0,
                            user_Name:
                                'Desconocido'), // Pasar el usuario o uno por defecto
                    userRole: widget.userRole ??
                        'Usuario', // Pasar el rol del usuario
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Folio: $codFolio',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descripción: ${ajustePrincipal.ajuesteMas_Descripcion ?? 'Sin descripción'}',
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  user != null
                      ? Text(
                          'Realizado por: ${user.user_Name}',
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text('Realizado por: Usuario no encontrado'),
                  const SizedBox(height: 10),
                  Text(
                    'Fecha: ${ajustePrincipal.ajusteMas_Fecha ?? 'Sin fecha'}',
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total Unidades: ${totalUnidades.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Productos: ${ajustes.length}',
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
