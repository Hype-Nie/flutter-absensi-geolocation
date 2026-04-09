class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String checkInPhoto;
  final String? checkOutPhoto;
  final double checkInLat;
  final double checkInLon;
  final double? checkOutLat;
  final double? checkOutLon;
  final String? checkInAddress;
  final String? checkOutAddress;
  final bool isLate;
  final String? notes;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInPhoto,
    this.checkOutPhoto,
    required this.checkInLat,
    required this.checkInLon,
    this.checkOutLat,
    this.checkOutLon,
    this.checkInAddress,
    this.checkOutAddress,
    required this.isLate,
    this.notes,
    required this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      checkInPhoto: json['check_in_photo'] ?? '',
      checkOutPhoto: json['check_out_photo'],
      checkInLat: (json['check_in_lat'] ?? 0.0).toDouble(),
      checkInLon: (json['check_in_lon'] ?? 0.0).toDouble(),
      checkOutLat: json['check_out_lat']?.toDouble(),
      checkOutLon: json['check_out_lon']?.toDouble(),
      checkInAddress: json['check_in_address'],
      checkOutAddress: json['check_out_address'],
      isLate: json['is_late'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'check_in_lat': checkInLat,
      'check_in_lon': checkInLon,
      'check_out_lat': checkOutLat,
      'check_out_lon': checkOutLon,
      'check_in_address': checkInAddress,
      'check_out_address': checkOutAddress,
      'is_late': isLate,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get hasCheckedOut => checkOutTime != null;

  Duration? get workDuration {
    final checkout = checkOutTime;
    if (checkout == null) return null;
    return checkout.difference(checkInTime);
  }

  String get workDurationFormatted {
    final duration = workDuration;
    if (duration == null) return '-';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}j ${minutes}m';
  }
}
