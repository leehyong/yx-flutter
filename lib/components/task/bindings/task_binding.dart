import 'package:get/get.dart';

import '../../../api/department_provider.dart';
import '../controllers/task_controller.dart';

class TaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DepartmentProvider());
    Get.lazyPut(() => TaskDetailController());
  }
}
