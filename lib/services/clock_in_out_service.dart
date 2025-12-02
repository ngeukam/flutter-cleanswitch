import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cleanswitch_staff/models/staff_location.dart';
import 'package:cleanswitch_staff/services/api_service.dart';

class ClockInOutService {
  final ApiService _apiService;
  ClockInOutService(this._apiService);

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  Future<Position> getCurrentPosition() async {
    if (!await _checkPermissions()) {
      throw Exception('Location permissions not granted');
    }
    
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  Future<void> clockIn(String staffId) async {
    final position = await getCurrentPosition();
    await _apiService.post(
      '/locations/clock/',
      StaffLocation(
        staffId: staffId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        isOnDuty: true,
      ).toJson(),
    );
  }

  Future<void> clockOut(String staffId) async {
    final position = await getCurrentPosition();
    await _apiService.post(
      '/locations/clock/',
      StaffLocation(
        staffId: staffId,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        isOnDuty: false,
      ).toJson(),
    );
  }

  Future<StaffLocation?> getCurrentStatus(String staffId) async {
    final response = await _apiService.get('/locations/status/?staff_id=$staffId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data != null ? StaffLocation.fromJson(data) : null;
    } else {
      throw Exception('Failed to get current status');
    }
  }
}