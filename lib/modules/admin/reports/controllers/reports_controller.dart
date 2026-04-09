import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/attendance_service.dart';

class ReportsController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final isLoading = false.obs;
  final selectedMonth = DateTime.now().obs;
  final reports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadReports();
  }

  void _loadReports() {
    // Mock data - replace with API
    reports.value = [
      {
        'name': 'Karyawan1',
        'npk': 'NPK001',
        'hadir': 20,
        'izin': 1,
        'sakit': 0,
        'total': 21,
      },
      {
        'name': 'Karyawan2',
        'npk': 'NPK002',
        'hadir': 18,
        'izin': 2,
        'sakit': 1,
        'total': 21,
      },
      {
        'name': 'Karyawan3',
        'npk': 'NPK003',
        'hadir': 19,
        'izin': 0,
        'sakit': 2,
        'total': 21,
      },
      {
        'name': 'Karyawan4',
        'npk': 'NPK004',
        'hadir': 21,
        'izin': 0,
        'sakit': 0,
        'total': 21,
      },
    ];
  }

  /// Public method for pull-to-refresh
  Future<void> refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _loadReports();
  }

  String get monthYearText {
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  void selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      selectedMonth.value = picked;
      _loadReports();
    }
  }

  void exportReport() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: AppColors.primary),
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
              leading: const Icon(Icons.table_chart, color: AppColors.primary),
              title: const Text('CSV (.csv)'),
              onTap: () {
                Get.back();
                _performExport('csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF (.pdf)'),
              onTap: () {
                Get.back();
                _performExport('pdf');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _performExport(String format) async {
    isLoading.value = true;

    try {
      final month = selectedMonth.value.month;
      final year = selectedMonth.value.year;

      final result = format == 'csv'
          ? await _attendanceService.exportCsv(
              month: month,
              year: year,
            )
          : await _attendanceService.exportPdf(
              month: month,
              year: year,
            );

      if (result.isSuccess && result.data != null) {
        await _saveAndOpenFile(
          result.data!,
          format,
          month,
          year,
        );
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              Icon(Icons.error_outline, color: Colors.red),
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
      isLoading.value = false;
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
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyiapkan file: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

  void goBack() {
    Get.back();
  }
}
