import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/employee_dashboard_controller.dart';

class AttendanceOptionsSheet extends StatelessWidget {
  const AttendanceOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeDashboardController>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jenis Absensi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildAttendanceOption(
            icon: Icons.check_circle_outline,
            label: 'Hadir',
            color: AppColors.success,
            onTap: () {
              Get.back();
              controller.goToAttendance('hadir');
            },
          ),
          const SizedBox(height: 12),
          _buildAttendanceOption(
            icon: Icons.access_time,
            label: 'Izin',
            color: AppColors.warning,
            onTap: () {
              Get.back();
              controller.goToAttendance('izin');
            },
          ),
          const SizedBox(height: 12),
          _buildAttendanceOption(
            icon: Icons.local_hospital_outlined,
            label: 'Sakit',
            color: AppColors.error,
            onTap: () {
              Get.back();
              controller.goToAttendance('sakit');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAttendanceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the attendance options bottom sheet
void showAttendanceOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AttendanceOptionsSheet(),
  );
}
