import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 🔐 Connexion utilisateur
  Future<bool> login(String username, String password) async {
    final response = await _apiService.post('/auth/login/', {
      'username': username,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['access'] != null) {
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        return true;
      }
    }
    return false;
  }

  /// 🚪 Déconnexion
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// ✅ Vérifie si l'utilisateur est encore authentifié
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // En cas d'erreur de décodage du JWT
      return false;
    }
  }

  /// 👤 Récupère et décode le token JWT
  Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  /// 🔁 Rafraîchit le token d'accès
  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    final response = await _apiService.post('/auth/refresh/', {
      'refresh': refreshToken,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access']);
      return true;
    } else {
      // Si le refresh token est expiré, déconnecter l'utilisateur
      await logout();
      return false;
    }
  }

  /// 🔑 Change le mot de passe de l'utilisateur
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiService.patch('/auth/change-password/', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Password change failed';
      throw Exception(errorMessage);
    }
  }

  /// 🧠 Récupère des infos utilisateur depuis le JWT
  Future<String?> getUserId() async {
    final decoded = await getDecodedToken();
    return decoded?['user_id'].toString();
  }

  Future<String?> getUserName() async {
    final decoded = await getDecodedToken();
    return decoded?['username'];
  }

  Future<String?> getUserRole() async {
    final decoded = await getDecodedToken();
    return decoded?['role'];
  }

  Future<String?> getFullName() async {
    final decoded = await getDecodedToken();
    if (decoded == null) return null;

    final firstName = decoded['first_name'] ?? '';
    final lastName = decoded['last_name'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) return null;
    return '$firstName $lastName'.trim();
  }

  Future<String?> getDepartment() async {
    final decoded = await getDecodedToken();
    if (decoded == null) return null;
    return decoded['department'];
  }

  Future<List<dynamic>> getassignedProperties() async {
    final decoded = await getDecodedToken();
    return decoded?['properties_assigned'] ?? [];
  }

  /// 🔄 Méthode utilitaire pour les appels API avec gestion automatique du token
  Future<http.Response> authenticatedApiCall(
    Future<http.Response> Function() apiCall,
  ) async {
    // Vérifier si le token est expiré
    if (await isAuthenticated()) {
      return await apiCall();
    } else {
      // Essayer de rafraîchir le token
      final refreshed = await refreshToken();
      if (refreshed) {
        return await apiCall();
      } else {
        throw Exception('Session expired. Please log in again.');
      }
    }
  }
}

// final authService = AuthService();

// // Au lieu de appeler _apiService directement :
// await authService.authenticatedApiCall(
//   () => _apiService.get('/api/protected-endpoint/'),
// );
