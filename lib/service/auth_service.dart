import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiURL = 'https://localhost:7048/api';

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
}
