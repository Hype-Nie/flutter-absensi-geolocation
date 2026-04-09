import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../widgets/admin_dashboard_header.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/admin_dashboard_page.dart';
import '../widgets/admin_employees_page.dart';
import '../widgets/admin_reports_page.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SafeArea(
        child: Column(
          children: [
            const AdminDashboardHeader(),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.currentPageIndex.value,
                  children: const [
                    AdminDashboardPage(),
                    AdminEmployeesPage(),
                    AdminReportsPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(),
      floatingActionButton: Obx(
        () => controller.currentPageIndex.value == 1
            ? FloatingActionButton.extended(
                onPressed: controller.goToAddEmployee,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: AppColors.textWhite),
                label: const Text(
                  'Tambah Karyawan',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
