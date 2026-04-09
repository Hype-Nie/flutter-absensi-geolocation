import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            SizedBox(
              width: 150,
              height: 150,
              child: SvgPicture.asset(
                'assets/images/Perhutani_logo.svg',
                placeholderBuilder: (context) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: AppColors.primary,
                  ),
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
