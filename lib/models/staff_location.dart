class StaffLocation {
  final String staffId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isOnDuty;

  StaffLocation({
    required this.staffId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isOnDuty,
  });

  factory StaffLocation.fromJson(Map<String, dynamic> json) {
    return StaffLocation(
      staffId: (json['staff_id'] ?? json['staff']).toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isOnDuty: json['is_on_duty'] ?? json['isOnDuty'] ?? false,
    );
  }

  static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'is_on_duty': isOnDuty,
    };
  }
}
