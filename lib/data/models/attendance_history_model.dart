import 'employee_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Attendance history model for employee detail page
/// Maps to API response from /absensi/{id}
class AttendanceHistoryModel {
  final int id;
  final int userId;
  final DateTime tanggal;
  final String clockIn;
  final String? clockInImage;
  final String? clockInLat;
  final String? clockInLong;
  final String? clockOut;
  final String? clockOutImage;
  final String? clockOutLat;
  final String? clockOutLong;
  final int? lateDuration;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EmployeeModel? user;

  AttendanceHistoryModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.clockIn,
    this.clockInImage,
    this.clockInLat,
    this.clockInLong,
    this.clockOut,
    this.clockOutImage,
    this.clockOutLat,
    this.clockOutLong,
    this.lateDuration,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id: json['id'] is int
          ? json['id']
          : (json['id'] != null ? int.parse(json['id'].toString()) : 0),
      userId: json['user_id'] is int
          ? json['user_id']
          : (json['user_id'] != null
                ? int.parse(json['user_id'].toString())
                : 0),
      tanggal: DateTime.parse(json['tanggal'] as String),
      clockIn: json['clock_in'] as String,
      clockInImage: json['clock_in_image'] as String?,
      clockInLat: json['clock_in_lat'] as String?,
      clockInLong: json['clock_in_long'] as String?,
      clockOut: json['clock_out'] as String?,
      clockOutImage: json['clock_out_image'] as String?,
      clockOutLat: json['clock_out_lat'] as String?,
      clockOutLong: json['clock_out_long'] as String?,
      lateDuration: json['late_duration'] != null
          ? (json['late_duration'] is int
                ? json['late_duration']
                : int.parse(json['late_duration'].toString()))
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null
          ? EmployeeModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal.toIso8601String(),
      'clock_in': clockIn,
      'clock_in_image': clockInImage,
      'clock_in_lat': clockInLat,
      'clock_in_long': clockInLong,
      'clock_out': clockOut,
      'clock_out_image': clockOutImage,
      'clock_out_lat': clockOutLat,
      'clock_out_long': clockOutLong,
      'late_duration': lateDuration,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  bool get hasCheckedOut => clockOut != null;

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'alpha':
        return 'Alpha';
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      default:
        return status;
    }
  }

  String get formattedDate {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    // Use local time (WIB) for display
    final localDate = tanggal.toLocal();
    return '${localDate.day} ${months[localDate.month]} ${localDate.year}';
  }

  /// Get full URL for clock-in image
  String? get clockInImageUrl {
    final baseUrl = dotenv.env['BASE_URL'];
    final image = clockInImage;
    if (baseUrl == null || image == null || image.isEmpty) return null;
    final base = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$base/$image';
  }

  /// Get full URL for clock-out image
  String? get clockOutImageUrl {
    final baseUrl = dotenv.env['BASE_URL'];
    final image = clockOutImage;
    if (baseUrl == null || image == null || image.isEmpty) return null;
    final base = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$base/$image';
  }
}
