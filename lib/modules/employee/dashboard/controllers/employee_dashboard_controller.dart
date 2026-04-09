import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';

class EmployeeDashboardController extends GetxController
    with WidgetsBindingObserver {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final greeting = ''.obs;
  final userName = ''.obs;
  final attendanceCount = 0.obs;
  final izinCount = 0.obs;
  final sakitCount = 0.obs;
  final searchQuery = ''.obs;

  final recentAttendances = <AttendanceHistoryModel>[].obs;
  final isLoadingStats = false.obs;
  final isLoadingHistory = false.obs;

  // Track today's attendance for clock-in/out button
  final todayAttendance = Rxn<AttendanceHistoryModel>();
  final canAttendNow = true.obs;
  final attendanceButtonText = 'Masuk'.obs;

  // Server time from API (fallback to device time if not available)
  final serverTime = Rxn<DateTime>();

  Timer? _refreshTimer;
  bool _hasLoadedOnce = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _updateGreeting();
    // Add small delay to ensure API has processed recent attendance
    Future.delayed(const Duration(milliseconds: 500), _loadAttendanceData);
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasLoadedOnce) {
      // Refresh data when app is resumed (e.g., returning from background)
      _loadAttendanceData();
    }
  }

  void _startPeriodicRefresh() {
    // Refresh attendance data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final currentUser = _authService.currentUser.value;
      if (currentUser != null) {
        _loadRecentHistory(currentUser.id.toString());
      }
    });
  }

  void _loadUserData() {
    // Observe user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        userName.value = user.nama;
        _loadAttendanceData();
      }
    });

    // Initial load
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.nama;
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
  }

  Future<void> _loadAttendanceData() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    // Load stats and recent history in parallel
    await Future.wait([
      _loadStats(userId.toString()),
      _loadRecentHistory(userId.toString()),
    ]);
  }

  Future<void> _loadStats(String userId) async {
    isLoadingStats.value = true;

    final result = await _attendanceService.getUserStats(userId);

    isLoadingStats.value = false;

    if (result.isSuccess && result.data != null) {
      final stats = result.data!.stats;
      attendanceCount.value = stats.totalHadir;
      izinCount.value = stats.totalIzin;
      sakitCount.value = stats.totalSakit;
    }
  }

  Future<void> _loadRecentHistory(String userId) async {
    isLoadingHistory.value = true;

    // Fetch first page to get recent records
    final result = await _attendanceService.getAttendanceById(userId, page: 1);

    isLoadingHistory.value = false;

    if (result.isSuccess && result.data != null) {
      // Take only the 5 most recent records
      // API should return data ordered by date DESC
      recentAttendances.assignAll(result.data!.take(5));
      _hasLoadedOnce = true;

      // Check if first record is today's attendance
      if (result.data!.isNotEmpty) {
        final latestAttendance = result.data!.first;

        // Convert UTC date to local date for comparison
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // attendance.tanggal is UTC, convert to local date
        final localAttendanceDate = latestAttendance.tanggal.toLocal();
        final attendanceDate = DateTime(
          localAttendanceDate.year,
          localAttendanceDate.month,
          localAttendanceDate.day,
        );

        if (attendanceDate == today) {
          todayAttendance.value = latestAttendance;
          _updateAttendanceButtonState();
        } else {
          todayAttendance.value = null;
          attendanceButtonText.value = 'Masuk';
          canAttendNow.value = true;
        }
      } else {
        // No attendance records found
        todayAttendance.value = null;
        attendanceButtonText.value = 'Masuk';
        canAttendNow.value = true;
      }
    }
  }

  void _updateAttendanceButtonState() {
    final attendance = todayAttendance.value;
    if (attendance == null) {
      attendanceButtonText.value = 'Masuk';
      canAttendNow.value = true;
      return;
    }

    // If already clocked out, show as completed (API will handle validation)
    if (attendance.clockOut != null) {
      attendanceButtonText.value = 'Sudah Absen';
      canAttendNow.value = true; // Let API handle duplicate prevention
      return;
    }

    // If clocked in but not clocked out yet
    attendanceButtonText.value = 'Keluar';

    // Check if current time is 9 AM or later (using server time if available, otherwise device time)
    final now = serverTime.value ?? DateTime.now();
    final nineAM = DateTime(now.year, now.month, now.day, 9, 0, 0);

    canAttendNow.value = now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM);
  }

  Future<void> refreshData() async {
    await _loadAttendanceData();
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void goToHistory() {
    Get.toNamed(AppRoutes.employeeHistory);
  }

  void goToAttendance(String type) {
    // Determine attendance type based on state
    if (todayAttendance.value != null && todayAttendance.value!.clockOut == null) {
      // Clock out scenario
      type = 'hadir'; // Default to 'hadir' for clock out
    }
    // Navigate to GPS validation (API will handle duplicate attendance prevention)
    Get.toNamed(
      AppRoutes.employeeGpsValidation,
      arguments: {
        'type': type,
        'isClockOut': todayAttendance.value != null &&
            todayAttendance.value!.clockOut == null,
      },
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
