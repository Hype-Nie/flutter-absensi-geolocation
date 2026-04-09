class UserModel {
  final String id;
  final String npk;
  final String nama;
  final String role; // 'karyawan' or 'admin'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.npk,
    required this.nama,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      npk: json['npk'] ?? '',
      nama: json['nama'] ?? '',
      role: json['role'] ?? 'karyawan',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'npk': npk,
      'nama': nama,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isKaryawan => role == 'karyawan';

  /// Display name for UI
  String get displayName => nama;

  /// Employee ID (same as npk)
  String get employeeId => npk;
}
