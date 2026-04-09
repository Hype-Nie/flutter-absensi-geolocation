import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/employee/dashboard/bindings/employee_dashboard_binding.dart';
import '../modules/employee/dashboard/views/employee_dashboard_view.dart';
import '../modules/employee/gps_validation/bindings/gps_validation_binding.dart';
import '../modules/employee/gps_validation/views/gps_validation_view.dart';
import '../modules/employee/photo_validation/bindings/photo_validation_binding.dart';
import '../modules/employee/photo_validation/views/photo_validation_view.dart';
import '../modules/employee/attendance_success/bindings/attendance_success_binding.dart';
import '../modules/employee/attendance_success/views/attendance_success_view.dart';
import '../modules/employee/history/bindings/history_binding.dart';
import '../modules/employee/history/views/history_view.dart';
import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/employees/bindings/employees_binding.dart';
import '../modules/admin/employees/views/employees_view.dart';
import '../modules/admin/employee_detail/bindings/employee_detail_binding.dart';
import '../modules/admin/employee_detail/views/employee_detail_view.dart';
import '../modules/admin/employee_form/bindings/employee_form_binding.dart';
import '../modules/admin/employee_form/views/employee_form_view.dart';
import '../modules/admin/reports/bindings/reports_binding.dart';
import '../modules/admin/reports/views/reports_view.dart';
import '../modules/admin/attendance_detail/bindings/attendance_detail_binding.dart';
import '../modules/admin/attendance_detail/views/attendance_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // Employee Routes
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: () => const EmployeeDashboardView(),
      binding: EmployeeDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeGpsValidation,
      page: () => const GpsValidationView(),
      binding: GpsValidationBinding(),
    ),
    GetPage(
      name: AppRoutes.employeePhotoValidation,
      page: () => const PhotoValidationView(),
      binding: PhotoValidationBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeAttendanceSuccess,
      page: () => const AttendanceSuccessView(),
      binding: AttendanceSuccessBinding(),
    ),
    GetPage(
      name: AppRoutes.employeeHistory,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),

    // Admin Routes
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEmployees,
      page: () => const EmployeesView(),
      binding: EmployeesBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEmployeeDetail,
      page: () => const EmployeeDetailView(),
      binding: EmployeeDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEmployeeAdd,
      page: () => const EmployeeFormView(),
      binding: EmployeeFormBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEmployeeEdit,
      page: () => const EmployeeFormView(),
      binding: EmployeeFormBinding(),
    ),
    GetPage(
      name: AppRoutes.adminReports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.adminAttendanceDetail,
      page: () => const AttendanceDetailView(),
      binding: AttendanceDetailBinding(),
    ),
  ];
}
