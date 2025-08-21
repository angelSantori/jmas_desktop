import 'dart:ui';

import 'package:flutter/material.dart';

final List<String> unMedEntrada = [
  'Caja',
  'Paquete',
  'Saco',
  'Tarima',
  'Contenedor',
  'Bolsa',
  'Tambor',
  'Rollo',
  'Pallet',
  'Barril',
  'Servicio',
];

final List<String> unMedSalida = [
  'Pza (Pieza)',
  'Kg (Kilogramo)',
  'Lts (Litros)',
  'Mto (Metro)',
  'Cilin (Cilindro)',
  'Gfon (Galón)',
  'Gr (Gramos)',
  'Ml (Mililitros)',
  'Un (Unidad)',
  'Servicio'
];

final List<String> rack = ['R1', 'R2', 'R3'];
final List<String> nivel = ['N1', 'N2', 'N3', 'N4', 'N5'];
final List<String> letra = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

final List<String> estadoLista = [
  'Disponible',
  'Deteriorado',
  'Obsoleto',
];

Color getEstadoColor(String? estado) {
  switch (estado?.toLowerCase()) {
    case 'disponible':
      return Colors.green;
    case 'deteriorado':
      return Colors.orange;
    case 'obsoleto':
      return Colors.red;
    default:
      return Colors.grey.shade900;
  }
}
