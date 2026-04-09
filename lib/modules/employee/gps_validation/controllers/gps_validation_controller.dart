import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';

class LocationPoint {
  final String name;
  final LatLng position;

  const LocationPoint({required this.name, required this.position});
}

class GpsValidationController extends GetxController {
  final SecurityService _securityService = Get.find<SecurityService>();
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isLocationValid = false.obs;
  final currentPosition = Rxn<Position>();
  final attendanceType = ''.obs;
  final nearestPoint = Rxn<LocationPoint>();
  final distanceToNearest = 0.0.obs;

  // Security status
  final isSecurityChecking = false.obs;
  final securityWarnings = <String>[].obs;

  // Clock-in/out state
  final isClockOut = false.obs;
  final todayAttendance = Rxn<AttendanceHistoryModel>();
  final canSubmit = true.obs;
  final timeUntilCanSubmit = ''.obs;

  // Outside location state
  final isOutsideLocation = false.obs;

  // NTP accurate time
  final accurateTime = Rxn<DateTime>();

  // Validation radius in meters
  final double validationRadius = 200.0;

  // 10 predefined location points - User akan sesuaikan koordinatnya nanti
  final List<LocationPoint> validationPoints = const [
    // LocationPoint(name: 'Lokasi 1', position: LatLng(-8.151595, 113.734986)),
    LocationPoint(name: 'Lokasi 1', position: LatLng(-7.15162, 111.60486)),
    LocationPoint(name: 'Lokasi 2', position: LatLng(-8.146722, 113.686282)),
    LocationPoint(name: 'Lokasi 3', position: LatLng(-8.151595, 113.734986)),
    LocationPoint(name: 'Lokasi 4', position: LatLng(-8.17268, 113.68994)),
    LocationPoint(name: 'Lokasi 5', position: LatLng(-7.2595, 112.7540)),
    LocationPoint(name: 'Lokasi 6', position: LatLng(-7.2600, 112.7545)),
    LocationPoint(name: 'Lokasi 7', position: LatLng(-7.2605, 112.7550)),
    LocationPoint(name: 'Lokasi 8', position: LatLng(-7.2610, 112.7555)),
    LocationPoint(name: 'Lokasi 9', position: LatLng(-7.2615, 112.7560)),
    LocationPoint(name: 'Lokasi 10', position: LatLng(-7.2620, 112.7565)),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    isClockOut.value = args?['isClockOut'] ?? false;
    _getCurrentLocation();
    if (isClockOut.value) {
      _checkTodayAttendance();
    }
  }

  Future<void> _checkTodayAttendance() async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    final attendance = await _attendanceService.getTodayAttendance(
      currentUser.id,
    );

