import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'dashboard_employee_item.dart';

class AdminEmployeesPage extends StatelessWidget {
  const AdminEmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchBar(controller),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) =>
                _handleScroll(controller, scrollInfo),
            child: RefreshIndicator(
              onRefresh: controller.refreshEmployees,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEmployeeList(controller),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handle scroll events for lazy loading pagination
  bool _handleScroll(
    AdminDashboardController controller,
    ScrollNotification scrollInfo,
  ) {
    // Only load more when scrolling near bottom
    if (scrollInfo is ScrollEndNotification &&
        scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent * 0.8) {
      // Load more if not already loading and not reached max
      if (!controller.isLoadingMoreEmployees.value &&
          !controller.hasReachedMaxEmployees.value) {
        controller.loadMoreEmployees();
      }
    }
    return false;
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
      child: TextField(
        onChanged: controller.onEmployeeSearch,
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama atau NPK...',
          hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(AdminDashboardController controller) {
    return Obx(() {
      // Show loading indicator on initial load
      if (controller.isLoadingEmployees.value &&
          controller.employees.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final employees = controller.filteredEmployees;

      // Show empty state
      if (employees.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada karyawan ditemukan',
                  style: const TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
          ),
        );
      }

      // Build employee list with loading more indicator at bottom
      return Column(
        children: [
          ...employees
              .map((emp) => DashboardEmployeeItem(employee: emp))
              .toList(),
          // Show loading more indicator at bottom
          if (controller.isLoadingMoreEmployees.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          // Show end of list indicator when reached max
          if (controller.hasReachedMaxEmployees.value &&
              controller.employees.length >= 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Tidak ada data lagi',
                  style: TextStyle(color: AppColors.grey400, fontSize: 12),
                ),
              ),
            ),
          // Add extra padding at bottom for FAB + bottom nav space
          const SizedBox(height: 130),
        ],
      );
    });
  }
}
