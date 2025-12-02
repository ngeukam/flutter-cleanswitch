import 'package:flutter/material.dart';
import '../services/network_service.dart';

class NetworkProvider with ChangeNotifier {
  NetworkStatus _networkStatus = NetworkStatus.connected;
  bool _isLoading = false;

  NetworkStatus get networkStatus => _networkStatus;
  bool get isLoading => _isLoading;
  bool get isConnected => _networkStatus == NetworkStatus.connected;

  NetworkProvider() {
    _initNetworkListener();
  }

  void _initNetworkListener() async {
    // Vérifier l'état initial
    await _checkInitialStatus();
    
    // Écouter les changements
    NetworkService.onNetworkStatusChanged.listen((status) {
      _updateNetworkStatus(status);
    });
  }

  Future<void> _checkInitialStatus() async {
    _setLoading(true);
    _networkStatus = await NetworkService.checkNetworkStatus();
    _setLoading(false);
    notifyListeners();
  }

  void _updateNetworkStatus(NetworkStatus status) {
    if (_networkStatus != status) {
      _networkStatus = status;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Vérifier manuellement la connexion
  Future<void> checkConnection() async {
    _setLoading(true);
    _networkStatus = await NetworkService.checkNetworkStatus();
    _setLoading(false);
    notifyListeners();
  }
}