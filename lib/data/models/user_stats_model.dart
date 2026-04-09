import 'employee_model.dart';

/// User statistics model for attendance statistics
/// Maps to API response from /absensi/user/{id}/stats
class UserStatsModel {
  final EmployeeModel user;
  final AttendanceStats stats;

  UserStatsModel({required this.user, required this.stats});

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      user: EmployeeModel.fromJson(json['user'] as Map<String, dynamic>),
      stats: AttendanceStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'stats': stats.toJson()};
  }
}

/// Attendance statistics data
class AttendanceStats {
  final int totalHadir;
  final int totalTerlambat;
  final int totalIzin;
  final int totalSakit;
  final String totalLateMinutes;
  final double? averageLateMinutes;

  AttendanceStats({
    required this.totalHadir,
    required this.totalTerlambat,
    required this.totalIzin,
    required this.totalSakit,
    required this.totalLateMinutes,
    this.averageLateMinutes,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalHadir: json['total_hadir'] as int? ?? 0,
      totalTerlambat: json['total_terlambat'] as int? ?? 0,
      totalIzin: json['total_izin'] as int? ?? 0,
      totalSakit: json['total_sakit'] as int? ?? 0,
      totalLateMinutes: json['total_late_minutes']?.toString() ?? '0',
      averageLateMinutes: json['average_late_minutes'] != null
          ? double.tryParse(json['average_late_minutes'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hadir': totalHadir,
      'total_terlambat': totalTerlambat,
      'total_izin': totalIzin,
      'total_sakit': totalSakit,
      'total_late_minutes': totalLateMinutes,
      'average_late_minutes': averageLateMinutes,
    };
  }

  /// Total attendance (hadir + terlambat)
  int get totalKehadiran => totalHadir + totalTerlambat;

  /// Total absence (izin + sakit)
  int get totalKetidakhadiran => totalIzin + totalSakit;

  /// Get formatted late minutes for display
  String get formattedLateMinutes {
    final minutes = int.tryParse(totalLateMinutes) ?? 0;
    if (minutes == 0) return '0 menit';

    final absMinutes = minutes.abs();
    final hours = absMinutes ~/ 60;
    final mins = absMinutes % 60;

    if (hours > 0) {
      return mins > 0 ? '$hours jam $mins menit' : '$hours jam';
    }
    return '$mins menit';
  }

  /// Get formatted average late minutes for display
  String get formattedAverageLateMinutes {
    if (averageLateMinutes == null) return '-';

    final minutes = averageLateMinutes!.abs().round();
    if (minutes == 0) return '0 menit';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return mins > 0 ? '$hours jam $mins menit' : '$hours jam';
    }
    return '$mins menit';
  }
}
