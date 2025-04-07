import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  //final String apiURL = 'https://localhost:5001/api';
  //final String apiURL = 'http://localhost/api';
  final String apiURL = 'http://200.200.200.155:5000/api';
  //final String apiURL = 'https://jmasapi.up.railway.app/api';
  //final String apiURL = 'http://192.168.0.15:8080/api';

  //Save token en almacenamiento local
  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  //Obtener token del almacenamiento local
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  //Delete token logout
  Future<void> deleteToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  //Decodificar el token
  Future<Map<String, dynamic>?> decodeToken() async {
    final String? token = await getToken();
    if (token == null) return null;

    // Decodificar el payload del token
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }
}
