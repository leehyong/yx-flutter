import 'package:get/get.dart';

import '../common.dart';
import '../work-task/task-list/controller.dart';

class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    // Get.lazyPut(()=> CommonTaskListCatController());
    Get.put(CommonTaskListCatController(), permanent: true);
    Get.put(TaskListController(), permanent: true);
  }
}
