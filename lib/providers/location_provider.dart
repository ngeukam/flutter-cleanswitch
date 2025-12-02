import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  error,
  permissionDenied,
  serviceDisabled
}

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  
  LocationStatus _status = LocationStatus.initial;
  String? _currentLocation;
  String? _error;
  bool _isLoading = false;

  LocationProvider(this._locationService);

  // Getters
  LocationStatus get status => _status;
  String? get currentLocation => _currentLocation;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasLocation => _currentLocation != null && _currentLocation!.isNotEmpty;

  // Methods
  Future<void> getCurrentLocation() async {
    _setLoading(true);
    _error = null;
    _status = LocationStatus.loading;
    
    try {
      final location = await _locationService.getCurrentLocationOnDashboard();
      
      if (location != null) {
        _currentLocation = location;
        _status = LocationStatus.success;
      } else {
        _currentLocation = null;
        _status = LocationStatus.permissionDenied;
        _error = 'Location permission denied or service unavailable';
      }
    } catch (e) {
      _currentLocation = null;
      _status = LocationStatus.error;
      _error = 'Failed to get location: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  void clearLocation() {
    _currentLocation = null;
    _status = LocationStatus.initial;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_status == LocationStatus.error) {
      _status = LocationStatus.initial;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}