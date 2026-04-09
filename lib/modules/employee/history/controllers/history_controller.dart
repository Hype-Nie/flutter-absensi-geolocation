import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';

class HistoryController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final attendanceCount = 0.obs;
  final izinCount = 0.obs;
  final sakitCount = 0.obs;
  final terlambatCount = 0.obs;

  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;

  final allAttendances = <AttendanceHistoryModel>[].obs;
  final filteredAttendances = <AttendanceHistoryModel>[].obs;

  final isLoadingStats = false.obs;
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  final currentPage = 1.obs;
  final perPage = 10; // API returns 10 items per page

  final filters = ['Semua', 'Hadir', 'Terlambat', 'Izin', 'Sakit'];

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    _loadInitialData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      // Load more when scrolled to 80% of the list
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        loadMore();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    currentPage.value = 1;
    hasMoreData.value = true;
    allAttendances.clear();

    await Future.wait([
      _loadStats(userId.toString()),
      _loadAttendanceHistory(userId.toString(), 1),
    ]);
  }

  Future<void> _loadStats(String userId) async {
    isLoadingStats.value = true;

    final result = await _attendanceService.getUserStats(userId);

    isLoadingStats.value = false;

    if (result.isSuccess && result.data != null) {
      final stats = result.data!.stats;
      attendanceCount.value = stats.totalHadir;
      terlambatCount.value = stats.totalTerlambat;
      izinCount.value = stats.totalIzin;
      sakitCount.value = stats.totalSakit;
    } else if (result.error != null) {
      Get.snackbar(
        'Perhatian',
        result.error!,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _loadAttendanceHistory(String userId, int page) async {
    if (page == 1) {
      isLoadingHistory.value = true;
    } else {
      isLoadingMore.value = true;
    }

    final result = await _attendanceService.getAttendanceById(
      userId,
      page: page,
    );

    if (page == 1) {
      isLoadingHistory.value = false;
    } else {
      isLoadingMore.value = false;
    }

    if (result.isSuccess && result.data != null) {
      if (result.data!.isEmpty || result.data!.length < perPage) {
        hasMoreData.value = false;
      }

      allAttendances.addAll(result.data!);
      _applyFilter();
    } else if (result.error != null) {
      Get.snackbar(
        'Perhatian',
        result.error!,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    currentPage.value++;
    await _loadAttendanceHistory(userId.toString(), currentPage.value);
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    var result = allAttendances.toList();

    // Apply status filter
    if (selectedFilter.value != 'Semua') {
      result = result
          .where((a) => a.statusDisplay == selectedFilter.value)
          .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((a) {
        final query = searchQuery.value.toLowerCase();
        return a.formattedDate.toLowerCase().contains(query) ||
            a.statusDisplay.toLowerCase().contains(query);
      }).toList();
    }

    filteredAttendances.value = result;
  }
}
