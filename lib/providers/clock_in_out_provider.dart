import 'package:cleanswitch_staff/models/staff_location.dart';
import 'package:flutter/material.dart';
import 'package:cleanswitch_staff/services/clock_in_out_service.dart';

class ClockInOutProvider extends ChangeNotifier {
  final ClockInOutService _locationService;
  
  ClockInOutProvider({required ClockInOutService locationService}) 
      : _locationService = locationService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  Future<void> clockIn(String staffId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _locationService.clockIn(staffId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clockOut(String staffId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _locationService.clockOut(staffId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StaffLocation?> getCurrentStatus(String staffId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = await _locationService.getCurrentStatus(staffId);
      return status;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}