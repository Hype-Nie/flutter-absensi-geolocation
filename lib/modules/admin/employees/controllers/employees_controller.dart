import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/employee_model.dart';
import '../../../../data/services/employee_service.dart';
import '../../../../routes/app_routes.dart';

/// Controller for dedicated employees list page
/// Uses EmployeeService for business logic
class EmployeesController extends GetxController {
  final EmployeeService _employeeService = Get.find<EmployeeService>();

  final searchQuery = ''.obs;

  // Forward to service state
  RxBool get isLoading => _employeeService.isLoading;
  RxList<EmployeeModel> get employees => _employeeService.employees;

  @override
  void onInit() {
    super.onInit();
    _loadEmployees();
  }

  Future<void> _loadEmployees({bool refresh = false}) async {
    if (refresh) {
      final result = await _employeeService.refreshEmployees();
      if (!result.isSuccess) {
        _showErrorSnackbar('Gagal memuat data karyawan', result.error);
      }
    } else {
      final result = await _employeeService.fetchAllEmployees();
      if (!result.isSuccess) {
        _showErrorSnackbar('Gagal memuat data karyawan', result.error);
      }
    }
  }

  List<EmployeeModel> get filteredEmployees {
    return _employeeService.searchEmployees(searchQuery.value);
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void goToEmployeeDetail(EmployeeModel employee) {
    Get.toNamed(AppRoutes.adminEmployeeDetail, arguments: employee.toJson());
  }

  void goToAddEmployee() {
    Get.toNamed(AppRoutes.adminEmployeeAdd);
  }

  void deleteEmployee(String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () => _performDelete(id),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(String id) async {
    final result = await _employeeService.deleteEmployee(id);

    Get.back(); // Close dialog

    if (result.isSuccess) {
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

  Future<void> refreshData() async {
    await _loadEmployees(refresh: true);
  }

  void _showErrorSnackbar(String title, String? detail) {
    Get.snackbar(
      title,
      detail ?? 'Terjadi kesalahan',
      backgroundColor: AppColors.error,
      colorText: AppColors.textWhite,
      snackPosition: SnackPosition.TOP,
    );
  }

  void goBack() {
    Get.back();
  }
}
