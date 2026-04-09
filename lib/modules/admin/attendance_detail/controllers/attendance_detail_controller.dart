import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';

class AttendanceDetailController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final isUpdating = false.obs;
  final attendance = Rxn<AttendanceHistoryModel>();
  final selectedStatus = ''.obs;
  final canUpdateStatus = false.obs;

  final List<Map<String, String>> statusOptions = [
    {'value': 'hadir', 'label': 'Hadir'},
    {'value': 'terlambat', 'label': 'Terlambat'},
    {'value': 'izin', 'label': 'Izin'},
    {'value': 'sakit', 'label': 'Sakit'},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final forceReadOnly = args?['readOnly'] == true;
    final isAdmin = _authService.currentUser.value?.isAdmin == true;
    canUpdateStatus.value = isAdmin && !forceReadOnly;

    final attendanceId = args?['attendanceId'] as int?;
    if (attendanceId != null) {
      _loadAttendance(attendanceId);
    }
  }

  Future<void> _loadAttendance(int id) async {
    isLoading.value = true;
    try {
      final result = await _attendanceService.getSingleAttendance(id);
      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        attendance.value = result.data!.first;
        selectedStatus.value = attendance.value!.status.toLowerCase();
        AppLogger.info(
          'AttendanceDetail: Loaded attendance ID: $id, status: ${attendance.value!.status}',
        );
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Data absensi tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      AppLogger.error('AttendanceDetail: Error loading attendance', e);
      Get.snackbar(
        'Error',
        'Gagal memuat data absensi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void onStatusChanged(String? value) {
    if (value != null) {
      selectedStatus.value = value;
    }
  }

  Future<void> updateStatus() async {
    if (!canUpdateStatus.value) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat mengubah status absensi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final att = attendance.value;
    if (att == null) return;

    if (selectedStatus.value == att.status.toLowerCase()) {
      Get.snackbar(
        'Info',
        'Status tidak berubah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.grey600,
        colorText: Colors.white,
      );
      return;
    }

    final statusLabel = statusOptions.firstWhere(
      (opt) => opt['value'] == selectedStatus.value,
    )['label']!;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: Text(
          'Ubah status absensi "${att.user?.name ?? "Karyawan"}" menjadi "$statusLabel"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _doUpdateStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _doUpdateStatus() async {
    final att = attendance.value;
    if (att == null) return;

    isUpdating.value = true;
    try {
      final result = await _attendanceService.updateStatus(
        id: att.id,
        status: selectedStatus.value,
        lateDuration: max(0, att.lateDuration ?? 0),
      );

      if (result.isSuccess && result.data != null) {
        attendance.value = result.data;
        selectedStatus.value = result.data!.status.toLowerCase();

        AppLogger.info(
          'AttendanceDetail: Status updated to ${result.data!.status}',
        );

        Get.snackbar(
          'Berhasil',
          'Status berhasil diubah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          result.error ?? 'Gagal mengubah status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppLogger.error('AttendanceDetail: Error updating status', e);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengubah status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  String get statusLabel {
    final match = statusOptions.where(
      (opt) => opt['value'] == selectedStatus.value,
    );
    return match.isNotEmpty ? match.first['label']! : selectedStatus.value;
  }
}
