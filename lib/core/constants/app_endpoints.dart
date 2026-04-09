import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEndpoints {
  // Base URL from .env file
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://api-laravel.hftech.web.id/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh';
  static const String forgotPassword = '/forgot-password';

  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';

  // Attendance Endpoints
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceDetail = '/attendance/detail';

  // Employee Endpoints (Admin)
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/detail';
  static const String createEmployee = '/employees/create';
  static const String updateEmployee = '/employees/update';
  static const String deleteEmployee = '/employees/delete';

  // Report Endpoints (Admin)
  static const String reportDaily = '/reports/daily';
  static const String reportMonthly = '/reports/monthly';
  static const String reportExport = '/reports/export';
}
