import 'dart:async';
import 'package:cleanswitch_staff/providers/auth_provider.dart';
import 'package:cleanswitch_staff/providers/clock_in_out_provider.dart';
import 'package:cleanswitch_staff/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleanswitch_staff/widgets/common/custom_app_bar.dart';
import 'package:cleanswitch_staff/widgets/constant/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockInOutScreen extends StatefulWidget {
  const ClockInOutScreen({super.key});

  @override
  State<ClockInOutScreen> createState() => ClockInOutScreenState();
}

class ClockInOutScreenState extends State<ClockInOutScreen> {
  DateTime? _shiftStartTime;
  Duration _shiftDuration = Duration.zero;
  Timer? _shiftTimer;

  @override
  void initState() {
    super.initState();
    _loadShiftData();
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clockInOutProvider = Provider.of<ClockInOutProvider>(context, listen: false);
    
    if (authProvider.userId != null) {
      await clockInOutProvider.getCurrentStatus(authProvider.userId!);
    }
  }

  Future<void> _loadShiftData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getInt('shiftStartTime');
      
      if (savedTime != null) {
        final savedStartTime = DateTime.fromMillisecondsSinceEpoch(savedTime);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final clockInOutProvider = Provider.of<ClockInOutProvider>(context, listen: false);
        
        if (authProvider.userId != null) {
          final status = await clockInOutProvider.getCurrentStatus(authProvider.userId!);
          
          if (status != null && status.isOnDuty) {
            setState(() {
              _shiftStartTime = savedStartTime;
              _shiftDuration = DateTime.now().difference(savedStartTime);
            });
            _startShiftTimer();
          } else {
            await prefs.remove('shiftStartTime');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading shift data: $e');
    }
  }

  void _startShiftTimer() {
    _shiftTimer?.cancel();

    if (_shiftStartTime != null) {
      _shiftDuration = DateTime.now().difference(_shiftStartTime!);
    }

    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _shiftStartTime != null) {
        setState(() {
          _shiftDuration = DateTime.now().difference(_shiftStartTime!);
        });
      }
    });
  }

  Future<void> _toggleDutyStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clockInOutProvider = Provider.of<ClockInOutProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (authProvider.userId == null) return;

    // Check location permissions
    if (locationProvider.status != LocationStatus.success) {
      await locationProvider.getCurrentLocation();
      if (locationProvider.status != LocationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are required')),
        );
        return;
      }
    }

    try {
      if (_shiftStartTime != null) {
        // Clock out
        await clockInOutProvider.clockOut(authProvider.userId!);
        if (mounted) {
          setState(() {
            _shiftStartTime = null;
            _shiftDuration = Duration.zero;
          });
          _shiftTimer?.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('shiftStartTime');
        }
      } else {
        // Clock in
        await clockInOutProvider.clockIn(authProvider.userId!);
        final now = DateTime.now();
        if (mounted) {
          setState(() {
            _shiftStartTime = now;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('shiftStartTime', now.millisecondsSinceEpoch);
          _startShiftTimer();
        }
      }
    } catch (e) {
      // Error handling is done in the provider
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  bool get _isOnDuty => _shiftStartTime != null;

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clockInOutProvider = Provider.of<ClockInOutProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Service Attendance'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(authProvider),
            const SizedBox(height: 32),
            
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 24),
            
            // Location Status
            _buildLocationStatus(locationProvider),
            
            // Error Display
            if (clockInOutProvider.error != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(clockInOutProvider),
            ],
            
            const Spacer(),
            
            // Action Button
            _buildActionButton(clockInOutProvider, locationProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        if (authProvider.fullName != null) ...[
          Text(
            'Welcome, ${authProvider.fullName}!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          'Track your work hours and attendance',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isOnDuty
                ? [Colors.green.shade50, Colors.blue.shade50]
                : [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Column(
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isOnDuty ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnDuty ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOnDuty ? Icons.work : Icons.work_outline,
                    color: _isOnDuty ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isOnDuty ? Colors.green : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Shift Information
            if (_shiftStartTime != null) ...[
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Shift Started',
                value: _shiftStartTime!.toLocal().toString().split('.')[0],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.timer,
                label: 'Duration',
                value: _formatDuration(_shiftDuration),
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ] else ...[
              Icon(
                Icons.schedule,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No active shift',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStatus(LocationProvider locationProvider) {
    final isLocationEnabled = locationProvider.status == LocationStatus.success;
    final isLocationError = locationProvider.status == LocationStatus.error || 
                           locationProvider.status == LocationStatus.permissionDenied;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocationEnabled ? Colors.green.shade50 : 
               isLocationError ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocationEnabled ? Colors.green : 
                 isLocationError ? Colors.orange : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocationEnabled ? Icons.location_on : Icons.location_off,
            color: isLocationEnabled ? Colors.green : 
                   isLocationError ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocationEnabled ? 'Location services enabled' :
                  isLocationError ? 'Location access required' : 'Checking location...',
                  style: TextStyle(
                    color: isLocationEnabled ? Colors.green : 
                           isLocationError ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (locationProvider.currentLocation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    locationProvider.currentLocation!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (!isLocationEnabled && !locationProvider.isLoading)
            TextButton(
              onPressed: locationProvider.getCurrentLocation,
              child: const Text('Enable'),
            ),
          if (locationProvider.isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ClockInOutProvider clockInOutProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clockInOutProvider.error!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade600),
            onPressed: clockInOutProvider.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ClockInOutProvider clockInOutProvider, 
    LocationProvider locationProvider
  ) {
    // final isLocationReady = locationProvider.status == LocationStatus.success;
    final isLoading = clockInOutProvider.isLoading || locationProvider.isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _toggleDutyStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isOnDuty ? Colors.red : AppColor.appBannerColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOnDuty ? Icons.logout : Icons.login,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isOnDuty ? 'CLOCK OUT' : 'CLOCK IN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}