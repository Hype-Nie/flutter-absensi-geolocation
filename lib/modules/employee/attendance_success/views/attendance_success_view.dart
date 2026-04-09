import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../controllers/attendance_success_controller.dart';

class AttendanceSuccessView extends GetView<AttendanceSuccessController> {
  const AttendanceSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.success,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Obx(() => Text(
                      controller.isCheckIn.value
                          ? 'Absensi Masuk Berhasil'
                          : 'Absensi Keluar Berhasil',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(height: 40),

                    // Details
                    _buildDetailRow('Tanggal', controller.currentDate),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      controller.isCheckIn.value ? 'Jam Masuk' : 'Jam Keluar',
                      controller.currentTime,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Status', controller.status),
                    const SizedBox(height: 40),

                    // Back to Dashboard Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.goToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kembali ke Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Obx(() => Text(
            value.value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          )),
        ],
      ),
    );
  }
}
