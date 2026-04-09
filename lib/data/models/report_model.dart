/// Report item model for admin dashboard reports
class ReportModel {
  final String name;
  final String npk;
  final int hadir;
  final int izin;
  final int sakit;
  final int total;

  ReportModel({
    required this.name,
    required this.npk,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.total,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      name: json['name'] ?? '',
      npk: json['npk'] ?? '',
      hadir: json['hadir'] as int? ?? 0,
      izin: json['izin'] as int? ?? 0,
      sakit: json['sakit'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'npk': npk,
      'hadir': hadir,
      'izin': izin,
      'sakit': sakit,
      'total': total,
    };
  }

  /// For mock data creation
  static ReportModel createMock({
    required String name,
    required String npk,
    required int hadir,
    required int izin,
    required int sakit,
    required int total,
  }) {
    return ReportModel(
      name: name,
      npk: npk,
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      total: total,
    );
  }

  /// Calculate total from hadir, izin, and sakit
  static ReportModel createWithCalculatedTotal({
    required String name,
    required String npk,
    required int hadir,
    required int izin,
    required int sakit,
  }) {
    return ReportModel(
      name: name,
      npk: npk,
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      total: hadir + izin + sakit,
    );
  }
}
