import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/employee_model.dart';
import '../../../../data/services/employee_service.dart';

class EmployeeFormController extends GetxController {
  final EmployeeService _employeeService = Get.find<EmployeeService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final npkController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isEditMode = false.obs;
  final isLoading = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  EmployeeModel? employeeData;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      isEditMode.value = true;
      employeeData = EmployeeModel.fromJson(args);
      _populateForm();
    }
  }

  void _populateForm() {
    if (employeeData != null) {
      nameController.text = employeeData!.name;
      npkController.text = employeeData!.npk;
    }
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateNPK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NPK tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'NPK minimal 3 karakter';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (!isEditMode.value) {
      if (value == null || value.isEmpty) {
        return 'Password tidak boleh kosong';
      }
      if (value.length < 6) {
        return 'Password minimal 6 karakter';
      }
    }
    // In edit mode, password fields are not shown
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!isEditMode.value || passwordController.text.isNotEmpty) {
      if (value != passwordController.text) {
        return 'Konfirmasi password tidak cocok';
      }
    }
    // In edit mode, password fields are not shown
    return null;
  }

  Future<void> saveEmployee() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    late final dynamic result;

    if (isEditMode.value) {
      // Update existing employee
      result = await _employeeService.updateEmployee(
        id: employeeData!.id,
        npk: npkController.text.trim(),
        name: nameController.text.trim(),
        role: 'karyawan', // Default role as per requirement
      );
    } else {
      // Create new employee
      result = await _employeeService.createEmployee(
        npk: npkController.text.trim(),
        name: nameController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );
    }

    isLoading.value = false;

    if (result.isSuccess) {
      Get.back(result: true); // Return true to indicate success
      Get.snackbar(
        'Berhasil',
        isEditMode.value
            ? 'Karyawan berhasil diperbarui'
            : 'Karyawan baru berhasil ditambahkan',
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Gagal',
        result.error ?? 'Terjadi kesalahan',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    npkController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
