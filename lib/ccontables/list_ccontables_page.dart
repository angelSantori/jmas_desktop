import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/ccontables_controller.dart';

class ListCcontablesPage extends StatefulWidget {
  const ListCcontablesPage({super.key});

  @override
  State<ListCcontablesPage> createState() => _ListCcontablesPageState();
}

class _ListCcontablesPageState extends State<ListCcontablesPage> {
  final CcontablesController _ccontablesController = CcontablesController();

  List<CContables> _filteredCuentas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isLoading = true;

  Future<void> _loadData() async {
    try {
      List<CContables> ccuentas = await _ccontablesController.listCcontables();
      setState(() {
        _filteredCuentas = ccuentas;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Cuentas Contables'),
      ),
      body: _filteredCuentas.isEmpty
          ? Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('No se pudieron cargar los datos'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 450,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: _filteredCuentas.length,
              itemBuilder: (context, index) {
                final cuenta = _filteredCuentas[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: const Color.fromARGB(255, 201, 230, 242),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('Cuenta: ${cuenta.cC_Cuenta}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.black),
                        Text('idProducto: ${cuenta.idProducto}'),
                        const SizedBox(height: 10),
                        Text('SCTA: ${cuenta.cC_SCTA}'),
                        const SizedBox(height: 10),
                        Text('CVEPROD: ${cuenta.cC_CVEPROD ?? 'Sin CVEPROD'}'),
                        const SizedBox(height: 10),
                        Text('Detalle: ${cuenta.cC_Detalle}'),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
