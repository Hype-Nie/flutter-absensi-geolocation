import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../controllers/attendance_detail_controller.dart';

class AttendanceDetailView extends GetView<AttendanceDetailController> {
  const AttendanceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Detail Absensi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final att = controller.attendance.value;
      if (att == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Data tidak ditemukan',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeInfo(att),
            const SizedBox(height: 16),
            _buildAttendanceDetails(att),
            const SizedBox(height: 16),
            _buildLocationInfo(att),
            if (controller.canUpdateStatus.value) ...[
              const SizedBox(height: 24),
              _buildStatusUpdateSection(att),
            ],
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  Widget _buildEmployeeInfo(AttendanceHistoryModel att) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  att.user?.name ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NPK: ${att.user?.npk ?? "-"}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceDetails(AttendanceHistoryModel att) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Absensi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today, 'Tanggal', att.formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.login, 'Jam Masuk', att.clockIn),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.logout, 'Jam Keluar', att.clockOut ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Terlambat',
            att.lateDuration != null ? '${att.lateDuration} menit' : '-',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.verified_user,
            'Status',
            att.statusDisplay,
            valueColor: _getStatusColor(att.status),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(AttendanceHistoryModel att) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.my_location,
            'Clock In Lat',
            att.clockInLat ?? '-',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.my_location,
            'Clock In Lng',
            att.clockInLong ?? '-',
          ),
          if (att.clockOutLat != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.my_location,
              'Clock Out Lat',
              att.clockOutLat!,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.my_location,
              'Clock Out Lng',
              att.clockOutLong!,
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildStatusUpdateSection(AttendanceHistoryModel att) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubah Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedStatus.value.isEmpty
                  ? null
                  : controller.selectedStatus.value,
              items: controller.statusOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt['value'],
                  child: Text(opt['label']!),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Status Baru',
                prefixIcon: const Icon(Icons.swap_horiz),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.onStatusChanged,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isUpdating.value
                    ? null
                    : controller.updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isUpdating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 20),
                label: Text(
                  controller.isUpdating.value
                      ? 'Menyimpan...'
                      : 'Simpan Perubahan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.success;
      case 'terlambat':
        return AppColors.warning;
      case 'sakit':
        return AppColors.error;
      case 'izin':
        return AppColors.orange;
      case 'alpha':
        return AppColors.grey600;
      case 'menunggu_konfirmasi':
        return AppColors.info;
      default:
        return AppColors.grey600;
    }
  }

}
