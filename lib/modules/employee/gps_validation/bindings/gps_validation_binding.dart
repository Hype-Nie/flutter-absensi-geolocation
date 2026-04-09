import 'package:get/get.dart';
import '../controllers/gps_validation_controller.dart';

class GpsValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GpsValidationController>(() => GpsValidationController());
  }
}
