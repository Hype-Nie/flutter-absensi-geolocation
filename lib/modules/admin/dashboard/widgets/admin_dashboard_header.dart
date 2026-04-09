import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  String title;
                  switch (controller.currentPageIndex.value) {
                    case 1:
                      title = 'Daftar Karyawan';
                      break;
                    case 2:
                      title = 'Laporan Absensi';
                      break;
                    default:
                      title = '${controller.greeting.value}, Admin!';
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      if (controller.currentPageIndex.value == 0) ...[
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.currentDate.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textWhite.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
              GestureDetector(
                onTap: controller.logout,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
