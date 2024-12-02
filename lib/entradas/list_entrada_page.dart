import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/entradas_controller.dart';

class ListEntradaPage extends StatefulWidget {
  const ListEntradaPage({super.key});

  @override
  State<ListEntradaPage> createState() => _ListEntradaPageState();
}

class _ListEntradaPageState extends State<ListEntradaPage> {
  final EntradasController _entradasController = EntradasController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Entradas'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: FutureBuilder<List<Entradas>>(
          future: _entradasController.listEntradas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay entradas registradas'),
              );
            }

            final entradas = snapshot.data!;

            return ListView.builder(
              itemCount: entradas.length,
              itemBuilder: (context, index) {
                final entrada = entradas[index];
                return Card(
                  color: Colors.blue.shade900,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entrada.entrada_Folio} - ${entrada.entrada_Fecha}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(''),

                              const SizedBox(height: 10),

                              //Unidades
                              Text(
                                'Unidades: ${entrada.entrada_Unidades}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              //Costo
                              Text(
                                'Costo: \$${entrada.entrada_Costo}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        //Folio
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
