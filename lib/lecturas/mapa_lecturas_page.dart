// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// import 'package:intl/intl.dart';
// import 'package:jmas_desktop/contollers/lectenviar_controller.dart';

// class MapaLecturasPage extends StatefulWidget {
//   const MapaLecturasPage({super.key});

//   @override
//   State<MapaLecturasPage> createState() => _MapaLecturasPageState();
// }

// class _MapaLecturasPageState extends State<MapaLecturasPage> {
//   final LectenviarController _controller = LectenviarController();
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   bool _isLoading = true;
//   bool _showRoute = false;
//   late GoogleMapController _mapController;
//   final int _mapId = 1; // ID único para el mapa

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
    
//     final lecturas = await _controller.listLecturas();
//     final filtered = lecturas.where((l) => 
//       l.estado == true && 
//       l.ubicacion != null && 
//       l.ubicacion!.contains(',')
//     ).toList();

//     filtered.sort((a, b) => _parseDate(a.felean ?? '').compareTo(_parseDate(b.felean ?? '')));

//     _updateMarkers(filtered);
//     setState(() => _isLoading = false);
//   }

//   DateTime _parseDate(String dateStr) {
//     try {
//       return DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
//     } catch (e) {
//       return DateTime.now();
//     }
//   }

//   void _updateMarkers(List<LectEnviar> lecturas) {
//     _markers.clear();
//     _polylines.clear();

//     final points = <LatLng>[];
    
//     for (final lectura in lecturas) {
//       final coords = lectura.ubicacion!.split(',');
//       if (coords.length == 2) {
//         final lat = double.tryParse(coords[0]);
//         final lng = double.tryParse(coords[1]);
//         if (lat != null && lng != null) {
//           final point = LatLng(lat, lng);
//           points.add(point);
//           _markers.add(Marker(
//             markerId: MarkerId(lectura.idLectEnviar.toString()),
//             position: point,
//             infoWindow: InfoWindow(
//               title: 'Cuenta: ${lectura.cuenta}',
//               snippet: lectura.nombre,
//             ),
//           ));
//         }
//       }
//     }

//     if (_showRoute && points.length > 1) {
//       _polylines.add(Polyline(
//         polylineId: const PolylineId('ruta'),
//         points: points,
//         color: Colors.blue,
//         width: 4,
//       ));
//     }
//   }

//   Future<void> _zoomToFit() async {
//     if (_markers.isEmpty) return;
//     final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
//     await _mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }

//   LatLngBounds _calculateBounds(List<LatLng> points) {
//     var sw = LatLng(double.infinity, double.infinity);
//     var ne = LatLng(-double.infinity, -double.infinity);

//     for (var point in points) {
//       sw = LatLng(
//         point.latitude < sw.latitude ? point.latitude : sw.latitude,
//         point.longitude < sw.longitude ? point.longitude : sw.longitude,
//       );
//       ne = LatLng(
//         point.latitude > ne.latitude ? point.latitude : ne.latitude,
//         point.longitude > ne.longitude ? point.longitude : ne.longitude,
//       );
//     }
//     return LatLngBounds(northeast: ne, southwest: sw);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mapa de Lecturas'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//           IconButton(
//             icon: Icon(_showRoute ? Icons.route : Icons.route_outlined),
//             onPressed: () {
//               setState(() {
//                 _showRoute = !_showRoute;
//                 _loadData(); // Recargar para actualizar la ruta
//               });
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _markers.isEmpty
//               ? const Center(child: Text('No hay datos para mostrar'))
//               : _buildMapView(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _zoomToFit,
//         child: const Icon(Icons.zoom_out_map),
//       ),
//     );
//   }

//   Widget _buildMapView() {
//     return GoogleMapsFlutterPlatform.instance.buildView(
//       _mapId,
//       onPlatformViewCreated: (id) {
//         _mapController = GoogleMapController(
//           PlatformWebViewControllerCreationParams(),
//           GoogleMapsFlutterPlatform.instance,
//         );
//         WidgetsBinding.instance.addPostFrameCallback((_) => _zoomToFit());
//       },
//       initialCameraPosition: const CameraPosition(
//         target: LatLng(28.1538577, -105.3955114),
//         zoom: 14,
//       ),
//       markers: _markers,
//       polylines: _polylines,
//       myLocationEnabled: false,
//       myLocationButtonEnabled: false,
//     );
//   }
// }