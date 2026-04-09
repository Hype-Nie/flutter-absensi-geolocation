import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../data/models/dashboard_attendance_model.dart';
import '../../../../../../routes/app_routes.dart';

class DashboardAttendanceItem extends StatelessWidget {
  final DashboardAttendanceModel attendance;

  const DashboardAttendanceItem({super.key, required this.attendance});

  Color _getStatusColor() {
    switch (attendance.status) {
      case 'Hadir':
        return AppColors.success;
      case 'Sakit':
        return AppColors.error;
      case 'Izin':
        return AppColors.orange;
      case 'Terlambat':
        return AppColors.warning;
      case 'Menunggu Konfirmasi':
        return AppColors.info;
      case 'Alpha':
        return AppColors.grey600;
      default:
        return AppColors.grey600;
    }
  }

  void _onTap() {
    if (attendance.id != null && attendance.id! > 0) {
      Get.toNamed(
        AppRoutes.adminAttendanceDetail,
        arguments: {'attendanceId': attendance.id},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          attendance.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${attendance.jamMasuk} - ${attendance.jamKeluar}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                attendance.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
