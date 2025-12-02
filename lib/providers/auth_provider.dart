import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _userName;
  String? _userRole;
  String? _fullName;
  String? _userId;
  List<dynamic> _assignedProperties = [];
  String? _department;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userRole => _userRole;
  String? get fullName => _fullName;
  String? get userId => _userId;
  List<dynamic> get assignedProperties => _assignedProperties;
  String? get department => _department;

  AuthProvider() {
    _initializeAuthState();
  }

  // Initialiser l'état d'authentification au démarrage
  Future<void> _initializeAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      if (_isAuthenticated) {
        await _loadUserData();
      }
    } catch (e) {
      _errorMessage = 'Error initializing authentication';
      if (kDebugMode) {
        print('AuthProvider initialization error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les données utilisateur
  Future<void> _loadUserData() async {
    _userName = await _authService.getUserName();
    _userRole = await _authService.getUserRole();
    _fullName = await _authService.getFullName();
    _userId = await _authService.getUserId();
    _assignedProperties = await _authService.getassignedProperties();
    _department = await _authService.getDepartment();
  }

  // 🔐 Connexion
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);

      if (success) {
        _isAuthenticated = true;
        await _loadUserData();
        _errorMessage = null;
      } else {
        _errorMessage = 'Incorrect credentials';
        _isAuthenticated = false;
      }

      return success;
    } catch (e) {
      _errorMessage = 'Connection error: ${e.toString()}';
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚪 Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userName = null;
      _userRole = null;
      _fullName = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error while logging out';
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔑 Changement de mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔁 Rafraîchir le token
  Future<bool> refreshToken() async {
    try {
      final success = await _authService.refreshToken();
      if (success) {
        await _loadUserData();
      } else {
        _isAuthenticated = false;
        _userName = null;
        _userRole = null;
        _fullName = null;
      }
      return success;
    } catch (e) {
      _isAuthenticated = false;
      _userName = null;
      _userRole = null;
      _fullName = null;
      notifyListeners();
      return false;
    }
  }

  // Vérifier et mettre à jour l'état d'authentification
  Future<void> checkAuthentication() async {
    final wasAuthenticated = _isAuthenticated;

    try {
      _isAuthenticated = await _authService.isAuthenticated();

      if (_isAuthenticated) {
        await _loadUserData();
      } else {
        _userName = null;
        _userRole = null;
        _fullName = null;
      }

      // Notifier seulement si l'état a changé
      if (wasAuthenticated != _isAuthenticated) {
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      _userName = null;
      _userRole = null;
      _fullName = null;
      notifyListeners();
    }
  }

  // Effacer les messages d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Forcer le rafraîchissement des données utilisateur
  Future<void> refreshUserData() async {
    if (_isAuthenticated) {
      await _loadUserData();
      notifyListeners();
    }
  }
}
