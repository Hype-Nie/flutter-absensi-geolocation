import 'package:get/get.dart';
import '../controllers/attendance_success_controller.dart';

class AttendanceSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceSuccessController>(() => AttendanceSuccessController());
  }
}
