import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../routes/app_routes.dart';

class AttendanceSuccessController extends GetxController {
  final attendanceType = ''.obs;
  final isCheckIn = true.obs;
  final currentDate = ''.obs;
  final currentTime = ''.obs;
  final status = 'Tepat Waktu'.obs;
  final lateDuration = Rxn<int>();
  final attendanceData = Rxn<AttendanceHistoryModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    isCheckIn.value = args?['isCheckIn'] ?? true;

    // Check if attendance data from API is available
    final apiData = args?['attendanceData'];
    if (apiData != null && apiData is AttendanceHistoryModel) {
      attendanceData.value = apiData;
      _setDataFromApi();
    } else {
      _setDateTime();
      _checkStatus();
    }
  }

  void _setDataFromApi() {
    final data = attendanceData.value;
    if (data == null) return;

    // Set date from API (use local time/WIB)
    currentDate.value = DateFormat('dd/MM/yyyy').format(data.tanggal.toLocal());
    // Set time from API (clock_in/clock_out format: "HH:mm:ss")
    if (isCheckIn.value) {
      currentTime.value = data.clockIn.substring(0, 5); // Get HH:mm only
    } else {
      // For clock out, use clockOut time if available, otherwise use clockIn
      currentTime.value = data.clockOut != null
          ? data.clockOut!.substring(0, 5)
          : data.clockIn.substring(0, 5);
    }
    // Set status from API
    status.value = _formatStatus(data.status);
    // Set late duration
    lateDuration.value = data.lateDuration;
  }

  String _formatStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'hadir':
        return 'Tepat Waktu';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return apiStatus;
    }
  }

  void _setDateTime() {
    final now = DateTime.now();
    currentDate.value = DateFormat('dd/MM/yyyy').format(now);
    currentTime.value = DateFormat('HH:mm').format(now);
  }

  void _checkStatus() {
    final now = DateTime.now();
    final checkInLimit = DateTime(now.year, now.month, now.day, 8, 0); // 08:00

    if (isCheckIn.value && now.isAfter(checkInLimit)) {
      status.value = 'Terlambat';
    } else {
      status.value = 'Tepat Waktu';
    }
  }

  void goToDashboard() {
    Get.offAllNamed(AppRoutes.employeeDashboard);
  }
}
