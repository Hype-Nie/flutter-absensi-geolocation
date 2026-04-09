import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../controllers/employee_dashboard_controller.dart';
import '../widgets/employee_stat_card.dart';
import '../widgets/employee_attendance_item.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildStatCards(),
                      const SizedBox(height: 24),
                      _buildAttendanceSection(),
                      const SizedBox(height: 16),
                      _buildAttendanceList(),
                      const SizedBox(height: 16),
                      _buildHistoryButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final isClockOut =
            controller.todayAttendance.value != null &&
            controller.todayAttendance.value!.clockOut == null;
        final canSubmit = controller.canAttendNow.value;

        return FloatingActionButton.extended(
          onPressed: () {
            // Check if clock-out needs to wait until 9 AM
            if (isClockOut && !canSubmit) {
              Get.snackbar(
                'Informasi',
                'Absen keluar dibuka mulai jam 9 pagi',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                colorText: AppColors.warning,
                duration: const Duration(seconds: 3),
              );
              return;
            }

            // Go directly to GPS validation
            controller.goToAttendance('hadir');
          },
          backgroundColor: canSubmit ? AppColors.primary : AppColors.grey400,
          icon: Icon(
            isClockOut ? Icons.logout : Icons.fingerprint,
            color: AppColors.textWhite,
          ),
          label: Text(
            controller.attendanceButtonText.value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey300,
              border: Border.all(color: AppColors.grey400, width: 2),
            ),
            child: Icon(Icons.person, size: 35, color: AppColors.grey600),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Obx(
                () => Text(
                  controller.userName.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => EmployeeStatCard(
                count: controller.attendanceCount.value.toString(),
                label: 'Hadir',
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => EmployeeStatCard(
                count: controller.izinCount.value.toString(),
                label: 'Izin',
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => EmployeeStatCard(
                count: controller.sakitCount.value.toString(),
                label: 'Sakit',
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Absensi Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey300),
            ),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: const TextStyle(color: AppColors.grey400),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.recentAttendances.length,
        itemBuilder: (context, index) {
          final attendance = controller.recentAttendances[index];
          return EmployeeAttendanceItem(attendance: attendance);
        },
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.goToHistory,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey800,
            foregroundColor: AppColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Riwayat Lengkap',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
