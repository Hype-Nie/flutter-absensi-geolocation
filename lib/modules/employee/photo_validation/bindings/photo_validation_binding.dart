import 'package:get/get.dart';
import '../controllers/photo_validation_controller.dart';

class PhotoValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoValidationController>(() => PhotoValidationController());
  }
}
