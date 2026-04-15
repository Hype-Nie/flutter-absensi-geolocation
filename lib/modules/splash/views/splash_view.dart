import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Perhutani Logo
            Container(
              width: 170,
              height: 170,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.textWhite,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo_baru.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            const Text(
              'Absensi GPS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Sistem Absensi Karyawan',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              color: AppColors.textWhite,
            ),
          ],
        ),
      ),
    );
  }
}