    if (attendance != null) {
      todayAttendance.value = attendance;
      AppLogger.info(
        'GpsValidation: Today attendance found - ID: ${attendance.id}, '
        'ClockIn: ${attendance.clockIn}, ClockOut: ${attendance.clockOut ?? "null"}',
      );

      if (attendance.clockOut == null) {
        _validateClockOutTime();
      }
    }
  }

  Future<void> _validateClockOutTime() async {
    try {
      final now = await _securityService.getAccurateTime();
      final today = DateTime(now.year, now.month, now.day);
      final nineAM = DateTime(today.year, today.month, today.day, 9, 0, 0);

      if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
        canSubmit.value = true;
        timeUntilCanSubmit.value = '';
      } else {
        canSubmit.value = false;
        final minutesUntilNine = nineAM.difference(now).inMinutes;
        timeUntilCanSubmit.value =
            'Clock out hanya bisa setelah jam 09:00. Tunggu $minutesUntilNine menit lagi';
        Future.delayed(const Duration(minutes: 1), _validateClockOutTime);
      }
    } catch (e) {
      AppLogger.error('GpsValidation: NTP time fetch failed, using device time', e);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final nineAM = DateTime(today.year, today.month, today.day, 9, 0, 0);

      if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
        canSubmit.value = true;
        timeUntilCanSubmit.value = '';
      } else {
        canSubmit.value = false;
        final minutesUntilNine = nineAM.difference(now).inMinutes;
        timeUntilCanSubmit.value =
            'Clock out hanya bisa setelah jam 09:00. Tunggu $minutesUntilNine menit lagi';
        Future.delayed(const Duration(minutes: 1), _validateClockOutTime);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Layanan lokasi tidak aktif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Izin lokasi ditolak',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = position;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateLocation() async {
    if (currentPosition.value == null) {
      Get.snackbar(
        'Error',
        'Lokasi belum tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading for security check
    isSecurityChecking.value = true;

    // Perform comprehensive security check
    final securityReport = await _securityService.performSecurityCheck(
      currentPosition.value!,
    );

    isSecurityChecking.value = false;
    securityWarnings.value = securityReport.warnings;

    // Store accurate time
    accurateTime.value = securityReport.accurateTime;

    // Check if security check passed
    if (!securityReport.isSecure) {
      _showSecurityWarningDialog(securityReport);
      return;
    }

    // Find nearest point and calculate distance
    LocationPoint? closestPoint;
    double minDistance = double.infinity;

    for (var point in validationPoints) {
      double distance = Geolocator.distanceBetween(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        point.position.latitude,
        point.position.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    nearestPoint.value = closestPoint;
    distanceToNearest.value = minDistance;

    // Validate if within radius
    if (minDistance <= validationRadius) {
      isOutsideLocation.value = false;
      isLocationValid.value = true;
      Get.snackbar(
        'Validasi Berhasil',
        'Anda berada di ${closestPoint?.name} (${minDistance.toStringAsFixed(0)}m)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Submit attendance directly after GPS validation
      Future.delayed(const Duration(seconds: 2), () {
        _submitAttendance();
      });
    } else {
      isLocationValid.value = false;
      _showOutsideLocationDialog(closestPoint, minDistance, securityReport);
    }
  }

  /// Create a small 1x1 pixel dummy PNG image file for API compatibility
  Future<File> _createDummyImage() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/dummy_attendance_${DateTime.now().millisecondsSinceEpoch}.png');

    // Minimal valid 1x1 white PNG (67 bytes)
    final bytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
      0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
      0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
      0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    await file.writeAsBytes(bytes);
    return file;
  }

  /// Submit attendance directly without photo (sends dummy image for API compatibility)
  Future<void> _submitAttendance() async {
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

    isSubmitting.value = true;

    try {
      // Create dummy image for API compatibility (backend still requires image field)
      final dummyImage = await _createDummyImage();

      late final ClockInResult result;

      if (isClockOut.value && todayAttendance.value != null) {
        // Clock Out
        result = await _attendanceService.clockOut(
          attendanceId: todayAttendance.value!.id,
          clockOutImage: dummyImage,
          clockOutLat: currentPosition.value!.latitude,
          clockOutLong: currentPosition.value!.longitude,
        );
      } else {
        // Clock In
        final attendanceTime =
            accurateTime.value ?? await _securityService.getAccurateTime();

        result = await _attendanceService.clockIn(
          userId: currentUser.id,
          tanggal: attendanceTime,
          clockInImage: dummyImage,
          clockInLat: currentPosition.value!.latitude,
          clockInLong: currentPosition.value!.longitude,
          status: isOutsideLocation.value ? 'menunggu_konfirmasi' : null,
        );
      }

      // Clean up dummy image
      try {
        await dummyImage.delete();
      } catch (_) {}

      isSubmitting.value = false;

      if (result.isSuccess && result.data != null) {
        Get.snackbar(
          'Berhasil',
          isClockOut.value ? 'Clock out berhasil' : 'Clock in berhasil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to success page
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(
            AppRoutes.employeeAttendanceSuccess,
            arguments: {
              'type': attendanceType.value,
              'isCheckIn': !isClockOut.value,
              'attendanceData': result.data,
              'accurateTime': accurateTime.value,
            },
          );
        });
      } else {
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
      isSubmitting.value = false;
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

  void _showOutsideLocationDialog(
    LocationPoint? closestPoint,
    double distance,
    SecurityReport securityReport,
  ) {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.location_off, color: AppColors.orange, size: 48),
        title: const Text('Diluar Area Lokasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda berada di luar area lokasi yang ditentukan.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Jarak: ${distance.toStringAsFixed(0)}m dari ${closestPoint?.name ?? "lokasi terdekat"}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Jarak maksimal: ${validationRadius.toStringAsFixed(0)}m',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              'Jika melanjutkan, absensi Anda akan berstatus "Menunggu Konfirmasi" dan memerlukan persetujuan admin.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(closeOverlays: true);
              isOutsideLocation.value = true;
              accurateTime.value = securityReport.accurateTime;
              _submitAttendance();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSecurityWarningDialog(SecurityReport report) {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.block, color: AppColors.error, size: 48),
        title: const Text('Absensi Ditolak', style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terdeteksi aktivitas mencurigakan. Anda tidak dapat melakukan absensi.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...report.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(warning, style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan periksa perangkat Anda dan hubungi admin jika ini adalah kesalahan.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(closeOverlays: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kembali'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void refreshLocation() {
    _getCurrentLocation();
  }
}
