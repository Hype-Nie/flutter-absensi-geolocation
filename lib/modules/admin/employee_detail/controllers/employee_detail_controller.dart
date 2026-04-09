import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/employee_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';

class EmployeeDetailController extends GetxController {
  final EmployeeService _employeeService = Get.find<EmployeeService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final employee = Rxn<Map<String, dynamic>>();
  final selectedFilter = 'Semua'.obs;
  final filters = [
    'Semua',
    'Hadir',
    'Terlambat',
    'Izin',
    'Sakit',
    'Alpha',
    'Menunggu Konfirmasi',
  ];
  final attendanceHistory = <AttendanceHistoryModel>[].obs;
  final isLoadingAttendance = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      employee.value = args;
      _loadAttendanceHistory();
    }
  }

  Future<void> _loadAttendanceHistory() async {
    final userId = employee.value?['id']?.toString();
    if (userId == null) return;

    isLoadingAttendance.value = true;

    final result = await _attendanceService.getAttendanceById(userId);

    isLoadingAttendance.value = false;

    if (result.isSuccess && result.data != null) {
      attendanceHistory.value = result.data!;
    } else {
      // Show error or empty state
      attendanceHistory.value = [];
      if (result.error != null) {
        Get.snackbar(
          'Perhatian',
          result.error!,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  List<AttendanceHistoryModel> get filteredHistory {
    if (selectedFilter.value == 'Semua') {
      return attendanceHistory;
    }
    return attendanceHistory
        .where((att) => att.statusDisplay == selectedFilter.value)
        .toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> goToEditEmployee() async {
    final result = await Get.toNamed(
      AppRoutes.adminEmployeeEdit,
      arguments: employee.value,
    );

    // Refresh employee data if edit was successful
    if (result == true) {
      await _refreshEmployeeData();
    }
  }

  Future<void> _refreshEmployeeData() async {
    final employeeId = employee.value?['id']?.toString();
    if (employeeId == null) return;

    // Find updated employee in service cache
    final updatedEmployee = _employeeService.employees.firstWhereOrNull(
      (emp) => emp.id == employeeId,
    );

    if (updatedEmployee != null) {
      employee.value = updatedEmployee.toJson();
    }
  }

  Future<void> refreshData() async {
    await Future.wait([_refreshEmployeeData(), _loadAttendanceHistory()]);
  }

  void deleteEmployee() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () => _performDelete(),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete() async {
    Get.back(); // Close dialog first

    final employeeId = employee.value?['id']?.toString();
    if (employeeId == null) {
      Get.snackbar(
        'Gagal',
        'ID karyawan tidak ditemukan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final result = await _employeeService.deleteEmployee(employeeId);

    if (result.isSuccess) {
      Get.back(); // Go back to list
      Get.snackbar(
        'Berhasil',
        'Karyawan berhasil dihapus',
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Gagal',
        result.error ?? 'Gagal menghapus karyawan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void goBack() {
    Get.back();
  }

  /// Get display position with fallbacks
  /// Uses position if available, otherwise uses role with department, then NPK-based info
  String getDisplayPosition() {
    final emp = employee.value;
    if (emp == null) return '-';

    final position = emp['position']?.toString();
    final role = emp['role']?.toString();
    final department = emp['department']?.toString();
    final npk = emp['npk']?.toString() ?? '';

    // Priority 1: Position if available and meaningful
    if (position != null &&
        position.isNotEmpty &&
        position != 'Staff' &&
        position != '-') {
      return position;
    }

    // Priority 2: Role with department
    if (role != null && role.isNotEmpty) {
      final roleDisplay = role == 'karyawan'
          ? 'Karyawan'
          : role == 'admin'
          ? 'Admin'
          : role;
      if (department != null && department.isNotEmpty && department != '-') {
        return '$roleDisplay - $department';
      }
      return roleDisplay;
    }

    // Priority 3: Department only
    if (department != null && department.isNotEmpty && department != '-') {
      return department;
    }

    // Priority 4: Show NPK-based info as last resort
    if (npk.isNotEmpty) {
      return 'Staff (NPK: $npk)';
    }

    return 'Staff';
  }

  /// Get display department with fallback
  String getDisplayDepartment() {
    final emp = employee.value;
    if (emp == null) return '-';

    final department = emp['department']?.toString();
    if (department != null && department.isNotEmpty && department != '-') {
      return department;
    }
    return '-';
  }
}
