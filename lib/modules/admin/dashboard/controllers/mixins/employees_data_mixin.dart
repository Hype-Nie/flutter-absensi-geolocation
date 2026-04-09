import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../../data/models/employee_model.dart';
import '../../../../../../data/services/employee_service.dart';

/// Mixin for employee data management
/// Uses EmployeeService for business logic and API calls
mixin EmployeesDataMixin on GetxController {
  // Get service from DI container
  EmployeeService get _employeeService => Get.find<EmployeeService>();

  final RxString employeeSearchQuery = ''.obs;

  // Forward getters to service for reactive UI
  RxList<EmployeeModel> get employees => _employeeService.employees;
  RxBool get isLoadingEmployees => _employeeService.isLoading;
  RxBool get isLoadingMoreEmployees => _employeeService.isLoadingMore;
  RxBool get hasReachedMaxEmployees => _employeeService.hasReachedMax;

  /// Load employees from API via service (initial load)
  Future<void> loadEmployees() async {
    final result = await _employeeService.fetchAllEmployees();

    if (!result.isSuccess) {
      Get.snackbar(
        'Error',
        result.error ?? 'Gagal memuat data karyawan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Load more employees (pagination)
  Future<void> loadMoreEmployees() async {
    final result = await _employeeService.loadMoreEmployees();

    if (!result.isSuccess && result.error != 'No more data') {
      Get.snackbar(
        'Error',
        result.error ?? 'Gagal memuat data karyawan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Refresh employee data
  Future<void> refreshEmployees() async {
    final result = await _employeeService.refreshEmployees();

    if (!result.isSuccess) {
      Get.snackbar(
        'Error',
        result.error ?? 'Gagal memuat ulang data karyawan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Search employees locally (already loaded data)
  void onEmployeeSearch(String query) {
    employeeSearchQuery.value = query;
  }

  /// Get filtered employees based on search query
  List<EmployeeModel> get filteredEmployees {
    return _employeeService.searchEmployees(employeeSearchQuery.value);
  }

  /// Navigate to employee detail page
  void goToEmployeeDetail(EmployeeModel employee) {
    Get.toNamed(AppRoutes.adminEmployeeDetail, arguments: employee.toJson());
  }

  /// Navigate to add employee page
  void goToAddEmployee() {
    Get.toNamed(AppRoutes.adminEmployeeAdd);
  }

  /// Show delete confirmation dialog
  void deleteEmployee(String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
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

  /// Perform delete operation via service
  Future<void> _performDelete(String id) async {
    Get.back(); // Close dialog

    final result = await _employeeService.deleteEmployee(id);

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
}
