import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  // Vérifier l'état global de la connexion
  static Future<NetworkStatus> checkNetworkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      return NetworkStatus.disconnected;
    }
    
    final hasInternet = await InternetConnectionChecker().hasConnection;
    return hasInternet ? NetworkStatus.connected : NetworkStatus.noInternet;
  }

  // Stream pour écouter les changements de connexion
  static Stream<NetworkStatus> get onNetworkStatusChanged {
    return Connectivity().onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) {
        return NetworkStatus.disconnected;
      }
      
      final hasInternet = await InternetConnectionChecker().hasConnection;
      return hasInternet ? NetworkStatus.connected : NetworkStatus.noInternet;
    });
  }

  // Vérification simple (booléenne)
  static Future<bool> get isConnected async {
    final status = await checkNetworkStatus();
    return status == NetworkStatus.connected;
  }
}

enum NetworkStatus {
  connected,       // Connecté à internet
  noInternet,      // Connecté à un réseau mais pas d'internet
  disconnected     // Pas de connexion du tout
}