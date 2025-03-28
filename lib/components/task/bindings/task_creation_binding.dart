
import 'package:yx/components/task/controllers/task_creation_controller.dart';
import 'package:get/get.dart';

class TaskCreationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TaskCreationController());
  }
}
