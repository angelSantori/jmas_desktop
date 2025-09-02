import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jmas_desktop/service/auth_service.dart';

class ConsultasController {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> consultaUniversal(int idProducto) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${_authService.apiNubeURL}/Productos/ConsultaUniversal/$idProducto'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData; // Contiene 'entradas' y 'salidas'
      } else {
        print(
            'Error en consulta universal: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error en consulta universal: $e');
      return {};
    }
  }
}
