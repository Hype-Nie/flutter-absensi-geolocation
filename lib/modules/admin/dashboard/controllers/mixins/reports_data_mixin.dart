import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../../data/models/attendance_history_model.dart';
import '../../../../../../data/services/attendance_service.dart';

mixin ReportsDataMixin on GetxController {
  // Reports Page Data
  final RxBool isLoadingReports = false.obs;
  final RxList<AttendanceHistoryModel> reportAttendanceList = <AttendanceHistoryModel>[].obs;

  // Date Range Filter
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxString quickFilterType = 'today'.obs; // today, yesterday, last_7_days, this_month, custom

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = ''.obs;

  // Get AttendanceService from GetX
  AttendanceService get _attendanceService => Get.find<AttendanceService>();

  // Computed Stats for Reports (different from Dashboard stats)
  List<AttendanceHistoryModel> get filteredReportList {
    var list = reportAttendanceList.toList();

    // Apply date range filter
    // IMPORTANT: Compare using local date (not UTC) because:
    // 1. startDate.value and endDate.value are in local time
    // 2. Users expect date filtering based on their local timezone
    list = list.where((a) {
      // Convert to local time for consistent comparison
      final attendanceDate = a.tanggal.toLocal();

      // Extract date components (year, month, day) for comparison
      final attYear = attendanceDate.year;
      final attMonth = attendanceDate.month;
      final attDay = attendanceDate.day;

      final start = startDate.value;
      final end = endDate.value;

      final startYear = start.year;
      final startMonth = start.month;
      final startDay = start.day;

      final endYear = end.year;
      final endMonth = end.month;
      final endDay = end.day;

      // Check if attendance date is within [start, end] range (inclusive)
      if (attYear < startYear || attYear > endYear) return false;
      if (attYear == startYear && attMonth < startMonth) return false;
      if (attYear == endYear && attMonth > endMonth) return false;
      if (attYear == startYear && attMonth == startMonth && attDay < startDay) return false;
      if (attYear == endYear && attMonth == endMonth && attDay > endDay) return false;

      return true;
    }).toList();

    // Apply status filter
    if (statusFilter.value.isNotEmpty) {
      list = list.where((a) => _isStatus(a.status, statusFilter.value)).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((a) {
        final user = a.user;
        if (user == null) return false;
        final userName = user.name.toLowerCase();
        final userNpk = user.npk.toLowerCase();
        return userName.contains(query) || userNpk.contains(query);
      }).toList();
    }

    return list;
  }

  int get reportTotalHadir => filteredReportList.where((a) => _isStatus(a.status, 'hadir')).length;
  int get reportTotalIzin => filteredReportList.where((a) => _isStatus(a.status, 'izin') || _isStatus(a.status, 'ijin')).length;
  int get reportTotalSakit => filteredReportList.where((a) => _isStatus(a.status, 'sakit')).length;
  int get reportTotalTerlambat => filteredReportList.where((a) => _isStatus(a.status, 'terlambat')).length;

  Future<void> loadReports();

  // Date Range Display Text
  String get dateRangeText {
    if (quickFilterType.value == 'custom' && _isSameDay(startDate.value, endDate.value)) {
      return DateFormat('dd MMM yyyy', 'id_ID').format(startDate.value);
    } else if (quickFilterType.value == 'today') {
      return 'Hari Ini';
    } else if (quickFilterType.value == 'yesterday') {
      return 'Kemarin';
    } else if (quickFilterType.value == 'last_7_days') {
      return '7 Hari Terakhir';
    } else if (quickFilterType.value == 'this_month') {
      return DateFormat('MMMM yyyy', 'id_ID').format(startDate.value);
    } else {
      final startStr = DateFormat('dd MMM', 'id_ID').format(startDate.value);
      final endStr = DateFormat('dd MMM yyyy', 'id_ID').format(endDate.value);
      return '$startStr - $endStr';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Quick Filter Actions
  void setQuickFilter(String type) {
    quickFilterType.value = type;
    final now = DateTime.now();

    switch (type) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate.value = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate.value = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;
      case 'last_7_days':
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        startDate.value = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this_month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'custom':
        // Don't change dates, user will pick manually
        break;
    }

    loadReports();
  }

  Future<void> selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();

    // Use two separate date pickers for better compatibility
    // Clamp initialDate to not exceed lastDate (now)
    final initialStart = startDate.value.isAfter(now) ? now : startDate.value;

    final DateTime? startPicked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDate: initialStart,
      helpText: 'Pilih Tanggal Mulai',
    );

    if (startPicked == null || !context.mounted) return;

    // For end date, ensure initialDate is within [startPicked, now] range
    var initialEnd = endDate.value;
    if (initialEnd.isAfter(now)) {
      initialEnd = now;
    }
    if (initialEnd.isBefore(startPicked)) {
      initialEnd = startPicked;
    }

    final DateTime? endPicked = await showDatePicker(
      context: context,
      firstDate: startPicked,
      lastDate: now,
      initialDate: initialEnd,
      helpText: 'Pilih Tanggal Akhir',
    );

    if (endPicked != null) {
      quickFilterType.value = 'custom';
      startDate.value = DateTime(startPicked.year, startPicked.month, startPicked.day);
      endDate.value = DateTime(endPicked.year, endPicked.month, endPicked.day, 23, 59, 59);
      loadReports();
    }
  }

  void onSearchReport(String query) {
    searchQuery.value = query;
  }

  void onStatusFilterChanged(String? status) {
    statusFilter.value = status ?? '';
  }

  /// Helper untuk cek status dengan case-insensitive
  bool _isStatus(String actualStatus, String expectedStatus) {
    return actualStatus.toLowerCase() == expectedStatus.toLowerCase();
  }

  void exportReport() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: AppColors.success),
            SizedBox(width: 8),
            Text('Export Laporan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih format export:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('CSV (.csv)'),
              onTap: () {
                Get.back();
                performExport('csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('PDF (.pdf)'),
              onTap: () {
                Get.back();
                performExport('pdf');
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ],
      ),
    );
  }

  Future<void> performExport(String format) async {
    isLoadingReports.value = true;

    try {
      // Export dengan date range yang sedang aktif
      final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);

      final result = format == 'csv'
          ? await _attendanceService.exportCsv(
              startDate: startStr,
              endDate: endStr,
            )
          : await _attendanceService.exportPdf(
              startDate: startStr,
              endDate: endStr,
            );

      if (result.isSuccess && result.data != null) {
        await _saveAndOpenFile(
          result.data!,
          format,
          startDate.value.month,
          startDate.value.year,
        );
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Export Gagal'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gagal mengekspor laporan.'),
                const SizedBox(height: 8),
                Text(
                  result.error ?? 'Unknown error',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kemungkinan penyebab:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text('• Server API tidak merespons', style: TextStyle(fontSize: 12)),
                const Text('• Endpoint export belum tersedia', style: TextStyle(fontSize: 12)),
                const Text('• Data untuk periode ini kosong', style: TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoadingReports.value = false;
    }
  }

  Future<void> _saveAndOpenFile(
    List<int> bytes,
    String format,
    int month,
    int year,
  ) async {
    try {
      final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(year, month));
      final fileExtension = _getFileExtension(format);
      final fileName = 'laporan_absensi_${monthName}_$year.$fileExtension';

      // Get temporary directory for creating the file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Share the file using share_plus
      final xFile = XFile(
        tempFile.path,
        name: fileName,
        mimeType: _getMimeType(format),
      );

      await Share.shareXFiles(
        [xFile],
        subject: 'Laporan Absensi $monthName $year',
        text: 'Berikut terlampir laporan absensi untuk periode $monthName $year',
      );

      // Show success message
      Get.snackbar(
        'Berhasil',
        'File siap dibagikan. Pilih "Download" atau simpan ke Drive.',
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyiapkan file: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _getFileExtension(String format) {
    switch (format.toLowerCase()) {
      case 'csv':
        return 'csv';
      case 'excel':
      case 'xlsx':
        return 'xlsx';
      case 'xls':
        return 'xls';
      case 'pdf':
        return 'pdf';
      default:
        return format;
    }
  }

  String _getMimeType(String format) {
    switch (format.toLowerCase()) {
      case 'csv':
        return 'text/csv';
      case 'excel':
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
