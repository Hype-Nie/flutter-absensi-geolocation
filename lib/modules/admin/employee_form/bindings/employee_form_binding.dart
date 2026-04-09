import 'package:get/get.dart';
import '../controllers/employee_form_controller.dart';

class EmployeeFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EmployeeFormController>(EmployeeFormController());
  }
}
