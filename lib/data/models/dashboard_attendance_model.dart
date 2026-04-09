/// Attendance item model for dashboard display
class DashboardAttendanceModel {
  final int? id;
  final String name;
  final String npk;
  final String date;
  final String jamMasuk;
  final String jamKeluar;
  final String status;
  final String? clockInImageUrl;
  final String? clockOutImageUrl;

  DashboardAttendanceModel({
    this.id,
    required this.name,
    this.npk = '',
    required this.date,
    required this.jamMasuk,
    this.jamKeluar = '-',
    required this.status,
    this.clockInImageUrl,
    this.clockOutImageUrl,
  });

  factory DashboardAttendanceModel.fromJson(Map<String, dynamic> json) {
    return DashboardAttendanceModel(
      id: json['id'] is int
          ? json['id']
          : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      name: json['name'] ?? '',
      npk: json['npk'] ?? '',
      date: json['date'] ?? '',
      jamMasuk: json['jamMasuk'] ?? '-',
      jamKeluar: json['jamKeluar'] ?? '-',
      status: json['status'] ?? 'Hadir',
      clockInImageUrl: json['clockInImageUrl'],
      clockOutImageUrl: json['clockOutImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'npk': npk,
      'date': date,
      'jamMasuk': jamMasuk,
      'jamKeluar': jamKeluar,
      'status': status,
      'clockInImageUrl': clockInImageUrl,
      'clockOutImageUrl': clockOutImageUrl,
    };
  }

  /// For mock data creation
  static DashboardAttendanceModel createMock({
    required String name,
    required String date,
    required String jamMasuk,
    String jamKeluar = '-',
    String status = 'Hadir',
  }) {
    return DashboardAttendanceModel(
      name: name,
      date: date,
      jamMasuk: jamMasuk,
      jamKeluar: jamKeluar,
      status: status,
    );
  }
}
