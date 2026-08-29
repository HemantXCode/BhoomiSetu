class GPSRecordModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final DateTime timestamp;

  GPSRecordModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    required this.timestamp,
  });

  factory GPSRecordModel.fromJson(Map<String, dynamic> json) {
    return GPSRecordModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
