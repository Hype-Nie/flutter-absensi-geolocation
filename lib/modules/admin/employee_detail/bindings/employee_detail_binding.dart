import 'package:get/get.dart';
import '../controllers/employee_detail_controller.dart';

class EmployeeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EmployeeDetailController>(EmployeeDetailController());
  }
}
