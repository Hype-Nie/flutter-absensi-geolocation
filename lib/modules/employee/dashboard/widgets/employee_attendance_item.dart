import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/attendance_history_model.dart';

class EmployeeAttendanceItem extends StatelessWidget {
  final AttendanceHistoryModel attendance;

  const EmployeeAttendanceItem({super.key, required this.attendance});

  Color _getStatusColor() {
    switch (attendance.status.toLowerCase()) {
      case 'hadir':
        return AppColors.success;
      case 'terlambat':
        return AppColors.warning;
      case 'sakit':
        return AppColors.error;
      case 'izin':
        return AppColors.warning;
      case 'alpha':
        return AppColors.grey600;
      case 'menunggu_konfirmasi':
        return AppColors.info;
      default:
        return AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: AppColors.grey500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jam Masuk:  ${attendance.clockIn}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  'Jam Keluar:  ${attendance.clockOut ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              attendance.statusDisplay,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
