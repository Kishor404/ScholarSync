import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/cgpa_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/document_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => CgpaController());
    Get.lazyPut(() => CourseController());
    Get.lazyPut(() => DocumentController());
  }
}
