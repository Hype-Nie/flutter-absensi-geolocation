import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final npkController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    npkController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    // Validate inputs
    if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      // Call AuthService login
      final user = await _authService.login(
        npkController.text.trim(),
        passwordController.text,
      );

      // Show success message
      Get.snackbar(
        'Success',
        AppStrings.successLogin,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        duration: const Duration(seconds: 2),
      );

      // Navigate based on role from API response
      if (user.isAdmin) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else if (user.isKaryawan) {
        Get.offAllNamed(AppRoutes.employeeDashboard);
      } else {
        // Unknown role, default to employee dashboard
        Get.offAllNamed(AppRoutes.employeeDashboard);
      }
    } catch (e) {
      // Show error message
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : AppStrings.errorGeneral;
      Get.snackbar(
        'Login Gagal',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (npkController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'NPK wajib diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password ${AppStrings.errorFieldRequired.toLowerCase()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return false;
    }

    if (!Helpers.isValidPassword(passwordController.text)) {
      Get.snackbar(
        'Error',
        AppStrings.errorPasswordTooShort,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return false;
    }

    return true;
  }
}
