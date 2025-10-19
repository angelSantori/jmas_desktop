import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/lectenviar_controller.dart';
import 'package:jmas_desktop/contollers/problemas_lectura_controller.dart';
import 'package:jmas_desktop/lecturas/details_lectura.dart';
import 'package:jmas_desktop/widgets/formularios.dart';

class ListLecturasScreen extends StatefulWidget {
  const ListLecturasScreen({super.key});

  @override
  State<ListLecturasScreen> createState() => _ListLecturasScreenState();
}

class _ListLecturasScreenState extends State<ListLecturasScreen> {
  final ProblemasLecturaController _problemasLecturaController =
      ProblemasLecturaController();
  final LecturaEnviarController _controller = LecturaEnviarController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _leIdController = TextEditingController();

  List<LELista> _lecturas = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Map<int, String> _nombresProblemas = {};

  @override
  void dispose() {
    _periodoController.dispose();
    _leIdController.dispose();
    super.dispose();
  }

  Future<void> _cargarNombresProblemas(List<LELista> lecturas) async {
    final problemasIds = lecturas
        .where((lectura) => lectura.idProblemaLectura != null)
        .map((lectura) => lectura.idProblemaLectura!)
        .toSet();

    if (problemasIds.isEmpty) return;

    final nuevosNombres = <int, String>{};

    for (final id in problemasIds) {
      final nombre =
          await _problemasLecturaController.getNombreProblemaById(id);
      if (nombre != null) {
        nuevosNombres[id] = nombre;
      }
    }

    setState(() {
      _nombresProblemas = nuevosNombres;
    });
  }

  Future<void> _searchLecturas() async {
    if (_periodoController.text.isEmpty && _leIdController.text.isEmpty) {
      _showSnackBar('Ingrese al menos un criterio de búsqueda');
      return;
    }

    setState(() {
      _isLoading = true;
      _lecturas = [];
      _nombresProblemas = {};
    });

    try {
      List<LELista> resultados = [];

      // Buscar por leId si está especificado
      if (_leIdController.text.isNotEmpty) {
        final leId = int.tryParse(_leIdController.text);
        if (leId != null) {
          final lecturasPorLeId = await _controller.getLectEnviarByLeId(leId);
          resultados.addAll(lecturasPorLeId);
        }
      }

      // Si solo se especificó período, obtener todas y filtrar
      if (_leIdController.text.isEmpty && _periodoController.text.isNotEmpty) {
        final todasLasLecturas = await _controller.listLectEnviar();
        resultados = todasLasLecturas
            .where((lectura) => lectura.lePeriodo == _periodoController.text)
            .toList();
      }
      // Si se especificaron ambos, filtrar los resultados por período
      else if (_periodoController.text.isNotEmpty) {
        resultados = resultados
            .where((lectura) => lectura.lePeriodo == _periodoController.text)
            .toList();
      }

      setState(() {
        _lecturas = resultados;
        _hasSearched = true;
      });

      if (resultados.isNotEmpty) {
        await _cargarNombresProblemas(resultados);
      }

      if (resultados.isEmpty) {
        _showSnackBar(
            'No se encontraron lecturas con los criterios especificados');
      }
    } catch (e) {
      _showSnackBar('Error al buscar lecturas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _periodoController.clear();
      _leIdController.clear();
      _lecturas = [];
      _hasSearched = false;
    });
  }

  void _showDetails(LELista lectura) {
    showDialog(
      context: context,
      builder: (context) => DetailsLecturaDialog(lectura: lectura),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Aún no registrada';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildLecturaCard(LELista lectura) {
    // Manejo seguro de valores nulos
    final estado = lectura.leEstado ?? false;
    final nombre = lectura.leNombre ?? 'No disponible';
    final cuenta = lectura.leCuenta ?? 'No disponible';
    final idPadron = lectura.leId?.toString() ?? 'No disponible';
    final lecturaAnterior = lectura.leLecturaAnterior?.toString() ?? 'N/A';
    final lecturaActual =
        lectura.leLecturaActual?.toString() ?? 'Aún sin Registrar';
    final tieneProblema = lectura.idProblemaLectura != null;
    final nombreProblema = tieneProblema
        ? _nombresProblemas[lectura.idProblemaLectura] ??
            'Problema #${lectura.idProblemaLectura}'
        : '';

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: InkWell(
        onTap: () => _showDetails(lectura),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            // Cambiado a Row para diseño horizontal
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda - Información principal
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con ID y Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.numbers,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID Registro: ${lectura.idLectEnviar}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estado ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                estado ? Icons.check : Icons.pending,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                estado ? 'Registrada' : 'Pendiente',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Información del cliente
                    _buildInfoRow(Icons.person, 'Nombre:', nombre),
                    _buildInfoRow(Icons.credit_card, 'Cuenta:', cuenta),
                    _buildInfoRow(Icons.badge, 'ID Padrón:', idPadron),

                    // Fecha
                    _buildInfoRow(Icons.calendar_today, 'Fecha de registro:',
                        _formatDate(lectura.leFecha)),
                  ],
                ),
              ),

              // Línea divisoria vertical
              Container(
                width: 1,
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.grey.shade300,
              ),

              // Columna derecha - Información de lecturas y problemas
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información de lecturas
                    _buildInfoRow(
                        Icons.speed, 'Lectura Anterior:', lecturaAnterior),
                    _buildInfoRow(
                        Icons.arrow_forward, 'Lectura Actual:', lecturaActual),

                    if (lectura.lePeriodo != null)
                      _buildInfoRow(
                          Icons.date_range, 'Período:', lectura.lePeriodo!),

                    if (lectura.leRuta != null)
                      _buildInfoRow(Icons.map, 'Ruta:', lectura.leRuta!),

                    // Problema si existe
                    if (tieneProblema) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              lectura.idProblemaLectura != 1
                                  ? Icons.warning_amber
                                  : Icons.check_circle_outline_rounded,
                              size: 25,
                              color: lectura.idProblemaLectura != 1
                                  ? Colors.red.shade700
                                  : Colors.green.shade900,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Problema #${lectura.idProblemaLectura}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: lectura.idProblemaLectura != 1
                                          ? Colors.red.shade700
                                          : Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    nombreProblema,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: lectura.idProblemaLectura != 1
                                          ? Colors.red.shade600
                                          : Colors.green.shade900,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Lecturas'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          if (_hasSearched)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar búsqueda',
            ),
        ],
      ),
      body: Column(
        children: [
          // Formulario de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextFielTexto(
                        controller: _periodoController,
                        labelText: 'Período (Ej: 202401)',
                        prefixIcon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextFielTexto(
                        controller: _leIdController,
                        labelText: 'ID Padrón',
                        prefixIcon: Icons.format_list_numbered,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchLecturas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              children: [
                                Icon(Icons.search, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Buscar',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Buscando lecturas...'),
                      ],
                    ),
                  )
                : _hasSearched
                    ? _lecturas.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No se encontraron lecturas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              // Cambiado a ListView para tarjetas horizontales
                              itemCount: _lecturas.length,
                              itemBuilder: (context, index) {
                                return _buildLecturaCard(_lecturas[index]);
                              },
                            ),
                          )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Ingrese los criterios de búsqueda',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Puede buscar por período, ID padrón o ambos',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
