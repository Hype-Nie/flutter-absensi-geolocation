import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../routes/app_routes.dart';

class PhotoValidationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final SecurityService _securityService = Get.find<SecurityService>();

  final isLoading = false.obs;
  final capturedImage = Rxn<File>();
  final isPhotoValid = true.obs;
  final errorMessage = ''.obs;

  final attendanceType = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  // NTP accurate time (independent of device time)
  final accurateTime = Rxn<DateTime>();

  // Security warnings from GPS validation
  final securityWarnings = <String>[].obs;

  // Clock-in/out state
  final isClockOut = false.obs;
  final todayAttendance = Rxn<AttendanceHistoryModel>();
  final canSubmit = true.obs;
  final timeUntilCanSubmit = ''.obs;

  // Outside location state
  final isOutsideLocation = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    latitude.value = args?['latitude'] ?? 0.0;
    longitude.value = args?['longitude'] ?? 0.0;

    // Receive NTP time from GPS validation
    if (args != null && args['accurateTime'] != null) {
      accurateTime.value = args['accurateTime'] as DateTime;
    }

    // Receive security warnings if any
    if (args != null && args['securityWarnings'] != null) {
      final warnings = args['securityWarnings'] as List;
      securityWarnings.value = warnings.cast<String>();
    }

    // Receive outside location flag
    if (args != null && args['isOutsideLocation'] == true) {
      isOutsideLocation.value = true;
    }

    _checkTodayAttendance();
  }

  Future<void> _checkTodayAttendance() async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    isLoading.value = true;

    final attendance = await _attendanceService.getTodayAttendance(
      currentUser.id,
    );

    isLoading.value = false;

    if (attendance != null) {
      todayAttendance.value = attendance;

      AppLogger.info(
        'PhotoValidation: Today attendance found - ID: ${attendance.id}, '
        'ClockIn: ${attendance.clockIn}, ClockOut: ${attendance.clockOut ?? "null"}',
      );

      // If already checked in but not checked out
      if (attendance.clockOut == null) {
        isClockOut.value = true;
        AppLogger.info(
          'PhotoValidation: User can clock out, validating time...',
        );
        _checkIfCanClockOut();
      } else {
        AppLogger.info('PhotoValidation: User already checked out today');
      }
    } else {
      AppLogger.info('PhotoValidation: No attendance found for today');
    }
  }

  void _checkIfCanClockOut() {
    final attendance = todayAttendance.value;
    if (attendance == null) return;

    // Always fetch fresh NTP time for clock out validation
    // This ensures we have the current time, not the old GPS validation time
    _validateClockOutTime();
  }

  Future<void> _validateClockOutTime() async {
    try {
      // Fetch fresh NTP time
      final now = await _securityService.getAccurateTime();
      final today = DateTime(now.year, now.month, now.day);
      final nineAM = DateTime(today.year, today.month, today.day, 9, 0, 0);

      AppLogger.info(
        'PhotoValidation: Clock out time check - '
        'Now: $now, NineAM: $nineAM',
      );

      if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
        canSubmit.value = true;
        timeUntilCanSubmit.value = '';
        AppLogger.info('PhotoValidation: Clock out ALLOWED - time is >= 09:00');
      } else {
        canSubmit.value = false;
        final minutesUntilNine = nineAM.difference(now).inMinutes;
        timeUntilCanSubmit.value =
            'Clock out hanya bisa setelah jam 09:00. Tunggu $minutesUntilNine menit lagi';
        AppLogger.warning(
          'PhotoValidation: Clock out BLOCKED - $minutesUntilNine minutes until 09:00',
        );

        // Auto-check again after a minute
        Future.delayed(const Duration(minutes: 1), _validateClockOutTime);
      }
    } catch (e) {
      AppLogger.error(
        'PhotoValidation: NTP time fetch failed, using device time',
        e,
      );
      // If NTP fails, use device time as fallback
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final nineAM = DateTime(today.year, today.month, today.day, 9, 0, 0);

      if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
        canSubmit.value = true;
        timeUntilCanSubmit.value = '';
        AppLogger.info('PhotoValidation: Clock out ALLOWED (device time)');
      } else {
        canSubmit.value = false;
        final minutesUntilNine = nineAM.difference(now).inMinutes;
        timeUntilCanSubmit.value =
            'Clock out hanya bisa setelah jam 09:00. Tunggu $minutesUntilNine menit lagi';
        AppLogger.warning(
          'PhotoValidation: Clock out BLOCKED (device time) - $minutesUntilNine minutes until 09:00',
        );

        // Auto-check again after a minute
        Future.delayed(const Duration(minutes: 1), _validateClockOutTime);
      }
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 60, // Lower quality to reduce file size
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final imageFile = File(image.path);
        final fileSize = await imageFile.length();
        final fileSizeInMB = fileSize / (1024 * 1024);

        // Check if file is too large (> 2MB)
        if (fileSizeInMB > 2.0) {
          Get.snackbar(
            'Peringatan',
            'Ukuran foto terlalu besar (${fileSizeInMB.toStringAsFixed(2)} MB). Silakan ambil ulang dengan pencahayaan lebih rendah.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.warning,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        capturedImage.value = imageFile;
        isPhotoValid.value = true;
        errorMessage.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitAttendance() async {
    if (capturedImage.value == null) {
      Get.snackbar(
        'Error',
        'Silakan ambil foto terlebih dahulu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    // Check if can submit (for clock-out, must wait until 9 AM)
    if (!canSubmit.value) {
      Get.snackbar(
        'Perhatian',
        timeUntilCanSubmit.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final currentUser = _authService.currentUser.value;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'User tidak ditemukan. Silakan login kembali',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      late final result;

      if (isClockOut.value && todayAttendance.value != null) {
        // Clock Out
        result = await _attendanceService.clockOut(
          attendanceId: todayAttendance.value!.id,
          clockOutImage: capturedImage.value!,
          clockOutLat: latitude.value,
          clockOutLong: longitude.value,
        );
      } else {
        // Clock In - Use NTP time for accurate timestamp
        final attendanceTime =
            accurateTime.value ?? await _securityService.getAccurateTime();

        result = await _attendanceService.clockIn(
          userId: currentUser.id,
          tanggal: attendanceTime,
          clockInImage: capturedImage.value!,
          clockInLat: latitude.value,
          clockInLong: longitude.value,
          status: isOutsideLocation.value ? 'menunggu_konfirmasi' : null,
        );
      }

      isLoading.value = false;

      if (result.isSuccess && result.data != null) {
        Get.snackbar(
          'Berhasil',
          isClockOut.value ? 'Clock out berhasil' : 'Clock in berhasil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to success page with attendance data and local image
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(
            AppRoutes.employeeAttendanceSuccess,
            arguments: {
              'type': attendanceType.value,
              'isCheckIn': !isClockOut.value,
              'attendanceData': result.data,
              'capturedImage':
                  capturedImage.value, // Pass local file for immediate display
              'accurateTime': accurateTime.value,
            },
          );
        });
      } else {
        // Show detailed error message
        final errorMsg = result.error ?? 'Gagal menyimpan absensi';

        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: SingleChildScrollView(child: Text(errorMsg)),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void retakePhoto() {
    capturedImage.value = null;
    isPhotoValid.value = true;
    errorMessage.value = '';
  }
}
