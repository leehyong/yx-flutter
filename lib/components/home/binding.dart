import 'package:get/get.dart';

import '../common.dart';
import '../work-task/task-list/controller.dart';

class TaskHomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    Get.put(CommonTaskListCatController(), permanent: true);
    Get.put(TaskListController(), permanent: true);
    // Get.lazyPut(()=> CommonTaskListCatController());
    // Get.lazyPut(()=> TaskListController());
  }
}
