import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'dashboard_stat_card.dart';
import 'dashboard_attendance_item.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return RefreshIndicator(
      onRefresh: controller.loadDashboardData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(controller),
            const SizedBox(height: 24),
            _buildSearchBar(controller),
            const SizedBox(height: 16),
            _buildAttendanceList(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(AdminDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            icon: Icons.check_circle_outline,
            title: 'Total Hadir',
            value: controller.totalHadir,
            color: AppColors.success,
            bgColor: AppColors.success.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.access_time,
            title: 'Terlambat',
            value: controller.totalTerlambat,
            color: AppColors.warning,
            bgColor: AppColors.warning.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.event_note_outlined,
            title: 'Total Ijin',
            value: controller.totalIzin,
            color: AppColors.orange,
            bgColor: AppColors.orange.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.medical_services_outlined,
            title: 'Total Sakit',
            value: controller.totalSakit,
            color: AppColors.error,
            bgColor: AppColors.error.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AdminDashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => TextField(
          onChanged: controller.onSearch,
          controller: TextEditingController(text: controller.searchQuery.value)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: controller.searchQuery.value.length),
            ),
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama atau NPK...',
            hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.grey400),
                    onPressed: () => controller.onSearch(''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(AdminDashboardController controller) {
    return Obx(
      () {
        final displayList = controller.displayList;

        if (displayList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Absensi Hari Ini (${displayList.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 12),
          ...displayList.map(
            (attendance) => DashboardAttendanceItem(attendance: attendance),
          ),
        ],
      );
    },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Absensi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data absensi untuk hari ini belum tersedia.\nSilakan coba lagi nanti atau ubah filter pencarian.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
