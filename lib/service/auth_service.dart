import 'dart:convert';
import 'package:jmas_desktop/contollers/users_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiURL = 'https://localhost:5001/api';
  Users? _currentUser;
  //final String apiURL = 'http://localhost/api';
  //final String apiURL = 'http://200.200.200.155:5000/api';
  //final String apiURL = 'https://jmasapi.up.railway.app/api';
  //final String apiURL = 'http://192.168.0.15:8080/api';

  // Guardar datos del usuario al iniciar sesión
  Future<void> saveUserData(Users user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(user.toMap()));
    _currentUser = user;
  }

  // Obtener datos del usuario
  Future<Users?> getUserData() async {
    if (_currentUser != null) return _currentUser;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      _currentUser = Users.fromJson(userData);
      return _currentUser;
    }
    return null;
  }

  // Limpiar datos al cerrar sesión
  Future<void> clearAuthData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userData');
    _currentUser = null;
  }

  // Verificar permisos
  Future<bool> hasPermission(String permission) async {
    final user = await getUserData();
    if (user?.role == null) return false;

    switch (permission) {
      case 'view':
        return user!.role!.canView ?? false;
      case 'add':
        return user!.role!.canAdd ?? false;
      case 'edit':
        return user!.role!.canEdit ?? false;
      case 'delete':
        return user!.role!.canDelete ?? false;
      case 'manage_users':
        return user!.role!.canManageUsers ?? false;
      case 'manage_roles':
        return user!.role!.canManageRoles ?? false;
      default:
        return false;
    }
  }

  // Métodos rápidos para permisos comunes
  Future<bool> canView() => hasPermission('view');
  Future<bool> canEdit() => hasPermission('edit');
  Future<bool> canDelete() => hasPermission('delete');
  Future<bool> canManageUsers() => hasPermission('manage_users');
  Future<bool> canManageRoles() => hasPermission('manage_roles');

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
