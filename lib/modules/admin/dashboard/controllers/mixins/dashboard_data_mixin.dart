import 'package:get/get.dart';
import '../../../../../../data/models/dashboard_attendance_model.dart';

mixin DashboardDataMixin on GetxController {
  // Dashboard Data
  final RxString greeting = ''.obs;
  final RxString userName = ''.obs;
  final RxString currentDate = ''.obs;
  final RxInt totalHadir = 0.obs;
  final RxInt totalIzin = 0.obs;
  final RxInt totalSakit = 0.obs;
  final RxInt totalTerlambat = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxList<DashboardAttendanceModel> attendanceList = <DashboardAttendanceModel>[].obs;

  // Filtered attendance list for search
  final RxList<DashboardAttendanceModel> filteredAttendanceList = <DashboardAttendanceModel>[].obs;

  Future<void> loadDashboardData();

  /// Get the display list (filtered or all)
  List<DashboardAttendanceModel> get displayList {
    if (searchQuery.value.isEmpty) {
      return attendanceList;
    }
    final query = searchQuery.value.toLowerCase();
    return attendanceList.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.npk.toLowerCase().contains(query);
    }).toList();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    // Update filtered list
    filteredAttendanceList.value = displayList;
  }
}
